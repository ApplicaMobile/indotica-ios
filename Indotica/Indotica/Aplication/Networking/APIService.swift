//
//  APIService.swift
//  Indotica
//
//  Created by Ariel Scarafia on 25/01/2023.
//

import Foundation

class APIService: APIProtocol {
       
    private let userDefault: UserDefaultsManager
    
    init(userDefault: UserDefaultsManager) {
        self.userDefault = userDefault
    }
    
    enum RequestType: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    private func headerInterceptor(request: URLRequest) -> URLRequest {
        var request = request
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let lang = Locale.preferredLanguages.first?.prefix(2){
            request.addValue(String(lang), forHTTPHeaderField: "Accept-Language")
        }
                 
        if let token = self.tokenFromDefaults(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func tokenFromDefaults() -> String? {
        return userDefault.userToken
    }
    
    private func callEnpoint(path: String, method: RequestType, query: [URLQueryItem], requestData: EncodableRequest? = nil) async throws -> (Data?, URLResponse?) {
        
        guard let finalURL = parseUrl(path: path, query: query) else {
            throw IOError.invalidURL(path)
        }
        
        let urlRequest = URLRequest(url: finalURL)
        
        var request = headerInterceptor(request: urlRequest)
        request.httpMethod = method.rawValue
        
        if method != .GET {
            request.httpBody = requestData?.toJSONData()
        }
        
        let urlSession = getURLSession()
        
        return try await urlSession.data(for: request)
    }
    
    private func getURLSession() -> URLSession {
        let twentySeconds = 20.0
        let fifteenSeconds = 15.0
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = twentySeconds
        sessionConfig.timeoutIntervalForResource = fifteenSeconds
        return URLSession(configuration: sessionConfig)
    }
    
    private func parseUrl(path: String, query: [URLQueryItem])  -> URL? {
        var urlComponents = URLComponents()
        
        if path.starts(with: "http") {
            urlComponents = URLComponents(string: path) ?? URLComponents()
        } else {
            urlComponents.scheme = APIEndpoints.scheme
            urlComponents.host = APIEndpoints.host
            print("*** PORT \(APIEndpoints.port)")
            urlComponents.port = APIEndpoints.port
            urlComponents.path = path
        }
    
        if !query.isEmpty {
            urlComponents.queryItems = query
        }
        print("*** urlComp \(urlComponents)")
        print("*** url = \(urlComponents.url)")
        return urlComponents.url
    }

    func get<T: Decodable>(endpoint: String, query: [URLQueryItem] = []) async throws -> T {
        let (data, response) = try await callEnpoint(path: endpoint, method: RequestType.GET, query: query)
        
        guard let response = response as? HTTPURLResponse, !checkIfResponseContainsErrorCode(response: response) else {
            let response = response as? HTTPURLResponse
            throw IOError.responseErrorCode(response?.statusCode ?? 0)
        }
        
        guard let data = data else {
            throw IOError.invalidJSON("Null data received")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        let decodedData: T = try decoder.decode(T.self, from: data)
        return decodedData
    }
    
    func post<T: Decodable>(endpoint: String, query: [URLQueryItem] = [], requestData: EncodableRequest?) async throws -> T {
        let (data, response) = try await callEnpoint(path: endpoint, method: RequestType.POST, query: query, requestData: requestData)
        
        guard let response = response as? HTTPURLResponse, !checkIfResponseContainsErrorCode(response: response) else {
            let response = response as? HTTPURLResponse
            throw IOError.responseErrorCode(response?.statusCode ?? 0)
        }

        guard let data = data else {
            throw IOError.invalidJSON("Null data received")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        let decodedData: T = try decoder.decode(T.self, from: data)
        return decodedData
    }
    
    func put<T: Decodable>(endpoint: String, query: [URLQueryItem] = [], requestData: EncodableRequest) async throws -> T {
        let (data, response) = try await callEnpoint(path: endpoint, method: RequestType.PUT, query: query, requestData: requestData)
        
        guard let response = response as? HTTPURLResponse, !checkIfResponseContainsErrorCode(response: response) else {
            let response = response as? HTTPURLResponse
            throw IOError.responseErrorCode(response?.statusCode ?? 0)
        }

        guard let data = data else {
            throw IOError.invalidJSON("Null data received")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        let decodedData: T = try decoder.decode(T.self, from: data)
        return decodedData
    }
    
    func delete<T: Decodable>(endpoint: String, query: [URLQueryItem] = []) async throws -> T? {
        let (data, response) = try await callEnpoint(path: endpoint, method: RequestType.DELETE, query: query)
        
        guard let response = response as? HTTPURLResponse, !checkIfResponseContainsErrorCode(response: response) else {
            let response = response as? HTTPURLResponse
            throw IOError.responseErrorCode(response?.statusCode ?? 0)
        }
        
        guard let data = data else {
            throw IOError.invalidJSON("Null data received")
        }
        
        if data.isEmpty {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        let decodedData: T = try decoder.decode(T.self, from: data)
        return decodedData
    }
    
    private func checkIfResponseContainsErrorCode(response: HTTPURLResponse) -> Bool {
        if response.statusCode > 299 {
            switch(response.statusCode) {
            case 401:
                handle401Response(response: response)
                break;
            default:
                handleResponseError(response: response)
                break;
            }
            return true
        } else {
            return false
        }
    }
    
    private func handle401Response(response: HTTPURLResponse, requestData: EncodableRequest? = nil ){
        userDefault.clearToken()
        DispatchQueue.main.async { [weak self] in
            self?.goToLoginScreen(requestData: requestData)
        }
    }
    
    private func handleResponseError(response: HTTPURLResponse) {
        let error = NSError(domain: "", code: response.statusCode, userInfo: nil) as Error
    }
    
    private func goToLoginScreen(requestData: EncodableRequest? = nil) {
        //TODO: go to login ?
    }
}
