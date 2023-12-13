//
//  CommitFilterSheet.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/1.
//

import SwiftUI

struct FilterSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @State var inputText: String = ""
    @State var inputCase: CommitFileFilter.BlockType = .nameKeyWord

    @State var blockList: [CommitFileFilter.BlockItem] = []

    var body: some View {
        SheetTemplate.makeSheet(title: "排除列表",
                                body: AnyView(sheet))
        { confirmed in
            debugPrint("sheet completed \(confirmed)")
            presentationMode.wrappedValue.dismiss()
        }
    }

    var sheet: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
                """
                若要忽略指定的文件，请在此处填写。
                我们将会传入提交文件的相对路径与你的排除项逐一进行匹配。
                若有一项满足，则该文件不会被记入。此次提交的其他文件仍会进行统计。
                """
            )
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            HStack {
                TextField("在这里输入表达式", text: $inputText)
                Picker("过滤器", selection: $inputCase) {
                    ForEach(CommitFileFilter.BlockType.allCases, id: \.self) { val in
                        Text(val.readableDescription())
                    }
                }
                Button {
                    blockList.append(.init(type: inputCase, value: inputText))
                    inputText = ""
                } label: {
                    Text("添加")
                }
                .disabled(inputText.count < 1)
            }
            ScrollView {
                ForEach(0 ..< blockList.count, id: \.self) { index in
                    HStack {
                        Text("\(blockList[index].value) - \(blockList[index].type.readableDescription())")
                        Spacer()
                        Button {
                            blockList.remove(at: index)
                        } label: {
                            Text("删除")
                        }
                    }
                }
                .padding(10)
            }
            .padding(-10)
        }
        .onAppear {
            blockList = CommitFileFilter.shared.commitBlockList
        }
        .onChange(of: blockList) { newValue in
            CommitFileFilter.shared.commitBlockList = newValue
        }
    }
}
