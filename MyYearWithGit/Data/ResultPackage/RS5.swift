//
//  RS5.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

class ResultSection5: ResultSection {
    var emptyLineCount: Int = 0

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        emptyLineCount = 0
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                emptyLineCount += commit
                    .diffFiles
                    .map(\.emptyLineAdded)
                    .reduce(0, +)
            }
        }
        if emptyLineCount > 233_333 {
            return .init(achievement: .init(name: "摸鱼流量百分百", describe: "写了超过 233333 行空行"))
        }
        return nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            emptyLineCount: emptyLineCount
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let emptyLineCount: Int

        let preferredContextSize: CGFloat = 12
        let preferredContentHeight: CGFloat = 30

        var body: some View {
            Group {
                HStack {
                    container
                }
                .padding(50)
            }
        }

        var container: some View {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    Text("\(makeBigNumber(emptyLineCount))  行") // double space
                        .frame(height: preferredContentHeight)
                    Text("这是我今年写的空行的数量。空行，没错，就是只有空格或者什么都没有的那一行。")
                        .frame(height: preferredContentHeight)
                    Spacer()
                        .frame(height: 20)
                }
                Group {
                    if emptyLineCount < 1 {
                        Text("我从来不摸鱼，因为没有鱼给我摸。🐟")
                            .frame(height: preferredContentHeight)
                    } else if emptyLineCount < 1000 {
                        Text("空行能让我的代码变得好看，我很喜欢。")
                            .frame(height: preferredContentHeight)
                        Text("我想你也会很喜欢的，我如此说道，我如此和你说道。")
                            .frame(height: preferredContentHeight)
                    } else if emptyLineCount < 233_333 {
                        Text("人们说色即是空，空即是色。")
                            .frame(height: preferredContentHeight)
                        Text("我着实不能理解其中的含义。")
                            .frame(height: preferredContentHeight)
                    } else {
                        Text("天啦噜！我的摸鱼流量超过了 100TB 呢！")
                            .frame(height: preferredContentHeight)
                        Text("这相当于好几百只 🐳🐳🐳🐳🐳🐳 从我身边游过")
                            .frame(height: preferredContentHeight)
                    }
                }
                Group {
                    Text("你看到了吗，这一页，有 1010 行空行呢。")
                        .frame(height: preferredContentHeight)
                }
                Group {
                    Divider().hidden()
                }
            }
            .font(.system(size: preferredContextSize, weight: .semibold, design: .rounded))
        }

        func makeBigNumber(_ number: Int) -> Text {
            Text("\(number)")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color.pink)
        }

        func makeLarge(text: String) -> Text {
            Text(text)
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(.orange)
        }
    }
}
