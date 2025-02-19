//
//  MapViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

/// ViewModel para gestionar la lógica de la vista del mapa.
class MapViewModel: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var searchLocation: CLLocationCoordinate2D?
    @Published var isSearchActive: Bool = false
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func searchAddress(_ query: String) {
        if query.isEmpty {
            searchResults = []
            clearSearch()
            return
        }
        searchCompleter.queryFragment = query
    }
    
    func selectSearchResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                return
            }
            
            DispatchQueue.main.async {
                self?.searchLocation = coordinate
                self?.searchResults = []
                self?.isSearchActive = true
            }
        }
    }
    
    func clearSearch() {
        searchLocation = nil
        searchResults = []
        isSearchActive = false
    }
}

extension MapViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error en la búsqueda: \(error.localizedDescription)")
    }
}