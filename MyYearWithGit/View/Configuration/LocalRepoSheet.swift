//
//  LocalRepoSheet.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

var searchShouldStop: Bool = false

struct LocalRepoSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var locationTint: String = ""
    @State var currentRepos: [URL] = []
    @State var progressSheet: Bool = false
    @State var deleteKeyword: String = ""
    @State var shouldSetValueOnExit: Bool = false

    var body: some View {
        SheetTemplate.makeSheet(
            title: "添加来自本地的仓库",
            body: AnyView(container)
        ) { confirmed in
            print("sheet completed \(confirmed)")
            if confirmed || shouldSetValueOnExit, currentRepos.count > 0 {
                NotificationCenter.default.post(name: .sourceAdd, object: makeSourceRegData())
            }
            presentationMode.wrappedValue.dismiss()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sourceLoad, object: nil)) { notification in
            guard let source = (notification as Notification).object as? SourceRegistrationData else {
                return
            }
            print("receiving source reg data \(source)")
            shouldSetValueOnExit = true
            locationTint = source.mainUrl.path
            currentRepos = source
                .repos
                .compactMap { $0.representedData[.localUrl] }
                .map { URL(fileURLWithPath: $0) }
        }
    }

    func makeSourceRegData() -> SourceRegistrationData {
        var mainUrl = locationTint
        if !mainUrl.hasPrefix("/") {
            mainUrl = "/" + mainUrl
        }
        var repos = [SourceRegistrationData.RepoElement]()
        for currentRepo in currentRepos {
            repos.append(.init(localUrl: currentRepo))
        }
        return .init(
            register: .local,
            mainUrl: URL(fileURLWithPath: mainUrl),
            repos: repos
        )
    }

    var container: some View {
        VStack(alignment: .leading) {
            head
            Divider()
            if currentRepos.count > 0 {
                repoDeleter
                Divider().hidden()
            }
            ScrollView {
                VStack(alignment: .leading) {
                    if currentRepos.count < 1 {
                        Text("未找到有效的仓库。")
                    } else {
                        repositoriesView
                    }
                }
                .padding(10)
            }
            .padding(-10)
        }
        .sheet(isPresented: $progressSheet) {} content: {
            progressSheetView
        }
    }

    var head: some View {
        HStack {
            TextField("请选择一些文件夹，我们将从中搜索仓库。", text: $locationTint)
                .disabled(true)
            Button {
                select()
            } label: {
                Text("选择...")
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

    var repositoriesView: some View {
        ForEach(0 ..< currentRepos.count, id: \.self) { index in
            Group {
                HStack {
                    Text(currentRepos[index].path)
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

    var progressSheetView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("正在查找代码仓库...")
            Button {
                searchShouldStop = true
            } label: {
                Text("取消")
            }
        }
        .frame(width: 400, height: 200)
    }

    func select() {
        func searchBegin() {
            let searchRoots = panel
                .urls
                .compactMap(\.self)
            guard searchRoots.count > 0 else {
                return
            }
            locationTint = searchRoots
                .map(\.path)
                .joined(separator: ", ")
            progressSheet = true
            repoEmulator(searchPaths: searchRoots) { result in
                currentRepos = result
                progressSheet = false
            }
        }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window) { response in
                guard response == .OK else {
                    return
                }
                searchBegin()
            }
        } else {
            guard panel.runModal() == .OK else {
                return
            }
            searchBegin()
        }
    }
}

private let blockedDirectoryName: Set<String> = [
    "node_modules"
]

private func repoEmulator(searchPaths: [URL], complete: @escaping ([URL]) -> Void) {
    var searchResults: Set<URL> = []
    func search(searchRoot: URL, depth: Int) {
        guard depth < 64 else {
            // avoid stack overflow!
            return
        }
        guard !blockedDirectoryName.contains(searchRoot.lastPathComponent.lowercased()) else {
            print("[*] enumerator skipped a blocked dir \(searchRoot)")
            return
        }
        guard FileManager.default.fileExists(atPath: searchRoot.path) else {
            return
        }
        let items = (
            try? FileManager
                .default
                .contentsOfDirectory(atPath: searchRoot.path)
        ) ?? []
        // a little trick so we don't need to write this block twice
        // if .git exists and is dir, break down all the loop
        for item in [".git"] + items where !searchShouldStop {
            let location = searchRoot.appendingPathComponent(item)
            var isDir = ObjCBool(false)
            let exists = FileManager
                .default
                .fileExists(
                    atPath: location.path,
                    isDirectory: &isDir
                )
            guard exists else {
                continue
            }
            if isDir.boolValue {
                if item == ".git" {
                    searchResults.insert(searchRoot)
                }
                // for submodules
                search(searchRoot: location, depth: depth + 1)
            }
        }
    }
    DispatchQueue.global().async {
        for searchRoot in searchPaths {
            search(searchRoot: searchRoot, depth: 0)
        }
        let returnValue = [URL](
            searchResults
        )
        .sorted {
            $0.path < $1.path
        }
        searchShouldStop = false
        DispatchQueue.main.async {
            complete(returnValue)
        }
    }
}
