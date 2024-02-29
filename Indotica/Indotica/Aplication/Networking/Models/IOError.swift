//
//  IOError.swift
//  Indotica
//
//  Created by Ariel Scarafia on 25/01/2023.
//

import Foundation

enum IOError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
    case invalidDecoderConfiguration
    case responseError
    case responseErrorCode(Int)
}
