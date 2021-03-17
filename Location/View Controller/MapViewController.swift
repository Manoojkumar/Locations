//
//  MapViewController.swift
//  GetLocation
//
//  Created by Mano on 17/03/21.
//

import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var lattitude : Double?
    var longitude : Double?
    
   
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
    }

    func addMap(){
        map.mapType = MKMapType.standard
        let center = CLLocationCoordinate2D(latitude: lattitude!, longitude: longitude!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.map.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "You Are Here"
        annotation.subtitle = "congratulations"
        self.map.addAnnotation(annotation)
    }
    
}
