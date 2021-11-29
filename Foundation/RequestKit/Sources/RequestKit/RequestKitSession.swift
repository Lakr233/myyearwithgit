import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public protocol RequestKitURLSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol
    func uploadTask(with request: URLRequest, fromData bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension URLSession: RequestKitURLSession {
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }

    public func uploadTask(with request: URLRequest, fromData bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}
