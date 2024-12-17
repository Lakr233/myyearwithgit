//
//  RepoAnalyser.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Foundation

// Sun Apr 19 01:20:44 2020 +0800

private let dateFormatters: [DateFormatter] = [
    "E MMM d HH:mm:ss yyyy Z",
    "E MMM d HH:mm:ss yyyy",
    "E, d MMM yyyy HH:mm:ss Z",
    "MM-dd-yyyy HH:mm",
    "EEEE, MMM d, yyyy",
]
.map { createFormatter($0) }

private func createFormatter(_ str: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = str
    return dateFormatter
}

private func decodeDate(_ str: String) -> Date? {
    for formatter in dateFormatters {
        if let date = formatter.date(from: str) {
            return date
        }
    }
    return nil
}

private let calender = Calendar.current

class RepoAnalyser {
    static let shared = RepoAnalyser()
    private init() {}

    var currentSession = UUID()
    var currentResults = FinalReportCodeable(repos: [])
    var dictonaryIncreaseSession = UUID()
    var dictonaryDecreaseSession = UUID()
    var dictonaryCommitMessage = UUID()
    var requiredEmails = [String]()
    var commitHash: Set<String> = []

    struct FinalReportCodeable: Codable {
        var repos: [GitRepoResult]
    }

    func beginSession() -> UUID {
        let session = UUID()
        currentSession = session
        currentResults = FinalReportCodeable(repos: [])
        requiredEmails = []
        commitHash = []
        dictonaryIncreaseSession = DictionaryBuilder
            .sharedIncrease
            .beginSession()
        dictonaryDecreaseSession = DictionaryBuilder
            .sharedDecrease
            .beginSession()
        dictonaryCommitMessage = DictionaryBuilder
            .sharedCommit
            .beginSession()
        return session
    }

    func submitEmails(with: [String]) {
        requiredEmails = with
    }

    func analysis(at: URL, session: UUID) {
        guard session == currentSession else {
            return
        }
        defer {
            FileManager.default.changeCurrentDirectoryPath("/")
            // delete the repo after analysis
            try? FileManager.default.removeItem(at: at)
        }
        FileManager.default.changeCurrentDirectoryPath(at.path)
        // call git log

        guard let currentCommitLogs = grabGitCommitLog() else {
            print("failed to code git log, giving up!")
            return
        }
        var commitResults = [GitCommitResult]()

        // MARK: MULTI_THREAD

        let lock = NSLock()
        let queue = DispatchQueue(label: "wiki.qaq.git", attributes: .concurrent)
        let group = DispatchGroup()
        let boom = DispatchSemaphore(value: processCount)

        for currentCommitLog in currentCommitLogs {
            let currentCommitLog = currentCommitLog
            guard requiredEmails.contains(currentCommitLog.autherEmail),
                  let date = decodeDate(currentCommitLog.date),
                  let year = calender.dateComponents([.year], from: date).year,
                  year == requiredYear
            else {
                continue
            }
            guard !commitHash.contains(currentCommitLog.hash) else {
                continue
            }
            commitHash.insert(currentCommitLog.hash)
            autoreleasepool {
                // MARK: MULTI_THREAD

                group.enter()
                boom.wait()

                // MARK: EXEC

                queue.async {
                    print("calling analysis on commit \(currentCommitLog.hash) with \(currentCommitLog.autherEmail)")
                    let commitDiffs = self.grabGitCommitDetail(withHash: currentCommitLog.hash)
                    let commitResult = GitCommitResult(
                        email: currentCommitLog.autherEmail,
                        date: date,
                        diffFiles: commitDiffs
                    )

                    // DictionaryBuilder has it's own lock when feeding data
                    DictionaryBuilder
                        .sharedCommit
                        .feed(buffer: currentCommitLog.note, session: self.dictonaryCommitMessage)

                    lock.lock()
                    commitResults.append(commitResult)
                    lock.unlock()

                    // MARK: MULTI_THREAD

                    boom.signal()
                    group.leave()
                }
            }
        }
        guard commitResults.count > 0 else {
            print("no data was generated from repo \(at.path), skipping submit")
            return
        }
        print("analysis completed, submitting \(commitResults.count) result to repo")
        let repoResult = GitRepoResult(commits: commitResults)
        currentResults.repos.append(repoResult)
    }

    func commitResult() -> ResultPackage {
        print("compiling result for \(currentResults.repos.count) repos")
        let dataSource = ResultPackage.DataSource(
            repoResult: currentResults,
            dictionaryIncrease: DictionaryBuilder
                .sharedIncrease
                .commitSession(session: dictonaryIncreaseSession),
            dictionaryDecrease: DictionaryBuilder
                .sharedDecrease
                .commitSession(session: dictonaryDecreaseSession),
            dictionaryCommit: DictionaryBuilder
                .sharedCommit
                .commitSession(session: dictonaryCommitMessage)
        )
        let resultPackage = generateResultPackage(with: dataSource)
        _ = beginSession() // clear everything
        return resultPackage
    }
}
