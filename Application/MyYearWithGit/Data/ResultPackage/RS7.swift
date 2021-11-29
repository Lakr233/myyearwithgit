//
//  RS7.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation
import SwiftUI

class ResultSection7: ResultSection, ResultSectionBadgeData {
    var badgeElements: [ResultSectionUpdateRecipe] = []

    func update(with _: ResultPackage.DataSource) -> (ResultSectionUpdateRecipe)? {
        nil
    }

    func setBadge(_ items: [ResultSectionUpdateRecipe]) {
        badgeElements = items
    }

    func makeView() -> AnyView {
        AnyView(AssociatedView(
            badgeElements: badgeElements
        ))
    }

    func makeScreenShotView() -> AnyView {
        makeView()
    }

    struct AssociatedView: View {
        let badgeElements: [ResultSectionUpdateRecipe]

        let preferredContextSize: CGFloat = 12
        let preferredContentHeight: CGFloat = 30

        var body: some View {
            Group {
                HStack {
                    container
                }
                .padding(50)
            }
            .background(
                HStack {
                    Spacer()
                    Image("badge")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 340)
                        .rotationEffect(Angle(degrees: -90))
                        .opacity(0.8)
                        .offset(x: 24, y: 0)
//                        .clipped()
                }
            )
        }

        var container: some View {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    Text("成就墙")
                        .foregroundColor(Color(NSColor(red: 89 / 255, green: 196 / 255, blue: 189 / 255, alpha: 1)))
                        .font(.system(size: preferredContextSize * 2, weight: .semibold, design: .rounded))
                    Spacer()
                        .frame(height: 20)
                    Text("今年，我获得了不少成就。下面是我愿意和你分享的一些。")
                        .frame(height: preferredContentHeight)
                }
                Spacer()
                    .frame(height: 20)

                Group {
                    ForEach(0 ..< badgeElements.count, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image("custom.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 6, height: 6)
                                    Text("\(badgeElements[index].achievement.name)")
                                        .font(.system(size: preferredContextSize, weight: .semibold, design: .rounded))
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                        .frame(width: 16, height: 0)
                                    Text("\(badgeElements[index].achievement.describe)")
                                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                                        .opacity(0.5)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Group {
                    Divider().hidden()
                }
            }
            .font(.system(size: preferredContextSize, weight: .semibold, design: .rounded))
        }
    }
}
