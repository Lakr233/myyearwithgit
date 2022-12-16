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

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        mostUsedLanguage = nil
        howManyLine = 0
        otherUsedLanguages = []

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
            return .init(achievement: .init(name: "编程语言大师", describe: "今年的提交中熟练使用了超过六种语言"))
        }
        return nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            mostUsedLanguage: mostUsedLanguage,
            howManyLine: howManyLine,
            otherUsedLanguages: otherUsedLanguages
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let mostUsedLanguage: SourceLanguage?
        let howManyLine: Int
        let otherUsedLanguages: [SourceLanguage]

        let preferredContextSize: CGFloat = 12
        let preferredContentHeight: CGFloat = 30

        var body: some View {
            Group {
                container
                    .padding(50)
            }
        }

        var container: some View {
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

        func makeBigNumber(_ number: Int) -> Text {
            Text(" \(number) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color.orange)
        }
    }
}
