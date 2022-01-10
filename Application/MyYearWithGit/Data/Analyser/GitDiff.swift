//
//  GitDiff.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import Foundation

extension RepoAnalyser {
    struct GitCommitResult: Codable {
        // these are emails
        let email: String
//        let auther: String
//        let coAuthers: [String]
        // ...
        let date: Date
        // diff analysis
        let diffFiles: [GitFileDiff]
        struct GitFileDiff: Codable {
            // using the latest
            // eg .c changed to .swift, then we say it is a .swift
            let language: SourceLanguage?
            // file mode
            let mode: DiffMode
            // the emptyLine counted
            let emptyLineAdded: Int
            // add/remove
            let increasedLine: Int
            let decreasedLine: Int

            enum DiffMode: String, Codable {
                case modify
                case add
                case delete
            }
        }
    }

    func grabGitCommitDetail(withHash commitHash: String) -> [GitCommitResult.GitFileDiff] {
        let command = AuxiliaryExecuteWrapper.spawn(
            command: AuxiliaryExecuteWrapper.git,
            args: [
                "diff",
                "\(commitHash)^!",
            ], timeout: 0
        ) { _ in
        }
        let diff = command
            .1
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var result = [GitCommitResult.GitFileDiff]()

        var currentFileDiff: GitCommitResult.GitFileDiff?
        var currentStatus: CurrentStatus = .none
        var currentBuffer: [String] = []
        enum CurrentStatus: String {
            case none
            case header
            case body
        }

        func commitBuffer(str: String) {
            currentBuffer.append(str)
        }

        // when commit header, we construct a GitCommitResult.GitFileDiff
        func commitHeaderForAnalysis() {
            // get the first line we submit to the buffer
            // it will either be ["add", "delete", "rename"]
            // otherwise will be "index"
            guard let decisionLine = currentBuffer.first,
                  let decisionWord = decisionLine.components(separatedBy: " ").first
            else {
                debugPrint("no decision can make")
                return
            }

            var language: SourceLanguage?
            var mode: GitCommitResult.GitFileDiff.DiffMode?
            var fileName: String?
            switch decisionWord {
            case "index", "old":
                /*
                 - 0 : "old mode 100755"
                 - 1 : "new mode 100644"
                 - 2 : "index a4a32c1c..24295f0c"
                 */
                mode = .modify
                for line in currentBuffer where line.hasPrefix("+++ ") {
                    var path = String(line.dropFirst("+++ ".count))
                    while path.hasPrefix(" ") {
                        path.removeFirst()
                    }
                    while !path.hasPrefix("/"), path.count > 0 {
                        path.removeFirst()
                    }
                    guard path.count > 0 else {
                        debugPrint("unknown file <\(line)>", to: &standardError)
                        return
                    }
//                    debugPrint(path)
                    let url = URL(fileURLWithPath: path)
                    if !CommitFileFilter.shared.filter(url) { break }
                    fileName = url.lastPathComponent
                    language = SourceLanguage
                        .languageDecision(withFileExtension: url.pathExtension)
                    break
                }
            case "new":
                mode = .add
                for line in currentBuffer where line.hasPrefix("+++ ") {
                    var path = String(line.dropFirst("+++ ".count))
                    while path.hasPrefix(" ") {
                        path.removeFirst()
                    }
                    while !path.hasPrefix("/"), path.count > 0 {
                        path.removeFirst()
                    }
                    guard path.count > 0 else {
                        debugPrint("unknown file <\(line)>", to: &standardError)
                        return
                    }
//                    debugPrint(path)
                    let url = URL(fileURLWithPath: path)
                    if !CommitFileFilter.shared.filter(url) { break }
                    fileName = url.lastPathComponent
                    language = SourceLanguage
                        .languageDecision(withFileExtension: url.pathExtension)
                    break
                }
            case "similarity":
                /*
                 eg:
                 diff --git a/osfmk/corecrypto/ccn/src/ccn_set.c b/iokit/Kernel/IOPMGR.cpp
                 similarity index 80%
                 rename from osfmk/corecrypto/ccn/src/ccn_set.c
                 rename to iokit/Kernel/IOPMGR.cpp
                 index e288733..4fd29c3 100644
                 */
                mode = .modify
                for line in currentBuffer where line.hasPrefix("rename to") {
                    var path = String(line.dropFirst("rename to".count))
                    while path.hasPrefix(" ") {
                        path.removeFirst()
                    }
                    while !path.hasPrefix("/"), path.count > 0 {
                        path.removeFirst()
                    }
                    guard path.count > 0 else {
                        debugPrint("unknown file <\(line)>", to: &standardError)
                        return
                    }
//                    debugPrint(path)
                    let url = URL(fileURLWithPath: path)
                    if !CommitFileFilter.shared.filter(url) { break }
                    fileName = url.lastPathComponent
                    language = SourceLanguage
                        .languageDecision(withFileExtension: url.pathExtension)
                    break
                }
            case "deleted":
                mode = .delete
                for line in currentBuffer where line.hasPrefix("--- ") {
                    var path = String(line.dropFirst("+++ ".count))
                    while path.hasPrefix(" ") {
                        path.removeFirst()
                    }
                    while !path.hasPrefix("/"), path.count > 0 {
                        path.removeFirst()
                    }
                    guard path.count > 0 else {
                        debugPrint("unknown file <\(line)>", to: &standardError)
                        return
                    }
//                    debugPrint(path)
                    let url = URL(fileURLWithPath: path)
                    if !CommitFileFilter.shared.filter(url) { break }
                    fileName = url.lastPathComponent
                    language = SourceLanguage
                        .languageDecision(withFileExtension: url.pathExtension)
                    break
                }
            default:
                debugPrint("unknown header [\(decisionWord)]", to: &standardError)
                debugPrint(currentBuffer.joined(separator: " "), to: &standardError)
                return
            }
            guard fileName != nil, let mode = mode else {
                return
            }
            currentFileDiff = .init(
                language: language,
                mode: mode,
                emptyLineAdded: 0,
                increasedLine: 0,
                decreasedLine: 0
            )
        }

        // when commit the body, we add up the value in currentFileDiff
        func commitBodyForAnalysis() {
            guard currentBuffer.count > 0 else {
                return
            }
            guard let currentDiff = currentFileDiff else {
                // no header, drop data
                debugPrint("missing header, dropping data body", to: &standardError)
                return
            }
            var emptyLineAdded = currentDiff.emptyLineAdded
            var increasedLine = currentDiff.increasedLine
            var decreasedLine = currentDiff.decreasedLine
            for line in currentBuffer {
                var line = line
                if line.hasPrefix("+") {
                    // added
                    line.removeFirst()
                    increasedLine += 1
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).count < 1 {
                        emptyLineAdded += 1
                    }
                    DictionaryBuilder
                        .sharedIncrease
                        .feed(buffer: line, session: dictonaryIncreaseSession)
                } else if line.hasPrefix("-") {
                    // removed
                    line.removeFirst()
                    decreasedLine += 1
                    DictionaryBuilder
                        .sharedIncrease
                        .feed(buffer: line, session: dictonaryDecreaseSession)
                } else {
                    // ignore
                    continue
                }
            }

            currentFileDiff = .init(
                language: currentDiff.language,
                mode: currentDiff.mode,
                emptyLineAdded: emptyLineAdded,
                increasedLine: increasedLine,
                decreasedLine: decreasedLine
            )
            // clean the body before we double this analysis
            currentBuffer = []
        }

        // when commit the barrier, reset the header, push the result if needed
        func commitBodyBarrier() {
            commitBodyForAnalysis()
            // submit to result if needed
            if let currentFileDiff = currentFileDiff {
                result.append(currentFileDiff)
            }
            currentFileDiff = nil
        }

        func commitSwitch(status: CurrentStatus) {
            // previous status is used for selector
            let privStatus = currentStatus
            currentStatus = status
            switch privStatus {
            case .none:
                break
            case .header:
                commitHeaderForAnalysis()
            case .body:
                commitBodyForAnalysis()
            }
            // now we switch the status
            switch status {
            case .none:
                if privStatus == .body {
                    commitBodyBarrier()
                    // reset the buffers
                    currentStatus = .none
                    currentBuffer = []
                }
            case .header:
                // avoid crashing if two header nested together
                if privStatus == .body {
                    commitBodyBarrier()
                    // now we are in the header
                    // nothing to do tho
                    currentStatus = .header
                    currentBuffer = []
                }
            case .body:
                // commit the header and do the switch
                currentStatus = .body
                currentBuffer = []
            }
        }

        currentBuffer = []
        currentStatus = .none
        for line in diff.components(separatedBy: "\n") {
            autoreleasepool {
                if line.hasPrefix("diff --git ") || line.hasPrefix("diff --cc ") {
                    commitSwitch(status: .header)
                    return
                }
                if line.hasPrefix("@@") {
                    commitSwitch(status: .body)
                    return
                }
                commitBuffer(str: line)
            }
        }
        // for the last block
        commitSwitch(status: .none)

        // final result generator

        return result
    }
}
