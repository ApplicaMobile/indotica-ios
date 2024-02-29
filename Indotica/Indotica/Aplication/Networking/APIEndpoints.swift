//
//  APIEndpoints.swift
//  Indotica
//
//  Created by Ariel Scarafia on 27/01/2023.
//

import Foundation

struct APIEndpoints {
    //TODO: Add base url to environment 
    static let scheme = Env.scheme.val
    static let host = Env.host.val
    static let baseURL = "://192.168.2.13:4552/"
    static let token = "auth/tokenLogin"
}
