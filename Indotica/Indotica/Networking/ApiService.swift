//
//  ApiService.swift
//  Indotica
//
//  Created by Nicolas Llanos on 23/02/2024.
//

import Foundation

struct ApiInfo {
    static let baseURL = "http://192.168.2.13:4552"
    static let token = "/token"
}

class SessionHandler {
    
    static var shared = SessionHandler()
    var requestHandler = RequestHandler()
    var reasonString = ""
}

protocol PropertyLoopable {
    func asQueyItems() -> [URLQueryItem]?
}

class RequestHandler {
    
    enum ServerError: Error {
        case generalError
    }
    
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20.0
        return URLSession(configuration: configuration,
                          delegate: nil,
                          delegateQueue: nil)
    }()
    
    public enum IndoticaHTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    
    enum SessionType {
        case normal
        case mendoza
    }

    enum EncType {
        case application_json
        case application_x_www_form_urlencoded
        case application_pdf
        case multiPartForm
    }
    
    typealias EncodableRequest = PropertyLoopable & Encodable
    
    private func decodeDataToString(_ data: Data) throws -> String {
        return try String(decoding: data, as: UTF8.self)
    }
    
    private func decodeDataToType<T: Decodable>(_ type: T.Type, data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        return try decoder.decode(type, from: data)
    }
    
    func requestdata<T: Decodable>(path: String,
                                    type: T.Type,
                                    method: IndoticaHTTPMethod = .get,
                                    requestData: EncodableRequest? = nil,
                                    sessionType: SessionType = .normal,
                                    encType: EncType = .application_json,
                                    completionHandler: @escaping (T?, Error?) -> ()) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        if sessionType == .normal {
            urlComponents.host = ApiInfo.baseURL
        }
        urlComponents.path = path
        
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
        
        if method == .get {
            urlComponents.queryItems = requestData?.asQueyItems()
        }
        
        guard let urlR = urlComponents.url else {
            completionHandler(nil, nil)
            return
        }
        var request = URLRequest(url: urlR)
        request.httpMethod = method.rawValue
        
        if sessionType == .normal && encType == .application_json {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Accept-Language", forHTTPHeaderField: "es")
            request.addValue("Connection", forHTTPHeaderField: "Keep-Alive")
        }
        
        session.dataTask(with: request){ (data, response, err) in
            print(#function, "PATH: " + path)
            if let error = err {
                completionHandler(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case ..<300:
                    do {
                        guard let data else { return }
                        let str = try self.decodeDataToString(data)
                        print("RESPONSE ----> \(str)")
                        
                        let json = try self.decodeDataToType(type, data: data)
                        completionHandler(json, nil)
                    } catch {
                        completionHandler(nil, nil)
                    }
                case 401:
                    print("Error 401")
                case 403:
                    print("Error 403")
                default:
                    if let error = err {
                        completionHandler(nil, error)
                        return
                    }
                }
            }
        }.resume()
    }
}


//MARK: HELPERS
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter
    }()
}

extension PropertyLoopable {
    
    func asQueyItems() -> [URLQueryItem]? {
        
        var result: [URLQueryItem] = []
        
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return nil
        }
        
        for (property,value) in mirror.children {
            guard let property = property else {
                continue
            }
            if case Optional<Any>.none = value  {
                continue
            }
            result.append(URLQueryItem(name: property, value: String(describing: value)))
        }
        
        return result
    }
    
    func asString() -> String? {
        var result = ""
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return nil
        }
        
        for (property,value) in mirror.children {
            guard let property = property else {
                continue
            }
            if case Optional<Any>.none = value  {
                continue
            }
            result.append("\(property):\(String(describing: value)), ")
        }
        
        return result
    }
}
