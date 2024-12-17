//
//  TextTypeEffectView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import SwiftUI

struct TextTypeEffectView: View {
    let size: CGFloat
    let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()

    let textList: [String]

    @State var displayText: String = ""

    @State var currentText: String = ""
    @State var currentIndex = -1
    @State var currentArray: String = ""
    @State var switchAwaitControl: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().hidden()
            if #available(macOS 13.0, *) {
                Text(displayText)
                    .font(.system(size: preferredTitleSize, weight: .semibold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.interactiveSpring, value: displayText)
            } else {
                Text(displayText)
                    .font(.system(size: preferredTitleSize, weight: .semibold, design: .rounded))
                    .animation(.interactiveSpring, value: displayText)
            }
            Divider().hidden()
        }
        .onReceive(timer) { _ in
            if switchAwaitControl > 0 {
                switchAwaitControl -= 1
                return
            }
            // if nothing to append to currentText
            if currentArray.count < 1 {
                // check if we are able to move the index to next
                currentIndex += 1
                // overflow! reset!
                if currentIndex >= textList.count {
                    currentIndex = 0
                }
                // list is empty?
                if currentIndex >= textList.count || currentIndex < 0 {
                    // nothing available
                    return
                }
                // move the payload to updated texts
                currentText = ""
                currentArray = textList[currentIndex]
            }
            if currentArray.count < 1 {
                // what? empty string here
                return
            }
            // now append it!
            currentText.append(currentArray.removeFirst())
            if currentArray.count == 0 {
                // wait around 1 second before switch to next text
                switchAwaitControl += 10
            }
        }
        .onChange(of: currentText) { newValue in
            displayText = newValue + "_"
        }
    }
}
