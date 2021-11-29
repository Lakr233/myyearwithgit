//
//  Navigators.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import SwiftUI

struct NavigatorView: View {
    @State var progress: Bool = false

    @State var sourcePackage: SourcePackage? = nil
    @State var resultPackage: ResultPackage? = nil

    var body: some View {
        Group {
            if let resultPackage = resultPackage {
                ResultView(resultPackage: resultPackage)
                    .environmentObject(PageData())
                    .onAppear {
                        protectWindowFromClose()
                    }
            } else if let sourcePackage = sourcePackage {
                AnalysisView(sourcePackage: sourcePackage)
            } else {
                MainView()
            }
        }
        .onDrop(of: ["public.url", "public.file-url"], isTargeted: nil, perform: { items -> Bool in
            guard sourcePackage == nil else {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "分析过程中不可载入数据，请稍后再试。"
                alert.addButton(withTitle: "确定")
                alert.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) { _ in
                }
                return false
            }
            guard let item = items.first,
                  let identifier = item.registeredTypeIdentifiers.first,
                  identifier == "public.url" || identifier == "public.file-url"
            else {
                return false
            }
            item.loadItem(forTypeIdentifier: identifier, options: nil) { provider, _ in
                if let provider = provider as? Data,
                   let location = URL(dataRepresentation: provider, relativeTo: nil, isAbsolute: true),
                   let data = try? Data(contentsOf: location),
                   let object = try? JSONDecoder().decode(ResultPackage.DataSource.self, from: data)
                {
                    progress = true
                    DispatchQueue.global().async {
                        let package = ResultPackage(data: object)
                        package.update()
                        DispatchQueue.main.async {
                            progress = false
                            resultPackage = package
                        }
                    }
                }
            }
            return true
        })
        .sheet(isPresented: $progress, onDismiss: nil, content: {
            SheetTemplate.makeProgress(text: "正在解析数据...")
        })
        .onReceive(NotificationCenter.default.publisher(for: .postAnalysis, object: nil)) { notification in
            guard let sourcePackage = notification.object as? SourcePackage else {
                return
            }
            self.sourcePackage = sourcePackage
        }
        .onReceive(NotificationCenter.default.publisher(for: .analysisComlete, object: nil)) { notification in
            guard let resultPackage = notification.object as? ResultPackage else {
                return
            }
            self.resultPackage = resultPackage
            self.sourcePackage = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .analysisErase, object: nil)) { _ in
            self.resultPackage = nil
            self.sourcePackage = nil
            unprotectWindowFromClose()
        }
    }
}
