//
//  ApiProtocol.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/5.
//

import Foundation

protocol GitApi {
    func validate() throws
    func repositories() throws -> [URL]
}

enum ApiError: Error, LocalizedError {
    case emptyData
    case invalidUrl
    case invalidUser
    case network(reason: String)
    case statusCode(code: Int)
    case response(reason: String)

    public var errorDescription: String? {
        switch self {
        case .emptyData:
            "未找到有效的数据，请再试一次。"
        case .invalidUrl:
            "错误的 URL 数据，请再试一次。"
        case .invalidUser:
            "无效的用户信息，请再试一次。"
        case let .network(reason):
            "无法连接到服务器: \(reason)"
        case let .statusCode(code):
            "服务器返回未知状态: \(code) \(HTTPURLResponse.localizedString(forStatusCode: code))"
        case let .response(reason):
            "服务器返回错误信息：\(reason)"
        }
    }
}
