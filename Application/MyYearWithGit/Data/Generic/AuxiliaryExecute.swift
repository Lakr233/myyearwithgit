//
//  AuxiliaryExecute.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Foundation

enum AuxiliaryExecute {
    private(set) static var git: String = "/usr/bin/git"

    static func setupExecutables() {
        let binarySearchPath = [
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
        ]
        var binaryLookupTable = [String: URL]()

        for path in binarySearchPath {
            if let items = try? FileManager
                .default
                .contentsOfDirectory(atPath: path)
            {
                for item in items {
                    let url = URL(fileURLWithPath: path)
                        .appendingPathComponent(item)
                    binaryLookupTable[item] = url
                }
            }
        }

        if let git = binaryLookupTable["git"] {
            self.git = git.path
            debugPrint("setting up binary git at \(git.path)")
        }
    }

    @discardableResult
    static func spawn(command: String,
                      args: [String],
                      timeout: Int,
                      output: @escaping (String) -> Void)
        -> (Int, String, String)
    {
        debugPrint("exec: \(command) " + args.joined(separator: " ") + " timeout: \(timeout)")
        var pipestdout: [Int32] = [0, 0]
        var pipestderr: [Int32] = [0, 0]

        let bufsiz = Int(BUFSIZ)

        pipe(&pipestdout)
        pipe(&pipestderr)

        guard fcntl(pipestdout[0], F_SETFL, O_NONBLOCK) != -1 else {
            return (-1, "", "")
        }
        guard fcntl(pipestderr[0], F_SETFL, O_NONBLOCK) != -1 else {
            return (-1, "", "")
        }

        var fileActions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&fileActions)
        posix_spawn_file_actions_addclose(&fileActions, pipestdout[0])
        posix_spawn_file_actions_addclose(&fileActions, pipestderr[0])
        posix_spawn_file_actions_adddup2(&fileActions, pipestdout[1], STDOUT_FILENO)
        posix_spawn_file_actions_adddup2(&fileActions, pipestderr[1], STDERR_FILENO)
        posix_spawn_file_actions_addclose(&fileActions, pipestdout[1])
        posix_spawn_file_actions_addclose(&fileActions, pipestderr[1])

        let args = [command] + args
        let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
        defer { for case let arg? in argv { free(arg) } }

        var pid: pid_t = 0

        let spawnStatus = posix_spawn(&pid, command, &fileActions, nil, argv + [nil], environ)
        if spawnStatus != 0 {
            return (-1, "", "")
        }

        close(pipestdout[1])
        close(pipestderr[1])

        var stdoutStr = ""
        var stderrStr = ""

        let mutex = DispatchSemaphore(value: 0)

        let readQueue = DispatchQueue(label: "wiki.qaq.command",
                                      qos: .userInitiated,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .inherit,
                                      target: nil)

        let stdoutSource = DispatchSource.makeReadSource(fileDescriptor: pipestdout[0], queue: readQueue)
        let stderrSource = DispatchSource.makeReadSource(fileDescriptor: pipestderr[0], queue: readQueue)

        stdoutSource.setCancelHandler {
            close(pipestdout[0])
            mutex.signal()
        }
        stderrSource.setCancelHandler {
            close(pipestderr[0])
            mutex.signal()
        }

        stdoutSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(pipestdout[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1, errno == EAGAIN {
                    return
                }
                stdoutSource.cancel()
                return
            }

            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                stdoutStr += str
                output(str)
            }
        }
        stderrSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }

            let bytesRead = read(pipestderr[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1, errno == EAGAIN {
                    return
                }
                stderrSource.cancel()
                return
            }

            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                stderrStr += str
                output(str)
            }
        }

        stdoutSource.resume()
        stderrSource.resume()

        var terminated = false
        if timeout > 0 {
            DispatchQueue.global().async {
                var count = 0
                while !terminated {
                    sleep(1) // no need to get this job running precisely
                    count += 1
                    if count > timeout {
                        let kill = Darwin.kill(pid, 9)
                        debugPrint("[E] execution timeout, kill \(pid) returns \(kill)")
                        terminated = true
                        return
                    }
                }
            }
        }

        mutex.wait()
        mutex.wait()
        var status: Int32 = 0

        waitpid(pid, &status, 0)
        terminated = true

        debugPrint("exec: \(command) returned \(status)")

        return (Int(status), stdoutStr, stderrStr)
    }
}
