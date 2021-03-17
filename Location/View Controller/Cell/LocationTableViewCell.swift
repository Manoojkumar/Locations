//
//  LocationTableViewCell.swift
//  GetLocation
//
//  Created by Mano on 16/03/21.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var latitudeLbl: UILabel!
    
    @IBOutlet weak var longitudeLbl: UILabel!
    
    var locationData : LocationDetails? {
        didSet {
            cityName.text = locationData?.city
            timeLbl.text = locationData?.time
            statusLbl.text = locationData?.appState
            latitudeLbl.text = locationData?.latitude
            longitudeLbl.text = locationData?.longitude
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//import Foundation
//
//class LocationModel {
//    var latitude: String
//    var longitude: String
//    var city: String
//    var time: String
//    var appState: String
//
//    init(latitude: String,longitude: String,city: String,appState: String,time: String) {
//        self.latitude = latitude
//        self.longitude = longitude
//        self.city = city
//        self.appState = appState
//        self.time = time
//    }
//}
