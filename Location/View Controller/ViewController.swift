//
//  ViewController.swift
//  GetLocation
//
//  Created by Mano on 16/03/21.
//

import UIKit
import CoreLocation
import MapKit
class ViewController: UIViewController {
   
    @IBOutlet weak var startOrStopBtn: UIBarButtonItem!
    @IBOutlet weak var locationTableView: UITableView!
    
    
    let locationManager = CLLocationManager()
    var start = false
    let userDefaults = UserDefaults.standard
    var locationList: [LocationDetails] = []
    
    fileprivate var locationViewModel = LocaitionControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Locations"
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.showsBackgroundLocationIndicator = true
        self.locationManager.pausesLocationUpdatesAutomatically = false

        
        self.locationList = CoreDataStore.fetchLocations()
        self.locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        self.locationTableView?.dataSource = locationViewModel
        
        self.getLocationPermission(){ permission in
            print("permission")
        }
        callToViewModelForUIUpdate()
        
    }
    
    
    // tableview cells updates
    func callToViewModelForUIUpdate(){
        let data = CoreDataStore.fetchLocations()
        self.locationList = CoreDataStore.fetchLocations()
        self.locationViewModel.refreshWith(data: data, {
            self.locationTableView.reloadData()
           
        })
        
    }
    func startUpdatingLocation(){
        if (CLLocationManager.locationServicesEnabled()){
            self.locationManager.stopUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            self.callToViewModelForUIUpdate()
        }
    }
    
    func stopUpdatingLocation(){
        if self.locationList.count > 0{
            
            guard let lastTime = self.locationList.last?.time else{
                return
            }
            let data = CoreDataStore.updateLocation(time: lastTime)
            data?.first?.locationStatus = "stopped"
            do {
                try CoreDataStore.getContext().save()
                self.locationManager.stopUpdatingLocation()
            } catch {
                print("Failed saving")
            }
        }else{
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func didTapStartBtn(_ sender: UIBarButtonItem) {
        if ReachabilityOld.isConnectedToNetwork(){
            if start == false{
                self.getLocationPermission(){ permission in
                    if permission == true{
                        let _ = CoreDataStore.deleteAllData() { success in
                            if success == true{
                                self.start = true
                                LocationConstant.showToast(message: "Started")
                                self.startUpdatingLocation()
                                self.startOrStopBtn.title = "stop"
                            }
                        }
                    }else{
                        self.start = false
                        self.startOrStopBtn.title = "start"
                        self.stopUpdatingLocation()
                        LocationConstant.showToast(message: "Need Permission")
                    }
                }
            }else{
                self.start = false
                self.startOrStopBtn.title = "start"
                LocationConstant.showToast(message: "Stopped")
                stopUpdatingLocation()
            }
        }else{
            self.start = false
            self.startOrStopBtn.title = "start"
            self.stopUpdatingLocation()
            LocationConstant.showToast(message: "No Internet Connection")
        }
    }
    
    
    func getLocationPermission(completionHandler: @escaping(_ permission: Bool) -> Void){
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            completionHandler(false)
        case .denied, .restricted:
            completionHandler(false)
            let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            alert.addAction(okAction)
            //self.present(alert, animated: true, completion: nil)
            UIApplication.topMostViewController!.present(alert, animated: true, completion: nil)
        case .authorizedAlways, .authorizedWhenInUse:
            completionHandler(true)
        default:
            break
        }
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = locationList[indexPath.row]
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let controller : MapViewController? = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        controller?.lattitude = Double((item.latitude)!)
        controller?.longitude = Double((item.longitude)!)
        self.present(controller!, animated: true, completion: nil)
    }

}

extension ViewController: CLLocationManagerDelegate{
    
    func getCurrentDateAndTime() -> String{
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        return timestamp
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        getAddress(latitude: center.latitude, longitude: center.longitude)
        //setup(latitude: center.latitude, longitude: center.longitude)
    }
    
    func setup(latitude: CLLocationDegrees,longitude: CLLocationDegrees){
        let time = getCurrentDateAndTime()
        if locationList.count >= 1{
            let lastTime = locationList.last!.time
            let difference = LocationConstant.timeDifferenceFromString(timeA:lastTime!,timeB: time)
            if difference == 1{
                self.saveToCoreData(latitude: "\(latitude)", longitude: "\(longitude)", appState: "active", city: "Coimbatore", time: time)
            }
        }else{
            if locationList.count == 0{
                self.saveToCoreData(latitude: "\(latitude)", longitude: "\(longitude)", appState: "active", city:"Coimbatore", time: time)
            }
        }
    }
    
    func getAddress(latitude: CLLocationDegrees,longitude: CLLocationDegrees){
        let location = CLLocation(latitude: latitude, longitude: longitude)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            
            guard let placemark = placemarks?.first else {
                let errorString = error?.localizedDescription ?? "Unexpected Error"
                print("Unable to reverse geocode the given location. Error: \(errorString)")
                //LocationConstant.showToast(message: "Can't get geolocation.Setting Default location")
                //self.saveSetup(latitude: "\(latitude)", longitude: "\(longitude)", city: nil)
                return
            }
            
            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [self] in
                self.saveSetup(latitude: "\(latitude)", longitude: "\(longitude)", city: reversedGeoLocation.city)
            })
        }
    }
    
    func saveSetup(latitude: String,longitude: String,city: String?){
        let time = getCurrentDateAndTime()
        guard let appState = self.userDefaults.object(forKey: "appState") as? String else {
            return
        }
        var cityName = ""
        if city != nil{
            cityName = city!
        }else{
            cityName = "Chennai"
        }
        
        if locationList.count >= 1{
            let lastTime = locationList.last!.time
            let difference = LocationConstant.timeDifferenceFromString(timeA:lastTime!,timeB: time)
            if difference == 10{
                self.saveToCoreData(latitude: "\(latitude)", longitude: "\(longitude)", appState: appState, city: cityName, time: time)
            }
        }else{
            if locationList.count == 0{
                self.saveToCoreData(latitude: "\(latitude)", longitude: "\(longitude)", appState: appState, city: cityName, time: time)
            }
        }
    }
    
    
    func saveToCoreData(latitude: String,longitude: String,appState: String,city: String,time: String){
        let _ = CoreDataStore.saveLocationDetails(latitude: latitude, longitude: longitude, appState: appState, city: city, time: time, locationStatus: "on-going") { (success) in
            if success == true{
                self.locationList = CoreDataStore.fetchLocations()
                self.callToViewModelForUIUpdate()
            }
        }
    }
}



