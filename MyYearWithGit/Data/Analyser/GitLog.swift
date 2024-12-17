//
//  GitLog.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import Foundation

private let jsonDecoder = JSONDecoder()

extension RepoAnalyser {
    struct GitLogElement {
        let hash: String
        let autherEmail: String
        let date: String
        let note: String
    }

    func grabGitCommitLog() -> [GitLogElement]? {
        let command = AuxiliaryExecuteWrapper.spawn(
            command: AuxiliaryExecuteWrapper.git,
            args: [
                "log",
                "--all",
            ], timeout: 0
        ) { _ in
        }
        let output = command
            .1
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var results = [GitLogElement]()

        var currentHash: String?
        var date: String?
        var autherEmail: String?
        var lineBuffer = [String]()

        func submitBarrier() {
            defer {
                currentHash = nil
                date = nil
                autherEmail = nil
                lineBuffer = []
            }
            guard let currentHash,
                  let date,
                  let autherEmail
            else {
                return
            }
            let commitLog = lineBuffer
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 0 }
                .joined(separator: "\n")
            let build = GitLogElement(
                hash: currentHash,
                autherEmail: autherEmail,
                date: date,
                note: commitLog
            )
            results.append(build)
//            print(build)
        }

        for line in output.components(separatedBy: "\n") {
            if line.hasPrefix("commit ") {
                submitBarrier()
                currentHash = line
                    .components(separatedBy: " ")
                    .last?
                    .lowercased() // <- LOWER CASE HERE, IT'S HASH
                continue
            }
            if line.hasPrefix("Author: ") {
                let trim = String(line.dropFirst("Author:".count))
                autherEmail = trim
                    .components(separatedBy: "<")
                    .last?
                    .components(separatedBy: ">")
                    .first?
                    .lowercased()
                continue
            }
            if line.hasPrefix("Date:") {
                var line = String(line.dropFirst("Date:".count))
                while line.hasPrefix(" ") {
                    line.removeFirst()
                }
                date = line
                continue
            }
            lineBuffer.append(line)
        }
        submitBarrier()

        if results.count == 0 {
            return nil
        }
        return results
    }
}
