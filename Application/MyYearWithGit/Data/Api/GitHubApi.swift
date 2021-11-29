//
//  GitHubApi.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/5.
//

import Foundation
import OctoKit
import RequestKit

class GitHubApi: GitApi {
    let config: Config
    struct Config {
        let token: String
    }

    init(config: Config) {
        self.config = config
    }

    var api: Octokit?

    func checkError(_ err: Error?) -> Error? {
        var error: Error?
        let errObj = (err as NSError?)?.userInfo[RequestKit.RequestKitErrorKey]
        if let errObj = errObj as? [String: Any],
           let errMsg = errObj["message"] as? String
        {
            if let errDoc = errObj["documentation_url"] as? String {
                error = ApiError.response(reason: "\(errMsg) (See: \(errDoc))")
            } else {
                error = ApiError.response(reason: errMsg)
            }
        } else if let errObj = errObj as? String {
            error = ApiError.response(reason: errObj)
        } else if let err = err as? URLError {
            error = ApiError.network(reason: err.localizedDescription)
        } else {
            error = err
        }
        return error
    }

    func validate() throws {
        let config = TokenConfiguration(config.token)
        var validated = false
        let sem = DispatchSemaphore(value: 0)
        let core = Octokit(config)
        var error: Error?
        core.me { [weak self] response in
            defer { sem.signal() }
            switch response {
            case let .success(userObject):
                validated = true
                if let email = userObject.email {
                    User.current.email.insert(email)
                }
            case let .failure(err):
                error = self?.checkError(err)
            }
        }
        sem.wait()
        if let error = error {
            throw error
        }
        if validated {
            api = core
        }
        guard validated else {
            throw ApiError.invalidUser
        }
    }

    func repositories() throws -> [URL] {
        guard let api = api else {
            return []
        }
        var result: Set<URL> = []
        var page = 1
        repeat {
            do {
                let repos = try repositoryFor(page: page, api: api)
                repos.forEach { result.insert($0) }
                if repos.count > 0, page <= 65535 {
                    page += 1
                } else {
                    page = -1
                }
            } catch {
                throw error
            }
        } while page != -1
        return [URL](result)
    }

    func repositoryFor(page: Int, api: Octokit) throws -> [URL] {
        var result: Set<URL> = []
        let sem = DispatchSemaphore(value: 0)
        var error: Error?
        api.repositories(page: String(page), perPage: "100") { [weak self] response in
            defer { sem.signal() }
            switch response {
            case let .success(repository):
                for repo in repository {
                    guard let location = repo.cloneURL,
                          let url = URL(string: location)
                    else {
                        continue
                    }
                    result.insert(url)
                }
            case let .failure(err):
                error = self?.checkError(err)
            }
        }
        sem.wait()
        if let error = error {
            throw error
        }
        debugPrint("GitHub repository for page \(page) returned \(result.count) results")
        return [URL](result)
    }
}
