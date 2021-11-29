//
//  BlockItem.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/1.
//

import AppKit
import Foundation

class CommitFileFilter {
    static let shared = CommitFileFilter()

    private init() {
        if let str = UserDefaults.standard.value(forKey: "wiki.qaq.block.list") as? String,
           let data = str.data(using: .utf8),
           let object = try? JSONDecoder().decode([BlockItem].self, from: data)
        {
            commitBlockList = object
        }
    }

    var commitBlockList: [BlockItem] = [] {
        didSet {
            if let jsonData = try? JSONEncoder().encode(commitBlockList),
               let json = String(data: jsonData, encoding: .utf8)
            {
                UserDefaults.standard.set(json, forKey: "wiki.qaq.block.list")
            }
        }
    }

    enum BlockType: String, Codable, CaseIterable, HumanReadable {
        case nameKeyWord
        case nameKeyWordCaseSensitive
        case pathKeyWord
        case pathKeyWordCaseSensitive
        case pathComponentFullMatch
        case pathComponentFullMatchCaseSensitive
        case nameRegExFullMatch

        func readableDescription() -> String {
            switch self {
            case .nameKeyWord:
                return "文件名关键词"
            case .nameKeyWordCaseSensitive:
                return "文件名关键词 匹配大小写"
            case .pathKeyWord:
                return "路径关键词"
            case .pathKeyWordCaseSensitive:
                return "路径关键词 匹配大小写"
            case .pathComponentFullMatch:
                return "路径中存在文件名"
            case .pathComponentFullMatchCaseSensitive:
                return "路径中存在文件名 匹配大小写"
            case .nameRegExFullMatch:
                return "文件名正则表达式完整匹配"
            }
        }
    }

    typealias Passed = Bool
    struct BlockItem: Codable, Equatable {
        let type: BlockType
        let value: String

        typealias Matched = Bool
        func match(_ location: URL) -> Matched {
            switch type {
            case .nameKeyWord:
                return location
                    .lastPathComponent
                    .lowercased()
                    .contains(value.lowercased())
            case .nameKeyWordCaseSensitive:
                return location
                    .lastPathComponent
                    .contains(value)

            case .pathKeyWord:
                return location
                    .deletingLastPathComponent()
                    .path
                    .lowercased()
                    .contains(value.lowercased())
            case .pathKeyWordCaseSensitive:
                return location
                    .deletingLastPathComponent()
                    .path
                    .contains(value)

            case .pathComponentFullMatch:
                let items = location
                    .deletingLastPathComponent()
                    .pathComponents
                    .map { $0.lowercased() }
                for item in items where item == value.lowercased() {
                    return true
                }
                return false
            case .pathComponentFullMatchCaseSensitive:
                let items = location
                    .deletingLastPathComponent()
                    .pathComponents
                for item in items where item == value {
                    return true
                }
                return false

            case .nameRegExFullMatch:
                let val = location
                    .path
                    .lowercased()
                return regExMatch(for: val, in: location.lastPathComponent)
            }
        }

        func regExMatch(for regex: String, in text: String) -> Bool {
            do {
                let regex = try NSRegularExpression(pattern: regex)
                let nsString = text as NSString
                let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
                return !results.isEmpty
            } catch {
                print("invalid regex: \(error.localizedDescription)")
                return false
            }
        }
    }

    func filter(_ location: URL) -> Passed {
        for blocker in commitBlockList where blocker.match(location) {
            debugPrint(
                """
                ignoring file \(location.path) matching rule \(blocker.type.readableDescription()) \(blocker.value)
                """
            )
            return false
        }
        return true
    }
}
