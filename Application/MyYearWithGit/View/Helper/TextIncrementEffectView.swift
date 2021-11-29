//
//  TextIncrementEffectView.swift
//  MyYearWithGit
//
//  Created by Cyandev on 2021/11/28.
//

import SwiftUI

struct TextIncrementEffectView: View {
    let number: Int
    let timer = Timer
        .publish(every: 0.02, on: .main, in: .common)
        .autoconnect()

    @State var currentNumber = 0

    var body: some View {
        Group {
            Text("\(currentNumber)")
                .font(.system(size: 32, design: .rounded).bold())
        }
        .background(
            number == currentNumber ? nil : Color.clear
                .onReceive(timer) { _ in
                    let newNumber = Int(Double(currentNumber) + Double(number) / 80.0)
                    currentNumber = min(number, newNumber)
                }
        )
    }
}
