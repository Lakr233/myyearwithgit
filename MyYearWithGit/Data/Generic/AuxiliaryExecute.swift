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
        var binaryLookupTable = [String: URL]()
        let binarySearchPath = [
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
        ]
        var searchPaths = binarySearchPath.map { URL(fileURLWithPath: $0) }
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
