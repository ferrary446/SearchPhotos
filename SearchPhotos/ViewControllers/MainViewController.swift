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
    
    private var total: Int?
    
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
        setupNavigationBar()
        configureButton()
        
        self.searchController.searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showResponse" {
            
            if let collectionVC = segue.destination as? CollectionViewController {
                
                collectionVC.filteredResults = filteredResults
            }
        }
    }
    
    @IBAction func searchButtonPressed() {
        
        if isFiltering {
            
            fetchData()
            
        } else {
            
            showAlert(with: "Ошибка", and: "Пожалуйста введите запрос!")
        }
    }
    
    // MARK: - Search controller
    private func setupSearchController() {
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.barTintColor = UIColor.white
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.font = UIFont.boldSystemFont(ofSize: 17)
            textField.textColor = .white
        }
    }
    
    // MARK: - Navigation bar
    private func setupNavigationBar() {
        
        // Navigation bar appearance
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .black
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    // MARK: - Alert controller
    private func showAlert(with title: String, and message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Custom button
    private func configureButton() {
        
        searchButtonOutlet.backgroundColor = .systemBlue
        searchButtonOutlet.layer.cornerRadius = 5
    }
    // MARK: - Get data from NetworkManager
    private func fetchData() {
        
        NetworkManager.shared.fetchPhoto(query: searchController.searchBar.text!) { results in
            
            switch results {
            
            case .success(let photos):
                
                self.filteredResults = photos.results
                self.total = photos.total
                
            case .failure(let error):
                print(error)
            }
            
            if self.total != 0 {
                
                self.performSegue(withIdentifier: "showResponse", sender: self)
            }
            else {
                
                self.showAlert(with: "Упс", and: "Ничего не найдено, повторите запрос!")
            }
        }
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredResults = filteredResults.filter { results in
            
            results.urls.regular.lowercased().contains(searchText.lowercased())
        } 
    }
}
