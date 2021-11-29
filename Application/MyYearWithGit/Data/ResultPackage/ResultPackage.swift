//
//  ResultPackage.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Foundation

class ResultPackage {
    var representedData: DataSource

    init() {
        representedData = .init(
            repoResult: .init(repos: []),
            dictionaryIncrease: [:],
            dictionaryDecrease: [:],
            dictionaryCommit: [:]
        )
    }

    init(data: DataSource) {
        representedData = data
    }

    struct DataSource: Codable {
        let repoResult: RepoAnalyser.FinalReportCodeable
        let dictionaryIncrease: [String: Int]
        let dictionaryDecrease: [String: Int]
        let dictionaryCommit: [String: Int]
    }

    var badgeEarned = [ResultSectionUpdateRecipe]()

    let resultSections: [ResultSection] = [
        // put all sections here
        ResultSection0(),
        ResultSection1(),
        ResultSection2(),
        ResultSection3(),
        ResultSection4(),
        ResultSection5(),
        ResultSection6(),
        ResultSection7(),
        ResultSection8(),
    ]

    func update() {
        badgeEarned = resultSections
            .map { $0.update(with: representedData) }
            .compactMap { $0 }
        resultSections
            .forEach { section in
                if let object = section as? ResultSectionBadgeData {
                    object.setBadge(badgeEarned)
                }
            }
    }

    func update(with scannerPackage: DataSource) {
        representedData = scannerPackage
        update()
    }
}
