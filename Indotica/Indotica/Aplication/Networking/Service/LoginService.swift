//
//  LoginService.swift
//  Indotica
//
//  Created by Nicolas Llanos on 01/03/2024.
//

import Foundation

protocol LoginService {
    func login(token: String) async throws -> TokenResponse
}
