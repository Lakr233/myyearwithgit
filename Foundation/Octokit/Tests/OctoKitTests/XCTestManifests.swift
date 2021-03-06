//
//  XCTestManifests.swift
//  OctoKitTests
//
//  Created by Franco Meloni on 07/11/2018.
//

import XCTest

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(ConfigurationTests.allTests),
            testCase(FollowTests.allTests),
            testCase(IssueTests.allTests),
            testCase(OctokitSwiftTests.allTests),
            testCase(PublicKeyTests.allTests),
            testCase(PullRequestTests.allTests),
            testCase(RepositoryTests.allTests),
            testCase(StarsTests.allTests),
            testCase(UserTests.allTests),
            testCase(StatusesTest.allTests),
        ]
    }
#endif
