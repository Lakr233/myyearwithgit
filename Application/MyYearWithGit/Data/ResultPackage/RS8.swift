//
//  RS8.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/30.
//

import Foundation
import SwiftUI

class ResultSection8: ResultSection {
    func update(with _: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        nil
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let preferredContextSize: CGFloat = 12
        let preferredContentHeight: CGFloat = 30

        var body: some View {
            GeometryReader { r in
                ZStack {
                    VStack(alignment: .center, spacing: 15) {
                        Image("qrcode")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128, alignment: .center)
                        Divider()
                            .padding(.horizontal, 50)
                        VStack(spacing: 4) {
                            Text("扫码开启你的专属年度代码提交报告")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .opacity(0.5)
                            Text("© \(requiredYear) 标准件厂长@砍砍 & 他的朋友们")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .opacity(0.5)
                        }
                    }
                }
                .frame(width: r.size.width, height: r.size.height, alignment: .center)
            }
        }
    }
}
