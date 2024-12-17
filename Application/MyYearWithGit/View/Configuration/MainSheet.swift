//
//  MainSheet.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

extension Notification.Name {
    static let sourceAdd = Notification.Name("wiki.qaq.mywg.source.add")
    static let sourceLoad = Notification.Name("wiki.qaq.mywg.source.load")
}

struct MainSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var openSourcePickerSheet: Bool = false

    @State var openLocalSheet: Bool = false
    @State var openGitHubSheet: Bool = false
    @State var openGitLabSheet: Bool = false
    @State var openBitbucketSheet: Bool = false
    @State var openEmailSheet: Bool = false
    @State var openFilterSheet: Bool = false

    @State var currentSources: [SourceRegistrationData] = []

    @State var inputNamespaceBuffer: String = ""

    var body: some View {
        SheetTemplate.makeSheet(
            title: "数据源",
            body: AnyView(sheetBody)
        ) { confirmed in
            debugPrint("sheet completed \(confirmed)")
            if !confirmed, currentSources.count > 0 {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "本次配置的数据源将不会保存。"
                alert.addButton(withTitle: "确定")
                alert.addButton(withTitle: "取消")
                guard let window = NSApp.keyWindow else {
                    presentationMode.wrappedValue.dismiss()
                    return
                }
                alert.beginSheetModal(for: window) { response in
                    if response == .alertFirstButtonReturn {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else if confirmed, currentSources.count < 1 {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = NSLocalizedString("没有可用的数据源，分析被取消。", comment: "")
                alert.addButton(withTitle: NSLocalizedString("确定", comment: ""))
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    alert.beginSheetModal(for: NSApp.keyWindow ?? NSWindow(), completionHandler: nil)
                }
            } else {
                presentationMode.wrappedValue.dismiss()
            }
            if currentSources.count > 0, confirmed {
                SourcePackage(sources: currentSources).postToAnalysis()
            }
        }
        .sheet(isPresented: $openSourcePickerSheet, onDismiss: nil, content: {
            PickSourceSheet()
                .frame(width: 400, height: 165, alignment: .center)
        })
        .sheet(isPresented: $openLocalSheet, onDismiss: nil, content: {
            prepareFor(sheet: LocalRepoSheet())
        })
        .sheet(isPresented: $openGitHubSheet, onDismiss: nil, content: {
            prepareFor(sheet: GitHubRepoSheet())
        })
        .sheet(isPresented: $openGitLabSheet, onDismiss: nil, content: {
            prepareFor(sheet: GitLabRepoSheet())
        })
        .sheet(isPresented: $openBitbucketSheet, onDismiss: nil, content: {
            prepareFor(sheet: BitbucketSheet())
        })
        .sheet(isPresented: $openEmailSheet, onDismiss: nil, content: {
            prepareFor(sheet: ConfigEmailSheet())
        })
        .sheet(isPresented: $openFilterSheet, onDismiss: nil) {
            prepareFor(sheet: FilterSheet())
        }
        .onReceive(NotificationCenter.default.publisher(for: .openSheet, object: nil)) { notification in
            guard let source = (notification as Notification).object as? SourceRegisters else {
                return
            }
            debugPrint("opening sheet for \(source.readableDescription())")
            openSheet(for: source)
        }
        .onReceive(NotificationCenter.default.publisher(for: .sourceAdd, object: nil)) { notification in
            guard let source = (notification as Notification).object as? SourceRegistrationData else {
                return
            }
            debugPrint("receiving source reg data \(source)")
            currentSources.append(source)
        }
    }

    func openSheet(for source: SourceRegisters) {
        switch source {
        case .local:
            openLocalSheet = true
        case .github:
            openGitHubSheet = true
        case .gitlab:
            openGitLabSheet = true
        case .bitbucket:
            openBitbucketSheet = true
        }
    }

    func prepareFor(sheet: some View) -> some View {
        sheet
            .frame(
                width: preferredApplicationSize.width * 0.9,
                height: preferredApplicationSize.height * 0.9,
                alignment: .center
            )
    }

    var buttonStack: some View {
        HStack {
            Button {
                openSourcePickerSheet.toggle()
            } label: {
                Text("添加")
            }
            Button {
                openEmailSheet.toggle()
            } label: {
                Text("配置邮箱地址")
            }
            Button {
                openFilterSheet.toggle()
            } label: {
                Text("配置排除项")
            }
            HStack(spacing: 4) {
                Spacer()
                    .frame(width: 20)
                Text("namespace::")
                    .font(Font.system(.body, design: .monospaced))
                TextField("输入昵称 可选", text: $inputNamespaceBuffer)
                    .onChange(of: inputNamespaceBuffer) { newValue in
                        User.current.namespace = newValue
                    }
                    .onAppear {
                        inputNamespaceBuffer = User.current.namespace
                    }
            }
        }
    }

    var repoStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0 ..< currentSources.count, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading) {
                        Text(currentSources[index].register.readableDescription())
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        if currentSources[index].register == .local {
                            Text(currentSources[index].mainUrl.path)
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                        } else {
                            Text(currentSources[index].mainUrl.absoluteString)
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                        }
                    }
                    Spacer()
                    Text("共 \(currentSources[index].repos.count) 个仓库")
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                    Button {
                        repoEdit(on: index)
                    } label: {
                        Text("编辑")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    Button {
                        currentSources.remove(at: index)
                    } label: {
                        Text("删除")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                }
                if index < currentSources.count - 1 {
                    Divider()
                }
            }
        }
    }

    var sheetBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
                """
                你可添加本地或远端的仓库，不用担心仓库重复，相同的提交哈希仅计算一次。
                远端仓库在分析时会被载入本地临时文件夹内，分析完成以后会从本地删除。
                你可能需要额外的步骤来获取远端仓库的访问令牌，登录时会自动添加邮件地址。
                克隆仅支持使用 HTTPS 协议。
                """
            )
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            Divider()
            buttonStack
            Divider()
            ScrollView {
                if currentSources.count == 0 {
                    Text("没有可用的数据源，请点击上面的按钮来添加。")
                } else {
                    repoStack
                }
            }
        }
    }

    func repoEdit(on index: Int) {
        let data = currentSources.remove(at: index)
        openSheet(for: data.register)
        // if user was too fast to close or pressing esc immediately
        // fuck he/her
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .sourceLoad, object: data)
        }
    }
}
