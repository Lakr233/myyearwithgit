//
//  GitLabApi.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Foundation

class GitLabApi: GitApi {
    let config: Config
    struct Config {
        let endpoint: URL
        let token: String
    }

    // user info from validation
    var userId: Int?
    var userName: String?

    init(config: Config) {
        self.config = config
    }

    // nil = invalid, otherwise "" but not nil
    func validate() throws {
        let request = createRequest(withPaths: [
            "user",
        ])
        var result: Bool = false
        var error: Error?
        let sem = DispatchSemaphore(value: 0)
        URLSession
            .shared
            .dataTask(with: request) { data, resp, err in
                defer { sem.signal() }

                // connection error
                if let err = err {
                    error = ApiError.network(reason: err.localizedDescription)
                    return
                }

                // unknown status code
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                    error = ApiError.statusCode(code: resp.statusCode)
                }

                // json decodable as dict
                guard let data = data,
                      let dic = try? JSONSerialization
                      .jsonObject(
                          with: data, options: .allowFragments
                      ) as? [String: Any]
                else {
                    return
                }

                // not an error
                if error == nil {
                    if let name = dic["name"] as? String {
                        self.userName = name
                    }
                    if let id = dic["id"] as? Int {
                        self.userId = id
                        result = true
                    }
                    if let email = dic["email"] as? String {
                        User.current.email.insert(email)
                    }
                    if let email = dic["commit_email"] as? String {
                        User.current.email.insert(email)
                    }
                }

                // server has detailed error description or messages
                if let errorVal = dic["error"] as? String,
                   let errorReason = dic["error_description"] as? String
                {
                    error = ApiError.response(reason: "\(errorReason) (\(errorVal))")
                } else if let errorMessage = dic["message"] as? String {
                    error = ApiError.response(reason: "\(errorMessage)")
                }
            }
            .resume()
        sem.wait()

        if let error = error {
            throw error
        }

        guard result else {
            throw ApiError.invalidUser
        }
    }

    func repositories() throws -> [URL] {
        var endpoints = Set<URL>(arrayLiteral: createURL(
            withPaths: [
                "projects",
            ],
            withParameters: [
                "min_access_level": "30", // developer access level
                "pagination": "keyset",
                "per_page": "100",
                "order_by": "id",
                "sort": "asc",
            ]
        ))

        var result = [URL]()
        var error: Error?
        while let endpoint = endpoints.popFirst() {
            let sem = DispatchSemaphore(value: 0)
            URLSession
                .shared
                .dataTask(with: createRequest(withURL: endpoint)) { [weak self] data, resp, err in
                    defer { sem.signal() }

                    // connection error
                    if let err = err {
                        error = ApiError.network(reason: err.localizedDescription)
                        return
                    }

                    // unknown status code
                    if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                        error = ApiError.statusCode(code: resp.statusCode)
                    }

                    // json decodable as arr
                    guard let data = data,
                          let dic = try? JSONSerialization
                          .jsonObject(
                              with: data, options: .allowFragments
                          ) as? [[String: Any]]
                    else {
                        return
                    }

                    // not an error
                    if error == nil {
                        for value in dic {
                            if let gitUrlStr = value["http_url_to_repo"] as? String,
                               let gitUrl = URL(string: gitUrlStr)
                            {
                                result.append(gitUrl)
                            }
                        }
                        if let resp = resp as? HTTPURLResponse,
                           let linkVal = resp.value(forHTTPHeaderField: "Link")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                           linkVal.hasSuffix("rel=\"next\"")
                        {
                            var linkHref = String(linkVal.dropLast("rel=\"next\"".count))
                                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            if linkHref.hasPrefix("<") {
                                linkHref = String(linkHref.dropFirst("<".count))
                            }
                            if linkHref.hasSuffix(">;") {
                                linkHref = String(linkHref.dropLast(">;".count))
                            }
                            if let linkURL = URL(string: linkHref),
                               let linkQuery = linkURL.queryParameters,
                               let replURL = self?.config.endpoint.appendingPathComponent(String(linkURL.path.dropFirst())).appendingQueryParameters(linkQuery)
                            {
                                endpoints.insert(replURL)
                            }
                        }
                    }
                }
                .resume()
            sem.wait()
        }

        if let error = error {
            throw error
        }

        guard result.count > 0 else {
            throw ApiError.emptyData
        }
        return result
    }

    func createURL(withPaths paths: [String], withParameters parameters: [String: String]? = nil) -> URL {
        var endpoint = config
            .endpoint
            .appendingPathComponent("api")
            .appendingPathComponent("v4")
        for path in paths {
            endpoint.appendPathComponent(path)
        }
        if let parameters = parameters {
            endpoint = endpoint.appendingQueryParameters(parameters)
        }
        return endpoint
    }

    func createRequest(withPaths paths: [String], withParameters parameters: [String: String]? = nil) -> URLRequest {
        createRequest(withURL: createURL(withPaths: paths, withParameters: parameters))
    }

    func createRequest(withURL url: URL) -> URLRequest {
        let endpoint = url
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(config.token, forHTTPHeaderField: "PRIVATE-TOKEN")
        return request
    }
}
