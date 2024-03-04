//
//  InjectionKeyList.swift
//  Indotica
//
//  Created by Ariel Scarafia on 28/03/2023.
//

import Foundation

private struct UserDefaultsKey: InjectionKey {
    static var computedValue: UserDefaultsManager = UserDefaultsManager()
    static var currentValue = computedValue
}

private struct APIServiceKey: InjectionKey {
    static var computedValue: APIProtocol {
        @Injected(\.userDefaultsProvider) var userDefaults: UserDefaultsManager
        
        return APIService(userDefault: userDefaults)
    }
    static var currentValue = computedValue
}

private struct LoginRepositoryKey: InjectionKey {
    typealias Value = LoginService

    static var computedValue: LoginService {
        @Injected(\.apiServiceProvider) var apiService: APIProtocol
        
        return LoginRepository(apiService: apiService)
    }
    
    static var currentValue = computedValue
}


extension InjectedValues {
    
    var userDefaultsProvider: UserDefaultsManager {
        get { Self[UserDefaultsKey.self] }
        set { Self[UserDefaultsKey.self] = newValue }
    }
    
    var apiServiceProvider: APIProtocol {
        get { Self[APIServiceKey.self] }
        set { Self[APIServiceKey.self] = newValue }
    }
    
    var loginRepositoryProvider: LoginService {
        get { Self[LoginRepositoryKey.self] }
        set { Self[LoginRepositoryKey.self] = newValue }
    }
}
