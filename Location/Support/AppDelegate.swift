//
//  AppDelegate.swift
//  Location
//
//  Created by Mano on 16/03/21.
//

import UIKit
import CoreData
import CoreLocation
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var locationData: [LocationDetails] = []
    let userDefault = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.locationManager.requestAlwaysAuthorization()
        userDefault.set("Background", forKey: "appState")
       
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        userDefault.set("Active", forKey: "appState")
    }
    func applicationWillTerminate(_ application: UIApplication) {
       print("terminated")
        self.locationData = CoreDataStore.fetchLocations()
        
        if locationData.count > 0{
            guard let locationStatus = locationData.last?.locationStatus else{
                return
            }
            if locationStatus == "on-going"{
                guard let lastTime = locationData.last?.time else{
                    return
                }
                let data = CoreDataStore.updateLocation(time: lastTime)
                data?.first?.appState = "Terminated"
                do {
                    try CoreDataStore.getContext().save()
                } catch {
                    print("Failed saving")
                }
            }
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        userDefault.set("In-Active", forKey: "appState")
    }
    

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Location")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//extension AppDelegate: CLLocationManagerDelegate{
//    func setupLocation(){
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.allowsBackgroundLocationUpdates = true
//        self.locationManager.pausesLocationUpdatesAutomatically = false
//    }
//    
//    func startUpdatingLocation(){
//        if (CLLocationManager.locationServicesEnabled()){
//            self.locationManager.stopUpdatingLocation()
//            self.locationManager.startUpdatingLocation()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        
//        let location = locations.last! as CLLocation
//        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        getAddress(latitude: center.latitude, longitude: center.longitude){ reloadData in
//            print(reloadData)
//        }
//    }
//    func getCurrentDateAndTime() -> String {
//        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
//        return timestamp
//    }
//    
//    func getAddress(latitude: CLLocationDegrees,longitude: CLLocationDegrees,completionHandler: @escaping(_ reloadData: Bool) -> Void){
//        let time = getCurrentDateAndTime()
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        print("location:::: \(latitude)")
//        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//            guard let placemark = placemarks?.first else {
//                let errorString = error?.localizedDescription ?? "Unexpected Error"
//                print("Unable to reverse geocode the given location. Error: \(errorString)")
//                return
//            }
//            
//            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [self] in
//                
//                if locationData.count >= 1{
//
//                   let lastTime = locationData.last!.time
//                   let difference = self.timeDifferenceFromString(timeA:lastTime,timeB: time)
//                    print(difference)
//                    if difference == 1{
//                        let addLocationData = LocationModel(latitude: "\(latitude)", longitude: "\(longitude)", city: reversedGeoLocation.city, appState: "Active", time: time)
//                        self.locationData.append(addLocationData)
//                        completionHandler(true)
//                    }
//                }else{
//                    if locationData.count == 0{
//                        let addLocationData = LocationModel(latitude: "\(latitude)", longitude: "\(longitude)", city: reversedGeoLocation.city, appState: "Active", time: time)
//                        self.locationData.append(addLocationData)
//                        completionHandler(true)
//                    }
//                    
//                    print("locationData.count \(locationData.count)")
//                }
//
//            })
//        }
//    }
//    
//    func timeDifferenceFromString(timeA: String,timeB: String) -> Int{
//        let timeformatter = DateFormatter()
//        timeformatter.dateFormat = "hh:mm a"
//        timeformatter.timeZone = TimeZone(identifier: "UTC")
//        timeformatter.locale = Locale(identifier: "en_US_POSIX")
//        guard let time1 = timeformatter.date(from: timeA),let time2 = timeformatter.date(from: timeB) else { return 0 }
//        let interval = time2.timeIntervalSince(time1)
//        //let hour = interval / 3600;
//        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
//       // let intervalInt = Int(interval)
//        
//        return Int(minute)
//
//    }
//    
//}
