//
//  GeoMonitor.swift
//  teha
//
//  Created by Nurullah Keskin on 20.01.23.
//


import CoreLocation
import CoreData

class GeoMonitor: NSObject, ObservableObject, CLLocationManagerDelegate{
    static let shared = GeoMonitor()
    
    var locationManager = CLLocationManager()
    
    override init(){
        super.init()
        
        locationManager.delegate = self
    }
    
    /**
     Registers the location of a given task for monitoring
     - Parameters:
     - task: A THTask CoreData Object ob the given task, which should get monitored
     */
    func startMonitoringTaskLocation(task: THTask){
//        if (locationManager.authorizationStatus != .authorizedAlways) {
//            requestLocationPermissions()
//        }
//        let currentlymonitoredRegions = locationManager.monitoredRegions
//        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) && currentlymonitoredRegions.count < 20 {
//            let coordinates = createCoordinates(lat: task.lat, long: task.long)
//            let identifier = task.objectID.uriRepresentation().absoluteString
//            let region = createRegionForCoordinates(coordinates: coordinates, identifier:identifier)
//            locationManager.startMonitoring(for: region)
//        }
    }
    
    /**
     Removes the location which is getting monitored for the given Task
     - Parameters:
     - task: A THTask CoreData Object ob the given task, which should removed from monitoring
     */
    func stopMonitoringTaskLocation(task:THTask) {
//        let coordinates = createCoordinates(lat: task.lat, long: task.long)
//        let region = createRegionForCoordinates(coordinates: coordinates , identifier: "TODO")
//        locationManager.stopMonitoring(for: region)
    }
    
    /**
     Refreshes the monitoring state
     - Parameters:
     - task: A THTask CoreData Object ob the given task, which should removed from monitoring
     */
    func refreshLocationMonitoring(task:THTask) {
//        stopMonitoringTaskLocation(task: task)
//        if task.address != "" && !task.isCompleted {
//            startMonitoringTaskLocation(task: task)
//        }
    }
    
    
    /**
     Creates a region with a static distance radius of 30 metres
     - Parameters:
     - coordinates: A CLocationCoordinate2D object, which holds the latitude and longtitude
     - identifier: A unique identifier for the new region
     - Returns:
     A CLCircularRegion object is getting returned with the given coordinates and properties
     */
    private func createRegionForCoordinates(coordinates:CLLocationCoordinate2D, identifier:String) -> CLCircularRegion {
        let maxDistance = 200 // The radius for the circle around the given coordinates
        let region = CLCircularRegion(
            center: coordinates,
            radius: CLLocationDistance(maxDistance),
            identifier: identifier)
        region.notifyOnEntry = true // notifyOnEntry describes whether when this region is getting monitored, if it should trigger on entering the region
        region.notifyOnExit = false // notifyOnExit describes whether when this region is getting monitored, if it should trigger on leaving the region
        return region
    }
    
    
    /**
     Creates a CLLocationCoordinate2D object which contains the given coordinates.
     - Parameters:
     - lat: A double value describing the latitude
     - long: A double value describing the longtitude
     - Returns:
     A CLLocationCoordinate2D which is holding the coordinates in one Object
     */
    func createCoordinates(lat:Double, long: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
    }
    
    
    /**
     LocationManager method getting called if a monitored region is entered. It handles the identifier and triggers a notification
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        DispatchQueue.main.async {
//            if let region = region as? CLCircularRegion {
//                let identifier = region.identifier
//                if let url = URL(string: identifier) { //Converts the identifier of the region into an URL Object, since the identifiers are converted Object IDs
//                    let container = PersistenceController.shared.container
//                    
//                    
//                    guard let objectID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else { // If an ObjectID isn't found by the given URL it breaks
//                        print("ObjectID not found!")
//                        return
//                    }
//                    let task = container.viewContext.object(with: objectID) // Fetches the object from the objectID
//                    guard let task = task as? THTask else { return } //Typecasts the object into a THTask object
//                    let now = Date.now
//                    
//                    if task.earliestStartDate != nil && task.deadline != nil {
//                        if (now >= task.earliestStartDate!) {
//                            if (now < task.deadline!) {
//                                NotificationManager.instance.displayLocationNotificationNow(title: task.title, requestIdentifier: identifier, offset: 1)
//                            } else {
//                                self.stopMonitoringTaskLocation(task: task)
//                            }
//                        }
//                    } else if task.earliestStartDate != nil && task.deadline == nil {
//                        if(now >= task.earliestStartDate!) {
//                            NotificationManager.instance.displayLocationNotificationNow(title: task.title, requestIdentifier: identifier, offset: 1)
//                        }
//                    } else if task.earliestStartDate == nil && task.deadline != nil {
//                        if (now < task.deadline!) {
//                            NotificationManager.instance.displayLocationNotificationNow(title: task.title, requestIdentifier: identifier, offset: 1)
//                        } else{
//                            self.stopMonitoringTaskLocation(task: task)
//                        }
//                    } else {
//                        NotificationManager.instance.displayLocationNotificationNow(title: task.title, requestIdentifier: identifier, offset: 1)
//                    }
//                }
//            }
//        }
    }
    
    /**
     Request always location permission and also when app is in use location permissions.
     */
    func requestLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    /**
     LocationManager method getting called if a something changes with the location authorization
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            print("No Location access granted!")
        case .authorizedWhenInUse:
            print("Location partly granted, needs always access!")
            requestLocationPermissions()
        case .authorizedAlways:
            print("Location access granted!")
        @unknown default:
            break
        }
    }
}
