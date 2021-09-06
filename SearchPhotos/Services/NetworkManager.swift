//
//  NetworkManager.swift
//  SearchPhotos
//
//  Created by Ilya Yushkov on 31.08.2021.
//
import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Get data from API
    func fetchPhoto(query: String, with complition: @escaping(Result<Photos, Error>) -> Void) {
        
        let stringUrl = "https://api.unsplash.com/search/photos?page=1&query=\(query)&client_id=\(apiKey)"
        
        guard let url = URL(string: stringUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            guard let data = data else {
                
                print(error?.localizedDescription ?? "No Description")
                return
            }
            
            do {
                
                let photos = try JSONDecoder().decode(Photos.self, from: data)
                
                DispatchQueue.main.async {
                    complition(.success(photos))
                }
                
            } catch let error {
                complition(.failure(error))
            }
            
        }.resume()
    }
}

class ImageManager {
    
    static let shared = ImageManager()
    
    private init() {}
    
    // MARK: - Get image data
    func configureCell(with stringUrl: String, complition: @escaping (Data) -> Void) {
        
        guard let url = URL(string: stringUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                complition(data)
            }
            
        }.resume()
    }
}
