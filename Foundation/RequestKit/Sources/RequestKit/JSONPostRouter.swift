import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public protocol JSONPostRouter: Router {
    func postJSON<T>(_ session: RequestKitURLSession, expectedResultType: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?
    func post<T: Codable>(_ session: RequestKitURLSession, decoder: JSONDecoder, expectedResultType: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?
}

public extension JSONPostRouter {
    func postJSON<T>(_ session: RequestKitURLSession = URLSession.shared, expectedResultType _: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {
        guard let request = request() else {
            return nil
        }

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            completion(nil, error)
            return nil
        }

        let task = session.uploadTask(with: request, fromData: data) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        userInfo[RequestKitErrorKey] = json as Any?
                    } else if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
                        userInfo[RequestKitErrorKey] = string as Any?
                    }
                    let error = NSError(domain: self.configuration.errorDomain, code: response.statusCode, userInfo: userInfo)
                    completion(nil, error)
                    return
                }
            }

            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    do {
                        let JSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T
                        completion(JSON, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    func post<T: Codable>(_ session: RequestKitURLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder(), expectedResultType _: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {
        guard let request = request() else {
            return nil
        }

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            completion(nil, error)
            return nil
        }

        let task = session.uploadTask(with: request, fromData: data) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        userInfo[RequestKitErrorKey] = json as Any?
                    } else if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
                        userInfo[RequestKitErrorKey] = string as Any?
                    }
                    let error = NSError(domain: self.configuration.errorDomain, code: response.statusCode, userInfo: userInfo)
                    completion(nil, error)
                    return
                }
            }

            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        completion(decoded, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
}
