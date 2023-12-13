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
        let recipe = AuxiliaryExecute.spawn(
            command: command,
            args: args,
            timeout: Double(timeout),
            output: output
        )
        return (recipe.exitCode, recipe.stdout, recipe.stderr)
    }
}
