//
//  GitHubRepoSheet.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

import OctoKit

struct GitHubRepoSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var token: String = ""
    @State var progressSheet: Bool = false
    @State var currentRepos: [URL] = []
    @State var deleteKeyword: String = ""
    @State var shouldSetValueOnExit: Bool = false

    var body: some View {
        SheetTemplate.makeSheet(
            title: "添加来自 GitHub 的仓库",
            body: AnyView(container)
        ) { confirmed in
            debugPrint("sheet completed \(confirmed)")
            if confirmed || shouldSetValueOnExit, currentRepos.count > 0 {
                NotificationCenter.default.post(name: .sourceAdd, object: makeSourceRegData())
            }
            presentationMode.wrappedValue.dismiss()
        }
        .sheet(isPresented: $progressSheet, onDismiss: nil) {
            SheetTemplate.makeProgress(text: "正在查找代码仓库...")
        }
        .onReceive(NotificationCenter.default.publisher(for: .sourceLoad, object: nil)) { notification in
            guard let source = (notification as Notification).object as? SourceRegistrationData else {
                return
            }
            debugPrint("receiving source reg data \(source)")
            shouldSetValueOnExit = true
            currentRepos = source
                .repos
                .compactMap { $0.representedData[.remoteUrl] }
                .compactMap { URL(string: $0) }
            token = source
                .repos
                .first?
                .representedData[.token]
                ?? ""
        }
    }

    func makeSourceRegData() -> SourceRegistrationData {
        var repos = [SourceRegistrationData.RepoElement]()
        for currentRepo in currentRepos {
            repos.append(.init(remoteUrl: currentRepo, username: "redacted", token: token))
        }
        return .init(
            register: .github,
            mainUrl: URL(string: "https://github.com/")!,
            repos: repos
        )
    }

    var container: some View {
        VStack(alignment: .leading) {
            helperNotice
            Divider()
            if currentRepos.count > 0 {
                repoDeleter
                Divider().hidden()
                ScrollView {
                    repoStack
                        .padding(10)
                }
                .padding(-10)
            } else {
                HStack {
                    Text("个人访问令牌")
                    TextField("ghp_xxxxxx", text: $token)
                }
                Button {
                    progressSheet = true
                    gatheringData(token: token.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) { result in
                        progressSheet = false
                        switch result {
                        case let .success(repos):
                            currentRepos = repos
                        case let .failure(error):
                            debugPrint(error.localizedDescription)
                            SheetTemplate.makeErrorAlert(with: error, delay: 0.5)
                        }
                    }
                } label: {
                    Text("获取数据")
                }
                .disabled(token.count < 1)
            }
        }
    }

    var repoDeleter: some View {
        HStack {
            TextField("删除包含 <关键词> 的仓库，区分大小写。", text: $deleteKeyword)
            Button {
                if deleteKeyword.count > 0 {
                    currentRepos = currentRepos
                        .filter { !$0.path.contains(deleteKeyword) }
                }
                deleteKeyword = ""
            } label: {
                Text("删除关键词")
            }
            .disabled(deleteKeyword.count < 1)
        }
    }

    var repoStack: some View {
        // validated! show the items
        ForEach(0 ..< currentRepos.count, id: \.self) { index in
            Group {
                HStack {
                    Text(currentRepos[index].absoluteString)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    Spacer()
                    Button {
                        currentRepos.remove(at: index)
                    } label: {
                        Text("删除")
                    }
                }
                if index < currentRepos.count - 1 {
                    Divider()
                }
            }
        }
    }

    var helperNotice: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("若要连接到 GitHub，请参考")
                Button {
                    NSWorkspace.shared.open(URL(
                        string: "https://docs.github.com/cn/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
                    )!)
                } label: {
                    Text("这份文档")
                }
                .makeHoverPointer()
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.orange)
                Text("以获取个人访问令牌。")
            }
            Text("我们将会列出你的全部仓库地址供你挑选，稍后克隆到本地为分析作准备。")
            Text("请为令牌添加 repo 和 user 的全部权限。")
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
    }
}

private func gatheringData(token: String, complete: @escaping (Result<[URL], Error>) -> Void) {
    func dispatchWorks() -> Result<[URL], Error> {
        let api = GitHubApi(config: .init(token: token))
        var result = Set<URL>()
        do {
            try api.validate()
            let repos = try api.repositories()
            repos.forEach { result.insert($0) }
        } catch {
            return .failure(error)
        }
        guard result.count > 0 else {
            return .failure(ApiError.emptyData)
        }
        return .success([URL](result).sorted { $0.path < $1.path })
    }

    DispatchQueue.global().async {
        let sender = dispatchWorks()
        DispatchQueue.main.async {
            complete(sender)
        }
    }
}
