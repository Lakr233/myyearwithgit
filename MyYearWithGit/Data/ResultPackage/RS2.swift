//
//  RS2.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

class ResultSection2: ResultSection {
    var mostUsedLanguage: SourceLanguage?
    var howManyLine: Int = 0
    var otherUsedLanguages: [SourceLanguage] = []
    var languageStats: [(language: SourceLanguage, lines: Int)] = [] // 新增：所有语言统计

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        mostUsedLanguage = nil
        howManyLine = 0
        otherUsedLanguages = []
        languageStats = [] // 重置统计数据

        var languageBuilder: [SourceLanguage: Int] = [:]
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                for file in commit.diffFiles {
                    if let language = file.language {
                        // count add only
                        languageBuilder[language, default: 0] += file.increasedLine
                    }
                }
            }
        }
        
        // 按行数从高到低排序所有语言
        languageStats = languageBuilder.map { (language: $0.key, lines: $0.value) }
            .sorted { $0.lines > $1.lines }
        
        var mostUsed: SourceLanguage?
        var mostUsedCount: Int = -1
        for key in languageBuilder.keys {
            let count = languageBuilder[key, default: 0]
            // if contain multiple result, first come first use
            if count > mostUsedCount {
                mostUsed = key
                mostUsedCount = count
            }
        }

        if let mostUsed {
            mostUsedLanguage = mostUsed
            howManyLine = mostUsedCount

            // don't count those tiny things
            // required at lease 0.05 percent of most used
            // so if a guy write 1000 line of code, then 5 line of other is required
            // or, if 128 line is written, then check!
            for key in languageBuilder.keys where key != mostUsed {
                let count = languageBuilder[key, default: 0]
                if count > Int(Double(howManyLine) * 0.05) || count > 128 {
                    otherUsedLanguages.append(key)
                }
            }
        }

        if otherUsedLanguages.count + 1 >= 6 {
            return .init(achievement: .init(
                name: NSLocalizedString("编程语言大师", comment: ""),
                describe: NSLocalizedString("今年的提交中熟练使用了超过六种语言", comment: "")
            )
            )
        }
        return nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            mostUsedLanguage: mostUsedLanguage,
            howManyLine: howManyLine,
            otherUsedLanguages: otherUsedLanguages,
            languageStats: languageStats // 传递统计数据
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let mostUsedLanguage: SourceLanguage?
        let howManyLine: Int
        let otherUsedLanguages: [SourceLanguage]
        let languageStats: [(language: SourceLanguage, lines: Int)] // 新增参数

        let preferredContextSize: CGFloat = 12
        let preferredContentHeight: CGFloat = 30

        var body: some View {
            Group {
                container
                    .padding(50)
            }
        }

        var container: some View {
            HStack(alignment: .top, spacing: 30) {
                // 左侧：文字描述
                textContent
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 右侧：柱状图
                if !languageStats.isEmpty {
                    chartContent
                        .frame(width: 200)
                }
            }
        }
        
        var textContent: some View {
            VStack(alignment: .leading, spacing: 0) {
                if let mostUsedLanguage {
                    Group {
                        Text(mostUsedLanguage.readableDescription())
                            .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                            .frame(height: preferredContentHeight)
                        Text("这是我最常用的语言。")
                            .frame(height: preferredContentHeight)
                    }
                    Group {
                        Spacer()
                            .frame(height: 20)
                        Text("在这一年里，我使用这门语言提交了 \(makeBigNumber(howManyLine)) 行代码。")
                            .frame(height: preferredContentHeight)
                        Text("他是我最好的伙伴。")
                    }

                    Group {
                        if otherUsedLanguages.count > 0 {
                            Spacer()
                                .frame(height: 20)
                            Text("在剩余的时光里，")
                                .frame(height: preferredContentHeight)
                            Text(
                                otherUsedLanguages
                                    .map { $0.readableDescription() }
                                    .shuffled()
                                    .joined(separator: ",  ")
                            )
                            .font(.system(size: preferredContextSize * 1.2, weight: .semibold, design: .rounded))
                            .foregroundColor(.purple)
                            Text("他们也陪我走过一段旅程。")
                                .frame(height: preferredContentHeight)
                        } else {
                            Spacer()
                                .frame(height: 20)
                            Text("我很专一，没有使用过其他的语言。")
                                .frame(height: preferredContentHeight)
                        }
                    }

                    Group {
                        if otherUsedLanguages.count > 6 {
                            Spacer()
                                .frame(height: 20)
                            Text("语言大师的称号，非你莫属！")
                        }
                    }

                } else {
                    Text("我不知道你写了什么")
                        .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                        .frame(height: preferredContentHeight)
                    Text("应该是太冷门了吧，数据库里找不到对应的语言。🥲")
                        .frame(height: preferredContentHeight)
                }

                Group {
                    Divider()
                        .hidden()
                }
            }
            .font(.system(size: preferredContextSize, weight: .semibold, design: .rounded))
        }
        
        // 新增：柱状图视图
        var chartContent: some View {
            VStack(alignment: .leading, spacing: 8) {
                // 获取最大值用于计算比例
                let maxLines = languageStats.first?.lines ?? 1
                
                // 显示前8种语言（如果有的话）
                ForEach(Array(languageStats.prefix(8).enumerated()), id: \.element.language) { index, stat in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(stat.language.readableDescription())
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .frame(width: 60, alignment: .leading)
                                .lineLimit(1)
                            
                            Text("\(stat.lines)")
                                .font(.system(size: 8, weight: .regular, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        // 横向柱状条
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景条
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geometry.size.width, height: 12)
                                
                                // 数据条
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                getColorForIndex(index),
                                                getColorForIndex(index).opacity(0.7)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * CGFloat(stat.lines) / CGFloat(maxLines),
                                        height: 12
                                    )
                            }
                        }
                        .frame(height: 12)
                    }
                }
                
                if languageStats.count > 8 {
                    Text("还有 \(languageStats.count - 8) 种语言...")
                        .font(.system(size: 8, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        
        // 为不同的柱状条分配颜色
        func getColorForIndex(_ index: Int) -> Color {
            let colors: [Color] = [
                .blue, .green, .orange, .purple, .pink, .red, .yellow, .cyan
            ]
            return colors[index % colors.count]
        }

        func makeBigNumber(_ number: Int) -> Text {
            Text(" \(number) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color.orange)
        }
    }
}
