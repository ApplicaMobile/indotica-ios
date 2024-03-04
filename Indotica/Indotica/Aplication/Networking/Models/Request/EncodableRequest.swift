//
//  APIKeysRequest.swift
//  Indotica
//
//  Created by Leandro Berli on 22/09/2021.
//

import Foundation

typealias EncodableRequest = PropertyLoopable & Encodable

protocol PropertyLoopable
{
    func asQueyItems() -> [URLQueryItem]?
}

extension PropertyLoopable {
    
    func asQueyItems() -> [URLQueryItem]? {
        
        var result: [URLQueryItem] = []
        
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return nil
        }
        
        for (property,value) in mirror.children {
            guard let property = property else {
                continue
            }
            if case Optional<Any>.none = value  {
                continue
            }
            result.append(URLQueryItem(name: property, value: String(describing: value)))
        }
        
        return result
    }
    
    func asString() -> String? {
        var result = ""
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            return nil
        }
        
        for (property,value) in mirror.children {
            guard let property = property else {
                continue
            }
            if case Optional<Any>.none = value  {
                continue
            }
            result.append("\(property):\(String(describing: value)), ")
        }
        
        return result
    }
}

extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
    func toJSONString() -> String {
        guard let d = self.toJSONData()  else { return ""}
        return String(decoding: d, as: UTF8.self).replacingOccurrences(of: "\\", with: "")
    }
    
}
