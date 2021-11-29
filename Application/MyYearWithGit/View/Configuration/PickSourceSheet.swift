//
//  SourceSelection.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

extension Notification.Name {
    static let openSheet = Notification.Name("wiki.qaq.mywg.open.sheet")
}

struct PickSourceSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var pickerData: SourceRegisters = .local

    var body: some View {
        SheetTemplate.makeSheet(
            title: "天才第一步",
            body: AnyView(container)
        ) { confirmed in
            debugPrint("sheet completed \(confirmed)")
            if confirmed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openSheet, object: pickerData)
                }
            }
            presentationMode.wrappedValue.dismiss()
        }
    }

    var container: some View {
        VStack(alignment: .leading) {
            Text("请选择一个需要分析的仓库的来源，我们将在稍后填写具体信息。")
                .font(.system(size: 12, weight: .regular, design: .rounded))
            Picker(">>", selection: $pickerData) {
                ForEach(SourceRegisters.allCases, id: \.self) { val in
                    Text(val.readableDescription())
                }
            }
        }
    }
}
