//
//  AnalysisView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import SwiftUI

// After analysis, let user to choose his emails

extension Notification.Name {
    static let analysisComlete = Notification.Name("wiki.qaq.analysis.complete")
    static let analysisErase = Notification.Name("wiki.qaq.analysis.erase")
}

struct AnalysisView: View {
    let sourcePackage: SourcePackage

    init(sourcePackage: SourcePackage) {
        self.sourcePackage = sourcePackage
        _progressTitle = State<String>(initialValue: NSLocalizedString("正在处理...", comment: ""))
        _completed = State<Int>(initialValue: 0)
        let count = sourcePackage
            .representedObjects
            .map(\.repos.count)
            .reduce(0, +)
            + 1
        _total = State<Int>(initialValue: count)
    }

    @State var analyserSession = UUID()

    @State var progressTitle: String
    @State var completed: Int
    @State var total: Int
    @State var progress = Progress(totalUnitCount: 0)

    var body: some View {
        GeometryReader { r in
            ZStack {
                VStack {
                    ProgressView()
                    ProgressView(progress)
                    Divider().hidden()
                    Text(progressTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .animation(.interactiveSpring(), value: progress)
                .padding()
            }
            .frame(width: r.size.width, height: r.size.height, alignment: .center)
        }
        .onChange(of: completed) { _ in
            updateProgress()
        }
        .onChange(of: total) { _ in
            updateProgress()
        }
        .onAppear {
            protectWindowFromClose()
            constructAnalysis()
        }
    }

    func updateProgress() {
        let builder = Progress(totalUnitCount: Int64(total))
        builder.completedUnitCount = Int64(completed)
        progress = builder
    }

    func constructAnalysis() {
        DispatchQueue.global().async {
            // iterate over the source
            let session = RepoAnalyser.shared.beginSession()
            analyserSession = session
            RepoAnalyser.shared.submitEmails(with: [String](User.current.email))
            let tempDir = sourcePackage.tempDir
            for package in sourcePackage.representedObjects {
                switch package.register {
                case .local:
                    prepareLocalRepos(with: package, andTempDir: tempDir)
                case .gitlab, .github, .bitbucket:
                    prepareRemoteRepos(with: package, andTempDir: tempDir)
                }
            }
            update(title: NSLocalizedString("正在生成汇总...", comment: ""))
            // completed! now let's pass the analysis result
            let result = RepoAnalyser.shared.commitResult()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .analysisComlete, object: result)
            }
        }
    }

    func completeOneUnit() {
        debugPrint("progress update \(completed + 1)/\(total)")
        DispatchQueue.main.async {
            completed += 1
        }
    }

    func prepareLocalRepos(with package: SourceRegistrationData, andTempDir tempDir: URL) {
        func process(repo: SourceRegistrationData.RepoElement) {
            defer { completeOneUnit() }
            guard let identifier = repo.representedData[.identifier],
                  let location = repo.representedData[.localUrl]
            else {
                return
            }
            let from = URL(fileURLWithPath: location)
            let dest = tempDir
                .appendingPathComponent(identifier)
            update(title: String(format:
                NSLocalizedString("正在创建分析副本 %@...", comment: ""),
                from.lastPathComponent))
            // we copy .git file only, and call a reset after that
            // so .gitignore like node_modules won't go too far
//            try? FileManager.default.copyItem(at: from, to: dest)
            do {
                try FileManager.default.createDirectory(
                    at: dest,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                let git = from.appendingPathComponent(".git")
                let destGit = dest.appendingPathComponent(".git")
                try FileManager.default.copyItem(at: git, to: destGit)
                let currentDir = FileManager.default.currentDirectoryPath
                FileManager.default.changeCurrentDirectoryPath(dest.path)
                _ = AuxiliaryExecuteWrapper.spawn(
                    command: AuxiliaryExecuteWrapper.git,
                    args: [
                        "reset",
                        "--hard",
                    ],
                    timeout: 0
                ) { _ in
                }
                FileManager.default.changeCurrentDirectoryPath(currentDir)
            } catch {
                print(error.localizedDescription)
                return
            }

            update(title: String(format:
                NSLocalizedString("正在分析 %@...", comment: ""),
                from.lastPathComponent))
            autoreleasepool {
                analysisRepo(at: dest)
            }
        }
        for repo in package.repos {
            process(repo: repo)
        }
    }

    func prepareRemoteRepos(with package: SourceRegistrationData, andTempDir tempDir: URL) {
        func process(repo: SourceRegistrationData.RepoElement) {
            defer { completeOneUnit() }
            guard let identifier = repo.representedData[.identifier],
                  let location = repo.representedData[.remoteUrl]
            else {
                return
            }
            let dest = tempDir
                .appendingPathComponent(identifier)
            if package.register == .github {
                guard let token = repo.representedData[.token] else {
                    return
                }
                downloadRepoFromHub(
                    token: token,
                    location: location,
                    dest: dest
                )
            }
            if package.register == .gitlab {
                guard let token = repo.representedData[.token] else {
                    return
                }
                downloadRepoFromLab(
                    mainUrl: package.mainUrl.absoluteString,
                    token: token,
                    location: location,
                    dest: dest
                )
            }
            if package.register == .bitbucket {
                guard let token = repo.representedData[.token] else {
                    return
                }
                downloadRepoFromBitbucket(
                    mainUrl: package.mainUrl.absoluteString,
                    username: repo.representedData[.username] ?? "broken-auth",
                    token: token,
                    location: location,
                    dest: dest
                )
            }
            update(title: String(format:
                NSLocalizedString("正在分析 %@...", comment: ""),
                location))
            analysisRepo(at: dest)
        }
        for repo in package.repos {
            process(repo: repo)
        }
    }

    func downloadRepoFromHub(token: String, location: String, dest: URL) {
        update(title: String(format:
            NSLocalizedString("正在从 Github 下载仓库 %@...", comment: ""),
            location))
        var location = location
        if location.hasPrefix("http"), let url = URL(string: location) {
            location = url.path
        }
        let realCloneLink = "https://"
            + token
            + "@github.com"
            + location
        AuxiliaryExecuteWrapper.spawn(
            command: AuxiliaryExecuteWrapper.git,
            args: ["clone", realCloneLink, dest.path],
            timeout: 0
        ) { output in
            print(output)
        }
    }

    func downloadRepoFromLab(mainUrl: String, token: String, location: String, dest: URL) {
        update(title: String(format:
            NSLocalizedString("正在从 GitLab 下载仓库 %@...", comment: ""),
            location))
        var location = location
        if location.hasPrefix("http"), let url = URL(string: location) {
            location = url.path
        }
        var realCloneLink = ""
        var trimmer = mainUrl
        if trimmer.hasPrefix("http://") {
            trimmer.removeFirst("http://".count)
            realCloneLink = "http://oauth2:\(token)@\(trimmer)"
        }
        if trimmer.hasPrefix("https://") {
            trimmer.removeFirst("https://".count)
            realCloneLink = "https://oauth2:\(token)@\(trimmer)"
        }
        if realCloneLink.hasSuffix("/") {
            realCloneLink.removeLast()
        }
        realCloneLink += location
        AuxiliaryExecuteWrapper.spawn(
            command: AuxiliaryExecuteWrapper.git,
            args: ["clone", realCloneLink, dest.path],
            timeout: 0
        ) { output in
            print(output)
        }
    }

    func downloadRepoFromBitbucket(mainUrl: String, username: String, token: String, location: String, dest: URL) {
        update(title: String(format:
            NSLocalizedString("正在从 Bitbucket 下载仓库 %@...", comment: ""),
            location))
        var location = location
        if location.hasPrefix("http"), let url = URL(string: location) {
            location = url.path
        }
        var realCloneLink = ""
        var trimmer = mainUrl
        if trimmer.hasPrefix("http://") {
            trimmer.removeFirst("http://".count)
            realCloneLink = "http://\(username):\(token)@\(trimmer)"
        }
        if trimmer.hasPrefix("https://") {
            trimmer.removeFirst("https://".count)
            realCloneLink = "https://\(username):\(token)@\(trimmer)"
        }
        if realCloneLink.hasSuffix("/") {
            realCloneLink.removeLast()
        }
        realCloneLink += location
        AuxiliaryExecuteWrapper.spawn(
            command: AuxiliaryExecuteWrapper.git,
            args: ["clone", realCloneLink, dest.path],
            timeout: 0
        ) { output in
            print(output)
        }
    }

    func analysisRepo(at location: URL) {
        RepoAnalyser.shared.analysis(at: location, session: analyserSession)
    }

    func update(title: String) {
        DispatchQueue.main.async {
            progressTitle = title
        }
    }
}
