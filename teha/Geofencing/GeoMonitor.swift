//
//  GeoMonitor.swift
//  teha
//
//  Created by Nurullah Keskin on 20.01.23.
//


import CoreLocation
import CoreData

class GeoMonitor: NSObject,ObservableObject, CLLocationManagerDelegate{
    var locationManager = CLLocationManager()
    
    
    
    override init(){
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoringTaskLocation(task:THTask){
        let currentlymonitoredRegions = locationManager.monitoredRegions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) && currentlymonitoredRegions.count < 20 {
            let coordinates = createCoordinates(lat: task.lat, long: task.long)
            let identifier = task.objectID.uriRepresentation().absoluteString
            let region = createRegionForCoordinates(coordinates: coordinates, identifier:identifier)
            locationManager.startMonitoring(for: region)
        }
    }
    
    func stopMonitoringTaskLocation(task:THTask){
        let coordinates = createCoordinates(lat: task.lat, long: task.long)
        let region = createRegionForCoordinates(coordinates: coordinates , identifier: "TODO")
        locationManager.stopMonitoring(for: region)
    }
    
    func refreshLocationMonitoring(task:THTask){
        stopMonitoringTaskLocation(task: task)
        if task.address != "" {
            startMonitoringTaskLocation(task: task)
        }
    }
    
    private func createRegionForCoordinates(coordinates:CLLocationCoordinate2D, identifier:String) -> CLCircularRegion{
        let maxDistance = 30
        let region = CLCircularRegion(
            center: coordinates,
            radius: CLLocationDistance(maxDistance),
            identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    func createCoordinates(lat:Double, long: Double) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            if let url = URL(string: identifier){
                lazy var persistentContainer: NSPersistentContainer = {
                    let container = NSPersistentContainer(name: "teha")
                    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                        if let error = error {
                            fatalError("Unresolved error \(error), \(error)")
                        }
                    })
                    return container
                }()
                
                
                let objectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
                print(region.identifier)
                let task = persistentContainer.viewContext.object(with: objectID!)
                if let task = task as? THTask {
                    //TODO: Add condition of earliestdate/deadline and connect to Notifcations
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        let statusCode = locationManager.authorizationStatus
        switch statusCode {
        case .notDetermined, .restricted, .denied:
            print("No access")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
        @unknown default:
            break
        }
    }
}
