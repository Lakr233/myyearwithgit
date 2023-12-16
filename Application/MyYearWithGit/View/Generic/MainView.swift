//
//  MainView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import ColorfulX
import SwiftUI

private let imageSize: CGFloat = 12

private let mainTitleTextList = [
    "我和我的代码，还有这一年。",
] + [
    #"""print("Hello World")"""#, // Python
    #"""System.out.println("Hello World");"""#, // Java
    #"""printf("Hello World\n");"""#, // C
    #"""std::cout << "Hello World" << std::endl;"""#, // C++
    #"""console.log("Hello World");"""#, // JavaScript
    #"""puts "Hello World""""#, // Ruby
    #"""<?php echo "Hello World"; ?>"""#, // PHP
    #"""print("Hello World")"""#, // Swift
    #"""fmt.Println("Hello World")"""#, // Go
    #"""Console.WriteLine("Hello World");"""#, // C#
]
.shuffled()

private let lightColorfulTheme: [ColorfulPreset] = [
    .spring, .winter,
]
private let darkColorfulTheme: [ColorfulPreset] = [
    .aurora, .starry, .jelly, .lavandula, .summer,
]

struct MainView: View {
    @State var colors: [Color] = []
    @State var openMainSheet: Bool = false
    @State var openThankSheet: Bool = false
    @Environment(\.colorScheme) var colorScheme

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        content
            .padding(60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                VStack {
                    Spacer()
                    Text("Made with love by @Lakr233")
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .opacity(0.5)
                        .padding()
                        .onTapGesture {
                            NSWorkspace.shared.open(URL(string: "https://twitter.com/Lakr233")!)
                        }
                        .makeHoverPointer()
                }
            )
            .background(
                ColorfulView(color: $colors)
                    .ignoresSafeArea()
                    .onChange(of: colorScheme) { _ in
                        updateColorScheme()
                    }
                    .onReceive(timer) { _ in
                        updateColorScheme()
                    }
                    .onAppear { updateColorScheme() }
            )
            .sheet(isPresented: $openMainSheet) {} content: {
                MainSheet()
                    .frame(
                        width: preferredApplicationSize.width * 0.8,
                        height: preferredApplicationSize.height * 0.8,
                        alignment: .center
                    )
            }
            .sheet(isPresented: $openThankSheet) {} content: {
                ThanksView()
                    .frame(
                        width: preferredApplicationSize.width * 0.8,
                        height: preferredApplicationSize.height * 0.8,
                        alignment: .center
                    )
            }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
                .frame(height: 80)
            TextTypeEffectView(
                size: preferredTitleSize,
                textList: mainTitleTextList
            )
            .frame(height: 60)
            HStack {
                Button {
                    openMainSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("开启我的年度报告")
                    }
                }
                Button {
                    openThankSheet.toggle()
                } label: {
                    HStack {
                        Text("致谢")
                    }
                }
                #if DEBUG
                    Button {
                        NotificationCenter.default.post(
                            name: .analysisComlete,
                            object: ResultPackage()
                        )
                    } label: {
                        HStack {
                            Text("任意门")
                                .foregroundColor(.orange)
                        }
                    }
                #endif
            }
            Divider().hidden()
            sourceLink
        }
    }

    var sourceLink: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("此年度报告支持以下数据源")
                .font(.system(size: imageSize, weight: .regular, design: .rounded))
            HStack {
                makeIconImage(with: "git")
                Text("Git")
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://git-scm.com/")!)
            }
            HStack {
                makeIconImage(with: "gitlab")
                Text("GitLab")
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://gitlab.com/")!)
            }
            HStack {
                makeIconImage(with: "github")
                Text("GitHub")
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://github.com/")!)
            }
            HStack {
                makeIconImage(with: "bitbucket")
                Text("Bitbucket")
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://Bitbucket.org/")!)
            }
        }
    }

    func makeIconImage(with: String) -> some View {
        Image(with)
            .resizable()
            .antialiased(true)
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize, alignment: .center)
    }

    func updateColorScheme() {
        let candidates: [ColorfulPreset] = colorScheme == .light ? lightColorfulTheme : darkColorfulTheme
        guard let c = candidates.randomElement() else { return }
        colors = c.colors
    }
}
