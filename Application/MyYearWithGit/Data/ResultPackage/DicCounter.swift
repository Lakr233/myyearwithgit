//
//  DicCounter.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation

enum DicCounter {
    static func mostUsedKeyword<T>(from dic: [T: Int]) -> (T, Int)? {
        var searchKey: T?
        var searchKeyCount = -1
        for key in dic.keys {
            let count = dic[key, default: 0]
            if count > searchKeyCount {
                searchKey = key
                searchKeyCount = count
            }
        }
        guard let key = searchKey else {
            return nil
        }
        return (key, searchKeyCount)
    }

    static func mostUsedKeywords(from dic: [String: Int], count: Int) -> [String] {
        var resultBuilder = [(String, Int)](repeating: ("", -1), count: count)
        for key in dic.keys {
            let count = dic[key, default: 0]
            inner: for index in 0 ..< resultBuilder.count where resultBuilder[index].1 < count {
                resultBuilder[index] = (key, count)
                break inner
            }
        }
        return resultBuilder
            .filter { $0.1 > 0 }
            .map(\.0)
    }
}
