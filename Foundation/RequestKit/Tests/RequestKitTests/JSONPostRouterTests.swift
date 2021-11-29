import Foundation
import RequestKit
import XCTest

class JSONPostRouterTests: XCTestCase {
    static var allTests = [
        ("testJSONPostJSONError", testJSONPostJSONError),
        ("testJSONPostStringError", testJSONPostStringError),
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
    ]

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = thisClass.defaultTestSuite.tests.count
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    func testJSONPostJSONError() {
        let jsonDict = ["message": "Bad credentials", "documentation_url": "https://developer.github.com/v3"]
        let jsonString = String(data: try! JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions()), encoding: String.Encoding.utf8)
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: jsonString, statusCode: 401)
        let task = TestInterface().postJSON(session) { response in
            switch response {
            case .success:
                XCTAssert(false, "should not retrieve a succesful response")
            case let .failure(error):
                XCTAssertEqual(Helper.getNSError(from: error)?.code, 401)
                XCTAssertEqual(Helper.getNSError(from: error)?.domain, "com.nerdishbynature.RequestKitTests")
                XCTAssertEqual((Helper.getNSError(from: error)?.userInfo[RequestKitErrorKey] as? [String: String]) ?? [:], jsonDict)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testJSONPostStringError() {
        let errorString = "Just nope"
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: errorString, statusCode: 401)
        let task = TestInterface().postJSON(session) { response in
            switch response {
            case .success:
                XCTAssert(false, "should not retrieve a succesful response")
            case let .failure(error):
                XCTAssertEqual(Helper.getNSError(from: error)?.code, 401)
                XCTAssertEqual(Helper.getNSError(from: error)?.domain, "com.nerdishbynature.RequestKitTests")
                XCTAssertEqual((Helper.getNSError(from: error)?.userInfo[RequestKitErrorKey] as? String) ?? "", errorString)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
}
