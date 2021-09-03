//
//  Photos.swift
//  SearchPhotos
//
//  Created by Ilya Yushkov on 31.08.2021.
//

struct Photos: Decodable {
    
    let total: Int
    let totalPages: Int
    let results: [Results]
    
    enum CodingKeys: String, CodingKey {
        case total = "total"
        case totalPages = "total_pages"
        case results = "results"
    }
}

struct Results: Decodable {
    
    let urls: URLs
}

struct URLs: Decodable {
    
    let regular: String
}

