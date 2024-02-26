//
//  UserDefaultsManager.swift
//  Indotica
//
//  Created by Nicolas Llanos on 26/02/2024.
//

import Foundation
class UserDefaultsManager: NSObject {
    
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private override init() {
        super.init()
    }
    
    private enum DefaultsKey: String, CaseIterable {
        case userToken
    }
    
    var userToken: String {
        get { defaults.string(forKey: DefaultsKey.userToken.rawValue) ?? ""}
        set { defaults.setValue(newValue, forKey:  DefaultsKey.userToken.rawValue) }
    }
}
