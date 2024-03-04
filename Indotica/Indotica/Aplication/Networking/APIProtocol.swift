//
//  APIProtocol.swift
//  Indotica
//
//  Created by Ariel Scarafia on 27/01/2023.
//

import Foundation

protocol APIProtocol {
    func get<T: Decodable>(endpoint: String, query: [URLQueryItem]) async throws -> T
    
    func post<T: Decodable>(endpoint: String, query: [URLQueryItem], requestData: EncodableRequest?) async throws -> T //TODO ver este opcional EncodableRequest?
    
    func put<T: Decodable>(endpoint: String, query: [URLQueryItem], requestData: EncodableRequest) async throws -> T
    
    func delete<T: Decodable>(endpoint: String, query: [URLQueryItem]) async throws -> T?
    
}
