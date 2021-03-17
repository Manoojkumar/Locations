//
//  LocationTableViewDataSource.swift
//  GetLocation
//
//  Created by Mano on 16/03/21.
//


import Foundation
import UIKit

class LocaitionControllerViewModel: NSObject {
    var items = [Any]()
   
    func refreshWith(data: [Any], _ completionBlock : @escaping ()->()) {
        self.items = data
        completionBlock()
    }
}

extension LocaitionControllerViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell {
                cell.locationData = item as? LocationDetails
                
                return cell
            }
        return UITableViewCell()
    }
    
    
}

