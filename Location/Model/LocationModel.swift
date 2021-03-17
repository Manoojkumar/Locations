//
//  LocationModel.swift
//  GetLocation
//
//  Created by Mano on 16/03/21.
//

import Foundation

class LocationModel : NSObject {
    
    //private var apiService : APIService!
    
    private(set) var locationData : [LocationDetails]! {
        didSet {
            self.bindLocationViewModelToController()
        }
    }
    
    var bindLocationViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        callFuncToGetEmpData()
    }
    
    func callFuncToGetEmpData() {
        let data = CoreDataStore.fetchLocations()
        self.locationData = data

    }
}
