import Foundation
import RequestKit
import XCTest
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

class RouterTests: XCTestCase {
    static var allTests = [
        ("testRequest", testRequest),
        ("testRequestWithAuthorizationHeader", testRequestWithAuthorizationHeader),
        ("testRequestWithCustomHeaders", testRequestWithCustomHeaders),
        ("testWasSuccessful", testWasSuccessful),
        ("testURLComponents", testURLComponents),
        ("testFormEncodedRouteRequest", testFormEncodedRouteRequest),
        ("testErrorWithJSON", testErrorWithJSON),
        ("testLoadAndIgnoreResponseBody", testLoadAndIgnoreResponseBody),
        ("testErrorWithLoadAndIgnoreResponseBody", testErrorWithLoadAndIgnoreResponseBody),
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

    lazy var router: TestRouter = {
        let config = TestConfiguration("1234", url: "https://example.com/api/v1/")
        let router = TestRouter.testRoute(config)
        return router
    }()

    func testRequest() {
        let subject = router.request()
        XCTAssertEqual(subject?.url?.absoluteString, "https://example.com/api/v1/some_route?access_token=1234&key1=value1%3A456&key2=value2")
        XCTAssertEqual(subject?.httpMethod, "GET")
    }

    func testRequestWithAuthorizationHeader() {
        let config = TestAuthorizationHeaderConfiguration("1234", url: "https://example.com/api/v1/")
        let router = TestRouter.testRoute(config)
        let subject = router.request()
        XCTAssertEqual(subject?.url?.absoluteString, "https://example.com/api/v1/some_route?key1=value1%3A456&key2=value2")
        XCTAssertEqual(subject?.httpMethod, "GET")
        XCTAssertEqual(subject?.value(forHTTPHeaderField: "Authorization"), "BEARER 1234")
    }

    func testRequestWithCustomHeaders() {
        let config = TestCustomConfiguration("1234", url: "https://github.com", customHeader: HTTPHeader(headerField: "x-custom-header", value: "custom_value"))
        let router = TestRouter.testRoute(config)
        let subject = router.request()
        XCTAssertEqual(subject?.value(forHTTPHeaderField: "x-custom-header"), "custom_value")
    }

    func testWasSuccessful() {
        let url = URL(string: "https://example.com/api/v1")!
        let response200 = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertTrue(response200.wasSuccessful)
        let response201 = HTTPURLResponse(url: url, statusCode: 201, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertTrue(response201.wasSuccessful)
        let response400 = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response400.wasSuccessful)
        let response300 = HTTPURLResponse(url: url, statusCode: 300, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response300.wasSuccessful)
        let response301 = HTTPURLResponse(url: url, statusCode: 301, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response301.wasSuccessful)
    }

    func testURLComponents() {
        let test1: [String: Any] = ["key1": "value1", "key2": "value2"]
        XCTAssertEqual(router.urlQuery(test1)!, [URLQueryItem(name: "key1", value: "value1"), URLQueryItem(name: "key2", value: "value2")])
        let test2: [String: Any] = ["key1": ["value1", "value2"]]
        XCTAssertEqual(router.urlQuery(test2)!, [URLQueryItem(name: "key1[0]", value: "value1"), URLQueryItem(name: "key1[1]", value: "value2")])
        let test3: [String: Any] = ["key1": ["key2": "value1", "key3": "value2"]]
        XCTAssertEqual(router.urlQuery(test3)!, [URLQueryItem(name: "key1[key2]", value: "value1"), URLQueryItem(name: "key1[key3]", value: "value2")])
    }

    func testFormEncodedRouteRequest() {
        let config = TestConfiguration("1234", url: "https://example.com/api/v1/")
        let router = TestRouter.formEncodedRoute(config)
        let subject = router.request()
        XCTAssertEqual(subject?.url?.absoluteString, "https://example.com/api/v1/route")
        XCTAssertEqual(String(data: subject?.httpBody ?? Data(), encoding: .utf8), "access_token=1234&key1=value1%3A456&key2=value2")
        XCTAssertEqual(subject?.httpMethod, "POST")
    }

    func testErrorWithJSON() {
        let jsonDict = ["message": "Bad credentials", "documentation_url": "https://developer.github.com/v3"]
        let jsonString = String(data: try! JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions()), encoding: String.Encoding.utf8)
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "GET", response: jsonString, statusCode: 401)
        let task = TestInterface().getJSON(session) { response in
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

    func testLoadAndIgnoreResponseBody() {
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: nil, statusCode: 204)

        var receivedSuccessResponse = false

        let task = TestInterface().loadAndIgnoreResponseBody(session) { response in
            switch response {
            case .success:
                receivedSuccessResponse = true
            case .failure:
                XCTAssert(false, "should not retrieve a failure response")
            }
        }

        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
        XCTAssertTrue(receivedSuccessResponse)
    }

    func testErrorWithLoadAndIgnoreResponseBody() {
        let jsonDict = ["message": "Bad credentials", "documentation_url": "https://developer.github.com/v3"]
        let jsonString = String(data: try! JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions()), encoding: String.Encoding.utf8)
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: jsonString, statusCode: 401)

        var receivedFailureResponse = false

        let task = TestInterface().loadAndIgnoreResponseBody(session) { response in
            switch response {
            case .success:
                XCTAssert(false, "should not retrieve a successful response")
            case let .failure(error):
                receivedFailureResponse = true
                XCTAssertEqual(Helper.getNSError(from: error)?.code, 401)
                XCTAssertEqual(Helper.getNSError(from: error)?.domain, "com.nerdishbynature.RequestKitTests")
                XCTAssertEqual((Helper.getNSError(from: error)?.userInfo[RequestKitErrorKey] as? [String: String]) ?? [:], jsonDict)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
        XCTAssertTrue(receivedFailureResponse)
    }
}

enum TestRouter: Router {
    case testRoute(Configuration)
    case formEncodedRoute(Configuration)

    var configuration: Configuration {
        switch self {
        case let .testRoute(config): return config
        case let .formEncodedRoute(config): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .testRoute:
            return .GET
        case .formEncodedRoute:
            return .POST
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .testRoute:
            return .url
        case .formEncodedRoute:
            return .form
        }
    }

    var path: String {
        switch self {
        case .testRoute:
            return "some_route"
        case .formEncodedRoute:
            return "route"
        }
    }

    var params: [String: Any] {
        ["key1": "value1:456", "key2": "value2"]
    }
}
