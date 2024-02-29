//
//  UserDefaultsManager.swift
//  Indotica
//
//  Created by Nicolas Llanos on 26/02/2024.
//

import Foundation
class UserDefaultsManager: NSObject {
    
    private let defaults = UserDefaults.standard
    
    private enum DefaultsKey: String, CaseIterable {
        case userToken
    }
    
    private (set) var userToken: String? {
        get { defaults.string(forKey: DefaultsKey.userToken.rawValue) ?? ""}
        set { defaults.setValue(newValue, forKey:  DefaultsKey.userToken.rawValue) }
    }
    
    func clearToken() {
        userToken = nil
    }
    
    func updateToken(_ newToken: String) {
        userToken = newToken
    }
}
