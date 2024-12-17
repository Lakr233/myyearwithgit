//
//  SheetTemplate.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

let preferredSheetTitleSize: CGFloat = 20

enum SheetTemplate {
    typealias Confirmed = Bool
    static func makeSheet(title: LocalizedStringKey, body: AnyView, complete: @escaping (Confirmed) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: preferredSheetTitleSize, weight: .semibold, design: .rounded))
            Divider()
            GeometryReader { _ in
                body
            }
            Divider()
            HStack {
                Button {
                    complete(false)
                } label: {
                    Text("取消")
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button {
                    complete(true)
                } label: {
                    Text("完成")
                }
            }
        }
        .padding()
    }

    static func makeProgress(text: String) -> some View {
        ProgressView(text)
            .frame(width: 400, height: 200)
    }

    static func makeErrorAlert(with error: Error, delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = error.localizedDescription
            alert.addButton(withTitle: "确定")
            alert.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) { _ in
            }
        }
    }
}
