//
//  TokenService.swift
//  Indotica
//
//  Created by Nicolas Llanos on 23/02/2024.
//

import Foundation

class TokenService {
    static var shared = TokenService()
    private var requestHandler = RequestHandler()
    
    func getToken(data: TokenRequest, completion: @escaping (TokenResponse?,Error?) -> Void) {
        requestHandler.requestdata(path: "http://192.168.2.13:4552/auth/tokenLogin", type: TokenResponse.self, method: .post) { rta, err in
            DispatchQueue.main.async {
                completion(rta,err)
            }
        }
    }
    
}
