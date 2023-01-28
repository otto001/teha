//
//  LocationSearch.swift
//  teha
//
//  Created by Nurullah Keskin on 20.01.23.
//



/**
     LocationSearch in an utility class for the LocationPicker, furthermore it takes the input from the Search EditBox
     and with the help of Mapkit/MKLocalSearchCompleter it gives real time complete suggestions to the given input.
*/

import Foundation
import MapKit
import Combine

class LocationSearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate{
    
    @Published var address: String = ""
    @Published var input: String = "" //input from the EditBox
    @Published var region: MKCoordinateRegion
    @Published var searchResults = [MKLocalSearchCompletion]() //RealTime list of the SearchCompleter
    
    var searchCompleter = MKLocalSearchCompleter()
    var publisher: AnyCancellable?
    
    
    override init() {
        //Initializes a region, since its nescessary for the MKLocalSearchCompleterDelegate constructor
        let latitude = 0
        let longitude = 0
        self.region = MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:
                                                                        CLLocationDegrees(latitude), longitude:CLLocationDegrees(longitude)),span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        super.init()
        
        searchCompleter.delegate = self
        
        self.searchCompleter.resultTypes = [.address, .pointOfInterest] // Only Addresses and pointOfInterests (as in malls, supermarkets, restaurants etc.) are accepted as a result.
        
        self.publisher = $input.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (str) in // Constantly reloading the results, if something changes
            self?.searchCompleter.queryFragment = str
        })
    }
    
    
    /**
        completerDidUpdateResults updates searchResults
    */
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    
    
    /**
     getCoordinatesFromAddress gets the latitude and longtitude from a given address. After it has the address, it triggers the completion handler with a CLLocationCoordinate2D
     if it found it, otherwise transmits nil.
        - Parameters:
            - address: String value of the given address
            - completion: A completion handler

    */
    func getCoordinatesFromAddress(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let coord = placemarks.first?.location?.coordinate else {
                completion(nil) // No coordinates found, transmits a nil value
                return
            }
            completion(coord) // Coordinates found, transmits CLLocationCoordinate2D object with the coordinates to the address
        }
    }
}
