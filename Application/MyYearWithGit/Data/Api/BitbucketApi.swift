//
//  Bitbucket.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/3.
//

import Foundation

private let bbEndpoint = URL(string: "https://api.bitbucket.org/")!
private let bbCloneBase = URL(string: "https://bitbucket.org/")!

class BitbucketApi: GitApi {
    let config: Config
    struct Config {
        let token: String
    }

    // user info from validation
    var userId: String?
    var userName: String?

    init(config: Config) {
        self.config = config
    }

    // nil = invalid, otherwise "" but not nil
    func validate() throws {
        let userRequest = createRequest(withPaths: [
            "user",
        ])
        var result = false
        var error: Error?
        let sem = DispatchSemaphore(value: 0)
        URLSession
            .shared
            .dataTask(with: userRequest) { data, resp, err in
                defer { sem.signal() }

                // connection error
                if let err {
                    error = ApiError.network(reason: err.localizedDescription)
                    return
                }

                // unknown status code
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                    error = ApiError.statusCode(code: resp.statusCode)
                }

                // json decodable as dict
                guard let data,
                      let dic = try? JSONSerialization
                      .jsonObject(
                          with: data, options: .allowFragments
                      ) as? [String: Any]
                else {
                    return
                }

                // not an error
                if error == nil {
                    if let name = dic["username"] as? String {
                        self.userName = name
                    }
                    if let id = dic["account_id"] as? String {
                        self.userId = id
                        result = true
                    }
                }

                // server has detailed error description or messages
                if let errorDict = dic["error"] as? [String: Any] {
                    if let errorDetail = errorDict["detail"] as? String,
                       let errorMessage = errorDict["message"] as? String
                    {
                        error = ApiError.response(reason: "\(errorDetail) (\(errorMessage))")
                    }
                }
            }
            .resume()
        let emailRequest = createRequest(withPaths: [
            "user",
            "emails",
        ])
        URLSession
            .shared
            .dataTask(with: emailRequest) { data, resp, err in
                defer { sem.signal() }

                // connection error
                if let err {
                    error = ApiError.network(reason: err.localizedDescription)
                    return
                }

                // unknown status code
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                    error = ApiError.statusCode(code: resp.statusCode)
                }

                // json decodable as dict
                guard let data,
                      let dic = try? JSONSerialization
                      .jsonObject(
                          with: data, options: .allowFragments
                      ) as? [String: Any]
                else {
                    return
                }

                // not an error
                if error == nil {
                    if let emailValues = dic["values"] as? [[String: Any]] {
                        emailValues
                            .compactMap { $0["email"] as? String }
                            .forEach { User.current.email.insert($0) }
                    }
                }

                // server has detailed error description or messages
                if let errorDict = dic["error"] as? [String: Any] {
                    if let errorDetail = errorDict["detail"] as? String,
                       let errorMessage = errorDict["message"] as? String
                    {
                        error = ApiError.response(reason: "\(errorDetail) (\(errorMessage))")
                    }
                }
            }.resume()

        sem.wait() // URLSession default timeout is 60 * 2 = 120 secs

        if let error {
            throw error
        }

        sem.wait()

        if let error {
            throw error
        }

        guard result else {
            throw ApiError.invalidUser
        }
    }

    func repositories() throws -> [URL] {
        var result = Set<URL>()
        for workspace in try workspaces() {
            var endpoints = Set<URL>(arrayLiteral: workspace)
            while let endpoint = endpoints.popFirst() {
                var error: Error?
                let sem = DispatchSemaphore(value: 0)
                URLSession
                    .shared
                    .dataTask(with: createRequest(withURL: endpoint)) { data, resp, err in
                        defer { sem.signal() }

                        // connection error
                        if let err {
                            error = ApiError.network(reason: err.localizedDescription)
                            return
                        }

                        // unknown status code
                        if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                            error = ApiError.statusCode(code: resp.statusCode)
                        }

                        // json decodable as dict
                        guard let data,
                              let dic = try? JSONSerialization
                              .jsonObject(
                                  with: data, options: .allowFragments
                              ) as? [String: Any]
                        else {
                            return
                        }

                        // not an error
                        if error == nil {
                            if let retValues = dic["values"] as? [[String: Any]] {
                                let repoHrefs = retValues.compactMap { retVal in
                                    ((retVal["links"] as? [String: Any])?["clone"] as? [[String: String]])?.first(where: { $0["name"] == "https" })?["href"]
                                }
                                let repoURLs = repoHrefs.compactMap { URL(string: $0) }
                                result.formUnion(repoURLs)
                            }
                            if let nextHref = dic["next"] as? String, let nextURL = URL(string: nextHref) {
                                endpoints.insert(nextURL)
                            }
                        }

                        // server has detailed error description or messages
                        if let errorDict = dic["error"] as? [String: Any] {
                            if let errorDetail = errorDict["detail"] as? String,
                               let errorMessage = errorDict["message"] as? String
                            {
                                error = ApiError.response(reason: "\(errorDetail) (\(errorMessage))")
                            }
                        }
                    }.resume()
                sem.wait()
                if let error {
                    throw error
                }
            }
        }
        guard result.count > 0 else {
            throw ApiError.emptyData
        }
        return [URL](result).map { bbCloneBase.appendingPathComponent(String($0.path.dropFirst())) }
    }

    func workspaces() throws -> [URL] {
        var endpoints = Set<URL>(arrayLiteral: bbEndpoint.appendingPathComponent("2.0").appendingPathComponent("workspaces"))
        var result = Set<URL>()
        while let endpoint = endpoints.popFirst() {
            var error: Error?
            let sem = DispatchSemaphore(value: 0)
            URLSession
                .shared
                .dataTask(with: createRequest(withURL: endpoint)) { data, resp, err in
                    defer { sem.signal() }

                    // connection error
                    if let err {
                        error = ApiError.network(reason: err.localizedDescription)
                        return
                    }

                    // unknown status code
                    if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                        error = ApiError.statusCode(code: resp.statusCode)
                    }

                    // json decodable as dict
                    guard let data,
                          let dic = try? JSONSerialization
                          .jsonObject(
                              with: data, options: .allowFragments
                          ) as? [String: Any]
                    else {
                        return
                    }

                    // not an error
                    if error == nil {
                        if let retValues = dic["values"] as? [[String: Any]] {
                            let repoHrefs = retValues.compactMap { (($0["links"] as? [String: Any])?["repositories"] as? [String: String])?["href"] }
                            let repoURLs = repoHrefs.compactMap { URL(string: $0) }
                            result.formUnion(repoURLs)
                        }
                        if let nextHref = dic["next"] as? String, let nextURL = URL(string: nextHref) {
                            endpoints.insert(nextURL)
                        }
                    }

                    // server has detailed error description or messages
                    if let errorDict = dic["error"] as? [String: Any] {
                        if let errorDetail = errorDict["detail"] as? String,
                           let errorMessage = errorDict["message"] as? String
                        {
                            error = ApiError.response(reason: "\(errorDetail) (\(errorMessage))")
                        }
                    }
                }.resume()
            sem.wait()
            if let error {
                throw error
            }
        }
        guard result.count > 0 else {
            throw ApiError.emptyData
        }
        return [URL](result)
    }

    func createURL(withPaths paths: [String], withParameters parameters: [String: String]? = nil) -> URL {
        var endpoint = bbEndpoint
            .appendingPathComponent("2.0")
        for path in paths {
            endpoint.appendPathComponent(path)
        }
        if let parameters {
            endpoint = endpoint.appendingQueryParameters(parameters)
        }
        return endpoint
    }

    func createRequest(withPaths paths: [String], withParameters parameters: [String: String]? = nil) -> URLRequest {
        createRequest(withURL: createURL(withPaths: paths, withParameters: parameters))
    }

    func createRequest(withURL url: URL) -> URLRequest {
        let endpoint = url
        let basicToken = config.token.data(using: .utf8)!.base64EncodedString()
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Basic \(basicToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
