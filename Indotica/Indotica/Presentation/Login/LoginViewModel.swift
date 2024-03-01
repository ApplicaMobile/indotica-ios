//
//  LoginViewModel.swift
//  Indotica
//
//  Created by Nicolas Llanos on 01/03/2024.
//

import Combine
import Foundation

class LoginViewModel {
    
    private let loginRepository: LoginService
    private let userDefault: UserDefaultsManager
    
    public init(loginRepository: LoginService, userDefault: UserDefaultsManager) {
        self.loginRepository = loginRepository
        self.userDefault = userDefault
    }
    
    @Published private(set) var spinner: Bool = false
    @Published private(set) var toastMessage: String?
    
    @Published private(set) var loginSuccessFull: Bool = false
    
    private func showSpinner() {
        spinner = true
    }

    private func hideSpinner() {
        spinner = false
    }
    
    func login(token: String) {
        showSpinner()
        Task {
            do {
                let response = try await loginRepository.login(token: token)
                if let token = response.notification?.token {
                    userDefault.updateToken(token)
                    loginSuccessFull = true
                } else {
                    throw IOError.invalidParameter("Invalid token", response)
                }
            } catch {
                //TODO: localize errors
                toastMessage = "Error de login"
            }
            hideSpinner()
        }
    }
}
