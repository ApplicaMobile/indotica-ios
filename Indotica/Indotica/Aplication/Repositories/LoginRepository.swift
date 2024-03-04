//
//  LoginRepository.swift
//  Indotica
//
//  Created by Nicolas Llanos on 01/03/2024.
//

import Foundation

class LoginRepository: LoginService {
    
    private let apiService: APIProtocol
    
    init(apiService: APIProtocol) {
        self.apiService = apiService
    }
    
    func login(token: String) async throws -> TokenResponse {
        let request = TokenRequest(token: token)
        return try await apiService.post(endpoint: APIEndpoints.token, query: [], requestData: request)
    }
}
