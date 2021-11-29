//
//  ThanksView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

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
            if #available(macOS 12.0, *) {
                Text(
                    """
                    此项目由 [Lakr Aream](https://twitter.com/Lakr233) 发起，设计，并完成撰写。

                    与此同时，感谢 [Cyandev](https://twitter.com/unixzii) [拾一](https://twitter.com/__oquery) [82Flex](https://twitter.com/82flex) 与我一同前行。排名不分先后。

                    此项目使用了 [Octokit](https://github.com/nerdishbynature/octokit.swift) 与 [RequestKit](https://github.com/nerdishbynature/RequestKit.git) 来处理 GitHub 相关 Api，请参考他们的使用许可。

                    此项目使用了来自 [Git](https://git-scm.com/downloads/logos) [GitHub](https://github.com/logos) [GitLab](https://about.gitlab.com/press/press-kit/) [Bitbucket](https://Bitbucket.org/) 的相关图标，请参考他们的使用许可。

                    2021 冬
                    """
                )
            } else {
                Text(
                    """
                    此项目由 Lakr Aream (@Lakr233) 发起，设计，并完成撰写。

                    与此同时，感谢 Cyandev (@unixzii) 拾一 (@__oquery) 82Flex(@82flex) 与我一同前行。排名不分先后。

                    此项目使用了 Octokit (https://github.com/nerdishbynature/octokit.swift) 与 RequestKit (https://github.com/nerdishbynature/RequestKit.git) 来处理 GitHub 相关 Api，请参考他们的使用许可。

                    此项目使用了来自 https://unsplash.com/ 的图片，请参考他们的相关使用许可。

                    此项目使用了来自 https://git-scm.com/downloads/logos https://github.com/logos https://about.gitlab.com/press/press-kit/ 的相关图标，请参考他们的使用许可。

                    2021 冬
                    """
                )
            }
        }
    }
}
