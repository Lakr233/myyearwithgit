//
//  ContentView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import Colorful
import SwiftUI

private let imageSize: CGFloat = 12

private let mainTitleTextList = [
    "我和我的代码，还有这一年。",
] + [
    "剑指天下，秋收 [Offer]",
    "半夜奋笔疾码，云相伴，”乐“相随。",
    "git push --force # 🐶",
    "debugPrint(\"Hello World!\")",
    "vivo mian() { }；",
].shuffled()

struct MainView: View {
    @State var openMainSheet: Bool = false

    @State var openThankSheet: Bool = false

    var body: some View {
        GeometryReader { _ in
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
            .padding(60)
        }
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
            ColorfulView(colorCount: 64)
                .opacity(0.25)
                .background(Color(NSColor.textBackgroundColor))
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

    var sourceLink: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("此年度报告支持以下数据源")
                .font(.system(size: imageSize, weight: .regular, design: .rounded))
            HStack {
                makeIconImage(with: "git")
                Text("Git")
                    .foregroundColor(.blue)
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://git-scm.com/")!)
            }
            HStack {
                makeIconImage(with: "gitlab")
                Text("GitLab")
                    .foregroundColor(.blue)
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://gitlab.com/")!)
            }
            HStack {
                makeIconImage(with: "github")
                Text("GitHub")
                    .foregroundColor(.blue)
                    .font(.system(size: imageSize, weight: .regular, design: .rounded))
            }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://github.com/")!)
            }
            HStack {
                makeIconImage(with: "bitbucket")
                Text("Bitbucket")
                    .foregroundColor(.blue)
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
}
