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
    
    func getToken(completion: @escaping (TokenResponse?,Error?) -> Void) {
        requestHandler.requestdata(path: ApiInfo.token, type: TokenResponse.self, method: .delete) { rta, err in
            DispatchQueue.main.async {
                completion(rta,err)
            }
        }
    }
    
}
