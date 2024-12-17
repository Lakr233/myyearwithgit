//
//  CodeTiles.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import SwiftUI

struct CodeTiles: View {
    // day of the year -> commit counts
    let commits: [Int: Int]

    init(commits: [Int: Int], animated: Bool = true) {
        self.commits = commits
        print("total commits: \(commits.values.reduce(0, +))")
        if animated {
            _displayCommit = State<[Int: Int]>(initialValue: [:])
        } else {
            _displayCommit = State<[Int: Int]>(initialValue: commits)
        }
    }

    let size: CGFloat = 14

    @State var currentLighter = 0
    @State var displayCommit: [Int: Int]

    let timer = Timer
        .publish(every: 0.01, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: size, maximum: size), spacing: 1),
            ],
            alignment: .leading,
            spacing: 1
        ) {
            ForEach(1 ..< 365) { index in
                Rectangle()
                    .foregroundColor(obtainColor(for: index))
                    .frame(width: size, height: size)
                    .animation(.interactiveSpring(), value: displayCommit)
            }
        }
        .frame(width: 14 * (size + 1))
        .onReceive(timer) { _ in
            if currentLighter > 400 { // for robust
                return
            }
            repeat {
//                print("timer load \(currentLighter) \(commits[currentLighter, default: 0])")
                displayCommit[currentLighter] = commits[currentLighter, default: 0]
                currentLighter += 1
            } while commits[currentLighter, default: 0] == 0 && currentLighter < 400
        }
    }

    // MARK: if color goes wrong, check here, pass index not commit count

    func obtainColor(for index: Int) -> Color {
        let commitCount = displayCommit[index] ?? 0
        var opacity = 0.05
        if commitCount > 0 {
            opacity = 0.2
        }
        opacity += CGFloat(commitCount) * 0.2
        if opacity > 1 {
            opacity = 1
        }
        return Color(
            #colorLiteral(red: 0.7458761334, green: 0.7851135731, blue: 0.9899476171, alpha: 1)
        )
        .opacity(opacity)
    }
}
