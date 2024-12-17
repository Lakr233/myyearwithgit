//
//  SourceRegister.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import Foundation

enum SourceRegisters: String, CaseIterable, Codable, HumanReadable {
    // MARK: CASE

    case local
    case github
    case gitlab
    case bitbucket

    // MARK: PROTOCOL

    func readableDescription() -> String {
        switch self {
        case .local:
            NSLocalizedString("本地仓库", comment: "")
        case .github:
            "GitHub"
        case .gitlab:
            "GitLab"
        case .bitbucket:
            "Bitbucket"
        }
    }
}

struct SourceRegistrationData: Codable, Identifiable, Hashable {
    var id = UUID()

    static func == (lhs: SourceRegistrationData, rhs: SourceRegistrationData) -> Bool {
        lhs.id == rhs.id
    }

    let register: SourceRegisters
    let mainUrl: URL
    let repos: [RepoElement]

    struct RepoElement: Codable, Hashable {
        var representedData: [RepresentedKeys: String]

        init(localUrl: URL) {
            representedData = [
                .localUrl: localUrl.path,
                .identifier: UUID().uuidString,
            ]
        }

        init(remoteUrl: URL, username: String, token: String) {
            representedData = [
                .remoteUrl: remoteUrl.absoluteString,
                .username: username,
                .token: token,
                .identifier: UUID().uuidString,
            ]
        }

        enum RepresentedKeys: String, Codable {
            case remoteUrl
            case localUrl

            case username
            case token

            case identifier
        }
    }
}
