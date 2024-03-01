//
//  Env.swift
//  Indotica
//
//  Created by Augusto Herbel on 18/07/2022.
//

import Foundation

public enum Env : String {
    
    case scheme = "SCHEME"
    case host = "HOST"
    case description = "DESCRIPTION"
    case port = "PORT"
    
    static let infoPlist: [String: Any] = {
        guard let info = Bundle.main.infoDictionary else { return [:] }
        return info
    }()
    
    var val: String { return Env.infoPlist[self.rawValue] as? String ?? "" }
    
    var intVal: Int? { return Env.infoPlist[self.rawValue] as? Int }
}
