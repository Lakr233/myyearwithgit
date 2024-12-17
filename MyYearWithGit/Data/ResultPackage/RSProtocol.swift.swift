//
//  RSProtocol.swift.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import SwiftUI

extension Notification.Name {
    static let resultContextSwitch = Notification.Name("wiki.qaq.result.context.switch")
}

struct ResultSectionUpdateRecipe {
    let achievement: Achievement
    struct Achievement: Codable {
        let name: String
        let describe: String
    }
}

protocol ResultSection {
    // get any badge if have
    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe?
    func makeView() -> AnyView
    func makeScreenShotView() -> AnyView
}

protocol ResultSectionBadgeData {
    func setBadge(_: [ResultSectionUpdateRecipe])
}

enum CommitDateInDay: String, HumanReadable {
    case midnight // 0:00 <-> 5:00
    case morning // 5:00 <-> 10:00
    case noon // 10:00 <-> 14:00
    case afternoon // 14:00 <-> 17:00
    case dinner // 17:00 <-> 19:00
    case night // 19:00 <-> 24:00

    func readableDescription() -> String {
        switch self {
        case .midnight: // 0:00 <-> 5:00
            NSLocalizedString("凌晨", comment: "")
        case .morning: // 5:00 <-> 10:00
            NSLocalizedString("早晨", comment: "")
        case .noon: // 10:00 <-> 14:00
            NSLocalizedString("中午", comment: "")
        case .afternoon: // 14:00 <-> 17:00
            NSLocalizedString("下午", comment: "")
        case .dinner: // 17:00 <-> 19:00
            NSLocalizedString("晚餐时间", comment: "")
        case .night: // 19:00 <-> 24:00
            NSLocalizedString("晚上", comment: "")
        }
    }

    static func convertFrom(hour: Int) -> Self {
        if (0 ..< 5).contains(hour) {
            return .midnight
        }
        if (5 ..< 10).contains(hour) {
            return .morning
        }
        if (10 ..< 14).contains(hour) {
            return .noon
        }
        if (14 ..< 17).contains(hour) {
            return .afternoon
        }
        if (17 ..< 19).contains(hour) {
            return .dinner
        }
        return .night
    }
}
