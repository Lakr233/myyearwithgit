//
//  RS0.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import Foundation
import SwiftUI

class ResultSection0: ResultSection {
    var reportHash: String = ""
    var clipDataItems: [Int: Int] = [:]

    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        clipDataItems = [:]
        // update the data

        reportHash = ""
        // dictionaries are unsorted
        // which means we do not considering it stable
        // so, we use some numbers inside them to do the calculate
        var hashSeedCounter: [UInt64] = []

        func countSeed(val: Int) {
            if let convertor = UInt64(exactly: val) {
                // fuck, i'm not caring about overflow anymore
                hashSeedCounter.append(convertor)
            }
        }
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                for diff in commit.diffFiles {
                    countSeed(val: diff.increasedLine)
                    countSeed(val: diff.decreasedLine)
                    countSeed(val: diff.emptyLineAdded)
                }
            }
        }

        let cal = Calendar.current
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                let date = commit.date
                if let day = cal.ordinality(of: .day, in: .year, for: date) {
                    clipDataItems[day, default: 0] += 1
                    countSeed(val: day * 114_514)
                }
            }
        }
        print("calendar result: \(clipDataItems)")

        // no more overflow on big numbers!
        reportHash = hashSeedCounter
            .sorted()
            .map { String($0) }
            .joined(separator: "")
            .sha256
            .uppercase

        while reportHash.count > 16 {
            reportHash.removeFirst()
        }
        print("generated report hash 0x\(reportHash)")

        return nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            clipData: clipDataItems,
            reportHash: reportHash,
            animated: true
        ))
    }

    func makeScreenShotView() -> AnyView {
        AnyView(AssociatedView(
            clipData: clipDataItems,
            reportHash: reportHash,
            animated: false
        ))
    }

    struct AssociatedView: View {
        let clipData: [Int: Int]
        let reportHash: String
        let animated: Bool

        @State var isInPresentation: Bool = false

        var body: some View {
            GeometryReader { r in
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(NSColor.textBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                    container
                        .padding(25)
                        .frame(
                            width: r.size.width,
                            height: r.size.height,
                            alignment: .center
                        )
                }
                .frame(
                    width: r.size.width,
                    height: r.size.height,
                    alignment: .center
                )
            }
        }

        var container: some View {
            HStack {
                CodeTiles(commits: clipData, animated: animated)
                rightContainer
            }
        }

        var rightContainer: some View {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                let name = User.current.namespace
                if name.count > 0 {
                    Text("\(String(requiredYear)) 年 x \(name)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                } else {
                    Text("\(String(requiredYear)) 年")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Text("我和我的代码，还有这一年。")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                Divider()
                Text("校验码: 0x\(reportHash.uppercase)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .opacity(0.5)
                Spacer()
            }
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Image("git")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
            )
            .padding()
        }
    }
}
