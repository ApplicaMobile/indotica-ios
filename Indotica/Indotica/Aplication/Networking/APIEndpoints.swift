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
    static let port = Env.port.intVal
    static let token = "/auth/tokenLogin"
}
