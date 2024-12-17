//
//  Exts.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import Foundation

protocol HumanReadable {
    func readableDescription() -> String
}

var standardError = FileHandle.standardError

extension FileHandle: @retroactive TextOutputStream {
    public func write(_ string: String) {
        let data = Data(string.utf8)
        write(data)
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }

        var items: [String: String] = [:]

        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }

        return items
    }

    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
            .map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url!
    }
}
