import XCTest

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(RouterTests.allTests),
            testCase(ConfigurationTests.allTests),
            testCase(JSONPostRouterTests.allTests),
        ]
    }
#endif
