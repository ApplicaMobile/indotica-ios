//
//  TokenResponse.swift
//  Indotica
//
//  Created by Nicolas Llanos on 23/02/2024.
//

import Foundation

struct TokenResponse: Codable {
    var notification: Notification?
}

struct Notification: Codable {
    var message: String?
    var status: String?
    var token: String?
}
