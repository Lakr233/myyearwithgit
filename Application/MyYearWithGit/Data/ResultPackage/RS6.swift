//
//  RS6.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

class ResultSection6: ResultSection {
    var specialDay: Int = 0
    var specialMonth: Int = 0
    var specialCount: Int = 0

    struct MonDayPair: Hashable {
        let mon: Int
        let day: Int
    }

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        var builder = [MonDayPair: Int]()
        let cal = Calendar.current
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                let date = commit.date
                if let mon = cal.ordinality(of: .month, in: .year, for: date),
                   let day = cal.ordinality(of: .day, in: .month, for: date)
                {
                    builder[MonDayPair(mon: mon, day: day), default: 0] += 1
                }
            }
        }
        specialMonth = 0
        specialDay = 0
        specialCount = 0
        if let nbDay = DicCounter.mostUsedKeyword(from: builder) {
            specialMonth = nbDay.0.mon
            specialDay = nbDay.0.day
            specialCount = nbDay.1
        }

        if specialCount > 50 {
            return .init(achievement: .init(name: "Bufeature 制造机", describe: "今年有一天的提交次数超过五十次"))
        } else if specialCount > 100 {
            return .init(achievement: .init(name: "我是奥特曼", describe: "今年有一天的提交次数超过百次"))
        }

        return nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            renderingPrint: false,
            specialDay: specialDay,
            specialMonth: specialMonth,
            specialCount: specialCount
        ))
    }

    func makeScreenShotView() -> AnyView {
        AnyView(AssociatedView(
            renderingPrint: true,
            specialDay: specialDay,
            specialMonth: specialMonth,
            specialCount: specialCount
        ))
    }

    struct AssociatedView: View {
        let renderingPrint: Bool

        let specialDay: Int
        let specialMonth: Int
        let specialCount: Int

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

        let weathers = [
            "sun.min",
            "sun.max",
            "sun.max.circle",
            "sunrise",
            "sunset",
            "sun.and.horizon",
            "sun.dust",
            "sun.haze",
            "moon",
            "moon.circle",
            "sparkles",
            "moon.stars",
            "cloud",
            "cloud.drizzle",
            "cloud.rain",
            "cloud.heavyrain",
            "cloud.fog",
            "cloud.hail",
            "cloud.snow",
            "cloud.sleet",
            "cloud.bolt",
            "cloud.bolt.rain",
            "cloud.sun",
            "cloud.sun.rain",
            "cloud.sun.bolt",
            "cloud.moon",
            "cloud.moon.rain",
            "cloud.moon.bolt",
            "smoke",
            "wind",
            "wind.snow",
            "snowflake",
            "snowflake.circle",
            "tornado",
            "tropicalstorm",
            "hurricane",
            "thermometer.sun",
            "thermometer.snowflake",
            "thermometer",
            "aqi.low",
            "aqi.medium",
            "aqi.high",
            "humidity",
        ]

        var container: some View {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    makeLarge(text: "\(specialMonth) 月 \(specialDay) 日")
                        .frame(height: preferredContentHeight)
                    Text("大概是很特别的一天。")
                        .frame(height: preferredContentHeight)
                    Spacer()
                        .frame(height: 20)
                }
                Group {
                    HStack {
                        if let iconList = makeIconList() {
                            ForEach(0 ..< iconList.count, id: \.self) { index in
                                if renderingPrint {
                                    makeImage(with: "custom.\(iconList[index])")
                                        .antialiased(true)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: preferredContextSize, height: preferredContextSize)
                                } else {
                                    Image("custom.\(iconList[index])")
                                        .renderingMode(.template)
                                        .antialiased(true)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: preferredContextSize, height: preferredContextSize)
                                        .foregroundColor(Color(NSColor.textColor))
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                }
                Group {
                    Text("在这短短的一天里，你一共提交了 \(makeBigNumber(specialCount)) 次代码。")
                        .frame(height: preferredContentHeight)
                    if specialCount > 233 {
                        Text("狗急了会跳墙，我急了会骂娘。一天这么多次的提交，肯定是有人被我骂得很惨吧。")
                            .frame(height: preferredContentHeight)
                    } else if specialCount > 80 {
                        Text("这一天，是忙碌的自己，没吃好，没睡好。")
                    } else if specialCount > 25 {
                        Text("我的 Bufeature 做好了吗？")
                            .frame(height: preferredContentHeight)
                        Text("Bufeature: <noun> bug feature, feature with bug.")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .opacity(0.5)
                    } else if specialCount > 10 {
                        Text("上串下跳的提交，是开心，是愉悦，还是害怕，或者担心呢？")
                            .frame(height: preferredContentHeight)
                    }
                }
                Group {
                    Divider().hidden()
                }
            }
            .font(.system(size: preferredContextSize, weight: .semibold, design: .rounded))
        }

        // so we can use if let to get it
        func makeIconList() -> [String]? {
            // no we don't use random
            let hash = "wiki.qaq.\(specialMonth).\(specialDay)".sha256
            let mod = 8
            var seed = [Character](hash)
                .map { Int(String($0)) }
                .compactMap(\.self)
                .reduce(0, +) % mod
            var result = [String]()
            while result.count < 16 {
                result.append(weathers[seed])
                seed += mod
                if seed >= weathers.count {
                    seed -= weathers.count
                }
            }
            return result
        }

        func makeBigNumber(_ number: Int) -> Text {
            Text(" \(number) ")
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color.orange)
        }

        func makeLarge(text: String) -> Text {
            Text(text)
                .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                .foregroundColor(Color(NSColor(red: 87 / 255, green: 86 / 255, blue: 206 / 255, alpha: 1)))
        }

        func makeImage(with: String) -> Image {
            let image = NSImage(named: with)
            let color = NSColor.textColor
            guard let imageTinted = image?.tint(color: color) else {
                return Image(systemName: "xmark")
            }
            return Image(nsImage: imageTinted)
        }
    }
}

private extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
