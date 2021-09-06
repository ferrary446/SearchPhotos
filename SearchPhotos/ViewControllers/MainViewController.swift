//
//  ViewController.swift
//  SearchPhotos
//
//  Created by Ilya Yushkov on 31.08.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet var searchButtonOutlet: UIButton!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredResults: [Results] = []
    
    private var searchBarIsEmpty: Bool {
        
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
        
    }
    
    private var isFiltering: Bool {
        
        return searchController.isActive && !searchBarIsEmpty
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        configureButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showResponse" {
            
            if let collectionVC = segue.destination as? CollectionViewController {
                
                collectionVC.filteredResults = filteredResults
            }
            
        }
    }
    
    @IBAction func searchButtonPressed() {
        
        if isFiltering {
            
            NetworkManager.shared.fetchPhoto(query: searchController.searchBar.text!) { photos in
                
                self.filteredResults = photos.results
                self.performSegue(withIdentifier: "showResponse", sender: self)
            }
        } else {
            
            showAlert(with: "Ошибка", and: "Пожалуйста введите запрос!")
        }
    }
    
    // MARK: - Search controller
    private func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Alert controller
    private func showAlert(with title: String, and message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    private func configureButton() {
        
        searchButtonOutlet.backgroundColor = .systemBlue
        searchButtonOutlet.layer.cornerRadius = 5
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredResults = filteredResults.filter { results in
            results.urls.regular.lowercased().contains(searchText.lowercased())
        } 
    }
}
