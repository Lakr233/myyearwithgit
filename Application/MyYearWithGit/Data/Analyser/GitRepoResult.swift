//
//  GitRepoResult.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import Foundation

extension RepoAnalyser {
    struct GitRepoResult: Codable {
        let commits: [GitCommitResult]
    }

    func generateResultPackage(with result: ResultPackage.DataSource) -> ResultPackage {
        let resultPackage = ResultPackage(data: result)
        resultPackage.update(with: result)
        return resultPackage
    }
}
