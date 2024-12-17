//
//  RS3.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

private let calender = Calendar.current

class ResultSection3: ResultSection {
    var commitDateInDay: CommitDateInDay = .midnight
    var commitDateInDayCount: Int = 0
    var averageCommitPerDay: Double = 0
    var averageCommitPerWeekday: Double = 0
    var weekendCommitCount: Int = 0

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        var counter = [CommitDateInDay: Int]()
        var totalCounter = 0
        var weekendCounter: Set<Int> = []
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                totalCounter += 1
                let date = commit.date
                do {
                    if isDateWeekend(date, with: calender) {
                        if let dayOfYear = calender.ordinality(of: .day, in: .year, for: commit.date) {
                            weekendCounter.insert(dayOfYear)
                        }
                    }
                }
                do {
                    let components = calender.dateComponents([.hour], from: date)
                    guard let hour = components.hour else {
                        continue
                    }
                    let object = CommitDateInDay.convertFrom(hour: hour)
                    counter[object, default: 0] += 1
                }
            }
        }
        averageCommitPerDay = Double(totalCounter) / 365 // no need to be that actuate
        averageCommitPerWeekday = Double(totalCounter) / 261 // google telling me 261 working days lol
        weekendCommitCount = weekendCounter.count
        var mostUsed = CommitDateInDay.midnight
        var mostUsedCount = -1
        for key in counter.keys {
            let count = counter[key, default: 0]
            if count > mostUsedCount {
                mostUsed = key
                mostUsedCount = count
            }
        }
        commitDateInDay = mostUsed
        commitDateInDayCount = mostUsedCount

        switch commitDateInDay {
        case .midnight:
            return .init(achievement: .init(
                name: NSLocalizedString("夜猫子", comment: ""),
                describe: NSLocalizedString("喜欢在午夜时分提交代码", comment: "")
            ))
        case .morning:
            return .init(achievement: .init(
                name: NSLocalizedString("早睡早起身体好", comment: ""),
                describe: NSLocalizedString("喜欢在早晨提交代码", comment: "")
            ))
        case .noon:
            return .init(achievement: .init(
                name: NSLocalizedString("干饭人！干饭魂！", comment: ""),
                describe: NSLocalizedString("喜欢在中午提交代码", comment: "")
            ))
        case .afternoon:
            return .init(achievement: .init(
                name: NSLocalizedString("星爸爸和气氛组的关怀", comment: ""),
                describe: NSLocalizedString("喜欢在下午茶时间提交代码", comment: "")
            ))
        case .dinner:
            return .init(achievement: .init(
                name: NSLocalizedString("晚饭的吃好", comment: ""),
                describe: NSLocalizedString("喜欢在晚饭时间提交代码", comment: "")
            ))
        case .night:
            return .init(achievement: .init(
                name: NSLocalizedString("睡前故事", comment: ""),
                describe: NSLocalizedString("喜欢在晚上提交代码", comment: "")
            ))
        }
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            commitDateInDay: commitDateInDay,
            commitDateInDayCount: commitDateInDayCount,
            averageCommitPerDay: averageCommitPerDay,
            averageCommitPerWeekday: averageCommitPerWeekday,
            weekendCommitCount: weekendCommitCount
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let commitDateInDay: CommitDateInDay
        let commitDateInDayCount: Int
        let averageCommitPerDay: Double
        let averageCommitPerWeekday: Double
        let weekendCommitCount: Int

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
                    makeLarge(text: commitDateInDay.readableDescription())
                        .frame(height: preferredContentHeight)
                    Text("我最喜欢在 \(commitDateInDay.readableDescription()) 的时候提交代码，总共提交了 \(commitDateInDayCount) 次。")
                        .frame(height: preferredContentHeight)
                    Text("风雨兼程的 Coding 旅途，一天中我最忙碌的时段。")
                        .frame(height: preferredContentHeight)
                    Spacer()
                        .frame(height: 20)
                }
                Group {
                    Text("平均而言，我一天提交代码 \(makeBigNumber(averageCommitPerDay)) 次。")
                        .frame(height: preferredContentHeight)
                    Text("如果不计算周末的日子，则是 \(makeBigNumber(averageCommitPerWeekday)) 次。")
                        .frame(height: preferredContentHeight)
                    if averageCommitPerWeekday > 10 {
                        Text("我是卷王本王 🤪")
                            .frame(height: preferredContentHeight)
                    } else if averageCommitPerWeekday > 3 {
                        Text("辛苦啦 🥲")
                            .frame(height: preferredContentHeight)
                    } else {
                        Text("是的，我又在摸鱼 🥺")
                            .frame(height: preferredContentHeight)
                    }
                    Spacer()
                        .frame(height: 20)
                }

                Text("有 \(makeBigNumber(weekendCommitCount)) 个周末的日子，我在仓库留下了身影。")
                    .frame(height: preferredContentHeight)

                if weekendCommitCount > 0 {
                    if weekendCommitCount > 30 {
                        Text("修得的福报，是我一生最大的欢喜。")
                            .frame(height: preferredContentHeight)
                    } else if weekendCommitCount > 10 {
                        Text("可能敲代码，正是我的乐趣吧。")
                            .frame(height: preferredContentHeight)
                    }
                } else {
                    Text("这一年的周末，我都没有提交代码。")
                        .frame(height: preferredContentHeight)
                    Text("偷得浮生半日闲，可不能再修福报啦！")
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
                .foregroundColor(Color.blue)
        }

        func makeBigNumber(_ number: Double) -> Text {
            Text(" \(String(format: "%.4f", number)) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color.blue)
        }

        func makeLarge(text: String) -> Text {
            Text(text)
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(.orange)
        }
    }

    func isDateWeekend(_ date: Date, with calendar: Calendar) -> Bool {
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else {
            assertionFailure("Failed to extract weekday from date")
            return false
        }
        return ["Saturday", "Sunday"].contains(calendar.weekdaySymbols[weekday - 1])
    }
}
