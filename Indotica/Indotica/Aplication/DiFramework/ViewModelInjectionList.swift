//
//  ViewModelInjectionList.swift
//  Indotica
//
//  Created by Ariel Scarafia on 31/03/2023.
//

import Foundation

private struct LoginViewModelKey: InjectionKey {
    static var computedValue: LoginViewModel {
        @Injected(\.loginRepositoryProvider) var loginRepository: LoginService
        @Injected(\.userDefaultsProvider) var userDefaultRepository: UserDefaultsManager
        
        return LoginViewModel(loginRepository: loginRepository, userDefault: userDefaultRepository)
    }
    static var currentValue = computedValue
}

extension InjectedValues {
    var loginViewModelProvider: LoginViewModel {
        get { Self[LoginViewModelKey.self] }
        set { Self[LoginViewModelKey.self] = newValue }
    }
}
