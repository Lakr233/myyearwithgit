//
//  AuxiliaryExecute.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import AuxiliaryExecute
import Foundation

enum AuxiliaryExecuteWrapper {
    private(set) static var git: String = "/usr/bin/git"

    static func setupExecutables() {
        let paths = [
            CommandLine.arguments.first,
            Bundle.main.url(forResource: "GitBuild", withExtension: nil)?.path
        ].compactMap { $0 }
        setenv("PATH", "\(paths.joined(separator: ":"))", 1)
        var binaryLookupTable = [String: URL]()

        var searchPaths = paths.map { URL(fileURLWithPath: $0) }
        while !searchPaths.isEmpty {
            let path = searchPaths.removeFirst()
            
            var isDir = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) else {
                continue
            }
            if isDir.boolValue {
                let items = (try? FileManager.default.contentsOfDirectory(atPath: path.path)) ?? []
                for item in items {
                    let url = path.appendingPathComponent(item)
                    searchPaths.append(url)
                }
            } else {
                binaryLookupTable[path.lastPathComponent] = path
            }
        }

        if let git = binaryLookupTable["git"] {
            self.git = git.path
            print("setting up binary git at \(git.path)")
        } else {
            fatalError()
        }
    }
    
    static func setupGitTemplates() {
        guard let gitBuildDir = Bundle.main.url(forResource: "GitBuild", withExtension: nil) else {
            return
        }
        // export GIT_EXEC_PATH=<path_of_/libexec/git-core/>
        let execPath = gitBuildDir.appendingPathComponent("libexec/git-core")
        setenv("GIT_EXEC_PATH", execPath.path, 1)
        // git config --global init.templateDir "" -> disable template
        spawn(command: git, args: [
            "config",
            "--global",
            "init.templateDir",
            ""
        ], timeout: 10) { _ in }
    }

    @discardableResult
    static func spawn(command: String,
                      args: [String],
                      timeout: Int,
                      output: @escaping (String) -> Void)
        -> (Int, String, String)
    {
        print("exec: \(command) " + args.joined(separator: " ") + " timeout: \(timeout)")
        let recipe = AuxiliaryExecute.spawn(
            command: command,
            args: args,
            timeout: Double(timeout),
            output: output
        )
        return (recipe.exitCode, recipe.stdout, recipe.stderr)
    }
}
