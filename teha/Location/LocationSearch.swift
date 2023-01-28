//
//  LocationSearch.swift
//  teha
//
//  Created by Nurullah Keskin on 20.01.23.
//


/*
 LocationSearch in an utility class for the LocationPicker, furthermore it takes the input from the Search EditBox
 and with the help of Mapkit/MKLocalSearchCompleter it gives real time complete suggestions to the given input
 */


import Foundation
import MapKit
import Combine

class LocationSearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate{
    
    @Published var location: CLLocationCoordinate2D?
    @Published var address: String = ""
    @Published var input: String = ""
    @Published var region: MKCoordinateRegion
    @Published var searchResults = [MKLocalSearchCompletion]()
    
    var searchCompleter = MKLocalSearchCompleter()
    var publisher: AnyCancellable?
    
    
    override init() {
        let latitude = 0
        let longitude = 0
        self.region = MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:
                                                                        CLLocationDegrees(latitude), longitude:CLLocationDegrees(longitude)),span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        super.init()
        searchCompleter.delegate = self
        self.searchCompleter.resultTypes = [.address, .pointOfInterest]
        self.publisher = $input.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (str) in
            self?.searchCompleter.queryFragment = str
        })
    }
    
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    
    
    
    func getCoordinatesFromAddress(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let coord = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(coord)
        }
    }
}
