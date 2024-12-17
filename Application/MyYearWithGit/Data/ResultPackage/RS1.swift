//
//  RS1.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

private let calender = Calendar.current

class ResultSection1: ResultSection {
    var totalCommit: Int = 0
    var commitIncreaseLine: Int = 0
    var commitDecreaseLine: Int = 0
    var totalCommitDay: Int = 0

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        totalCommit = scannerResult
            .repoResult
            .repos
            .map(\.commits.count)
            .reduce(0, +)
        commitIncreaseLine = 0
        commitDecreaseLine = 0
        var commitDay = Set<Int>() // day of the year
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                commitIncreaseLine += commit
                    .diffFiles
                    .map(\.increasedLine)
                    .reduce(0, +)
                commitDecreaseLine += commit
                    .diffFiles
                    .map(\.decreasedLine)
                    .reduce(0, +)
                if let day = calender.ordinality(of: .day, in: .year, for: commit.date) {
                    commitDay.insert(day)
                }
            }
        }
        totalCommitDay = commitDay.count

        return totoalCommitToDesc(totalCommit: totalCommit, totoalAdd: commitIncreaseLine)
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            totalCommit: totalCommit,
            commitIncreaseLine: commitIncreaseLine,
            commitDecreaseLine: commitDecreaseLine,
            totalCommitDay: totalCommitDay
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let totalCommit: Int
        let commitIncreaseLine: Int
        let commitDecreaseLine: Int
        let totalCommitDay: Int

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
                Group {
                    Text("在 \(String(requiredYear)) 年")
                        .frame(height: preferredContentHeight)
                    Text("\(makeYearDescription()) 是我今年的代言词。")
                        .frame(height: preferredContentHeight)
                }

                Group {
                    Spacer()
                        .frame(height: 20)
                    Text("这一年里，我总共进行了 \(makeBigNumber(totalCommit)) 次代码提交。")
                        .frame(height: preferredContentHeight)
                    Text("感谢我的仓库们，他们记录着我生活的点点滴滴。")
                        .frame(height: preferredContentHeight)
                }

                Group {
                    Spacer()
                        .frame(height: 20)
                    Text("提交记录告诉咱：")
                        .frame(height: preferredContentHeight)
                    Text("仓库因你增添了 \(makeAdd(commitIncreaseLine)) 行代码，也减去了 \(makeDelete(commitDecreaseLine)) 行的重量。")
                        .frame(height: preferredContentHeight)
                }

                Group {
                    Spacer()
                        .frame(height: 20)
                    if totalCommit < 0 {
                        Text("回过头来看看这一年，咱一共活跃了 \(makeBigNumber(totalCommitDay)) 天。")
                            .frame(height: preferredContentHeight)
                        Text("黑客是我的外号，我总能找到属于我的 🚩! 是 🏳️‍⚧️ 还是 🏳️‍🌈 呢？")
                            .frame(height: preferredContentHeight)
                    } else if totalCommit > 1000 {
                        Text("这一年，咱一共卷了 \(makeBigNumber(totalCommitDay)) 天。")
                            .frame(height: preferredContentHeight)
                        Text("风雨兼程，目的地是我向往的星辰大海。🥺")
                            .frame(height: preferredContentHeight)
                    } else if totalCommit > 365 {
                        Text("回过头来看看这一年，似乎付出了不少。咱一共活跃了 \(makeBigNumber(totalCommitDay)) 天。")
                            .frame(height: preferredContentHeight)
                        Text("如果说代码是有温度的字符，那仓库便是咱的小太阳～ 🤫")
                            .frame(height: preferredContentHeight)
                    } else if totalCommit > 50 {
                        Text("回过头来看看这一年，咱一共活跃了 \(makeBigNumber(totalCommitDay)) 天。")
                            .frame(height: preferredContentHeight)
                        Text("星星有月亮，代码回家有仓库，而你有我相伴。😛")
                            .frame(height: preferredContentHeight)
                    } else {
                        Text("回过头来看看这一年，咱一共活跃了 \(makeBigNumber(totalCommitDay)) 天。")
                            .frame(height: preferredContentHeight)
                        Text("他们说多少不重要，因为我的提交，每一次都心意满满。😮")
                    }
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
                .foregroundColor(Color.blue)
        }

        func makeAdd(_ number: Int) -> Text {
            Text(" \(number) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(.green)
        }

        func makeDelete(_ number: Int) -> Text {
            Text(" \(number) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(.red)
        }

        func makeYearDescription() -> Text {
            Text(
                totoalCommitToDesc(
                    totalCommit: totalCommit,
                    totoalAdd: commitIncreaseLine
                )
                .achievement
                .name
            )
            .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
        }
    }
}

private func totoalCommitToDesc(totalCommit: Int, totoalAdd: Int) -> ResultSectionUpdateRecipe {
    if totalCommit < 0 {
        return .init(achievement: .init(
            name: "flag{Hack_m3_1n_th3_b0x!}",
            describe: NSLocalizedString("提交的次数为负数", comment: "")
        ))
    }
    if totalCommit == 0 {
        return .init(achievement: .init(
            name: NSLocalizedString("我也不知道你来这里干什么", comment: ""),
            describe: NSLocalizedString("今年没有写代码", comment: "")
        ))
    }
    if totalCommit == 1 {
        return .init(achievement: .init(
            name: NSLocalizedString("签到不是胡闹", comment: ""),
            describe: NSLocalizedString("今年有且只有一次提交", comment: "")
        ))
    }
    let score = totalCommit * 10 + totoalAdd
    if (0 ... 500).contains(score) {
        return .init(achievement: .init(
            name: NSLocalizedString("休养生息", comment: ""),
            describe: NSLocalizedString("有一些提交", comment: "")
        ))
    }
    if (500 ... 1000).contains(score) {
        return .init(achievement: .init(
            name: NSLocalizedString("小试牛刀", comment: ""),
            describe: NSLocalizedString("有一些些提交", comment: "")
        ))
    }
    if (1000 ... 10000).contains(score) {
        return .init(achievement: .init(
            name: NSLocalizedString("勤劳努力", comment: ""),
            describe: NSLocalizedString("有很多提交", comment: "")
        ))
    }
    if (10000 ... 100_000).contains(score) {
        return .init(achievement: .init(
            name: NSLocalizedString("发奋图强", comment: ""),
            describe: NSLocalizedString("有很多很多很多很多的提交", comment: "")
        ))
    }
    return .init(achievement: .init(
        name: NSLocalizedString("卷卷卷卷卷卷", comment: ""),
        describe: NSLocalizedString("我是卷王王中王本王", comment: "")
    ))
}
