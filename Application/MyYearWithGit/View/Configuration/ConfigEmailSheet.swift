//
//  ConfigEmailSheet.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import SwiftUI

struct ConfigEmailSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var currentEmails: [String] = []

    @State var inputBuffer: String = ""

    var body: some View {
        SheetTemplate.makeSheet(title: "邮件地址",
                                body: AnyView(sheet)) { confirmed in
            debugPrint("sheet completed \(confirmed)")
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            updateEmails()
        }
    }

    var sheet: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
                """
                若要添加提交邮件地址，请在下方的文本框中输入。一次仅能输入一个，且只支持小写字符。
                若提交的电子邮件地址不在该列表内，则不会计算此次提交。
                我们会为你保存电子邮件地址记录，仅需配置一次即可。
                登录到 GitHub 或 GitLab 账号会自动添加账号所属的电子邮件地址。
                若有不愿使用的电子邮件地址，请在配置完成仓库以后，再来此处删除。
                """
            )
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            HStack {
                TextField("输入电子邮件地址", text: $inputBuffer)
                Button {
                    guard inputBuffer.count > 0 else {
                        return
                    }
                    User.current.email.insert(inputBuffer.lowercased())
                    inputBuffer = ""
                    updateEmails()
                } label: {
                    Text("添加")
                }
                .disabled(!inputBuffer.contains("@"))
            }
            ScrollView {
                ForEach(0 ..< currentEmails.count, id: \.self) { index in
                    HStack {
                        Text(currentEmails[index])
                        Spacer()
                        Button {
                            removeEmail(matching: currentEmails[index])
                        } label: {
                            Text("删除")
                        }
                    }
                }
                .padding(10)
            }
            .padding(-10)
        }
    }

    func updateEmails() {
        currentEmails = [String](User.current.email)
    }

    func removeEmail(matching: String) {
        let new = User
            .current
            .email
            .filter { $0 != matching }
        User.current.email = new
        updateEmails()
    }
}
