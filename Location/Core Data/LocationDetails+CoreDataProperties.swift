//
//  LocationDetails+CoreDataProperties.swift
//  Location
//
//  Created by BSSADM on 16/03/21.
//
//

import Foundation
import CoreData


extension LocationDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationDetails> {
        return NSFetchRequest<LocationDetails>(entityName: "LocationDetails")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var appState: String?
    @NSManaged public var time: String?
    @NSManaged public var city: String?
    @NSManaged public var locationStatus: String?

}

extension LocationDetails : Identifiable {

}
