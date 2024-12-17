//
//  ThanksView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import MarkdownUI
import SwiftUI

struct ThanksView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        SheetTemplate.makeSheet(
            title: "致谢",
            body: AnyView(container)
        ) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }

    var container: some View {
        ScrollView {
            Markdown {
                """
                **制作名单**

                此项目由 [标准件厂长@砍砍](https://twitter.com/Lakr233) 发起，设计，并完成撰写。

                与此同时，感谢 [Cyandev](https://twitter.com/unixzii) [拾一](https://twitter.com/__oquery) [82Flex](https://twitter.com/82flex) 与我一同前行。排名不分先后。

                **软件许可证**

                此项目使用了 [Octokit](https://github.com/nerdishbynature/octokit.swift) 与 [RequestKit](https://github.com/nerdishbynature/RequestKit.git) 来处理 GitHub 相关 Api，请参考他们的使用许可。

                此项目使用了来自 [Git](https://git-scm.com/downloads/logos) [GitHub](https://github.com/logos) [GitLab](https://about.gitlab.com/press/press-kit/) [Bitbucket](https://Bitbucket.org/) 的相关图标，请参考他们的使用许可。

                2021 冬，最后更新于 2024 年。
                """
            }
        }
    }
}
