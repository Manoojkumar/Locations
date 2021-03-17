//
//  LocationConstant.swift
//  Location
//
//  Created by Mano on 16/03/21.
//

import Foundation
import UIKit

public class LocationConstant  {

    static let Location_Local_Data = UserDefaults.standard
    
    struct Keys{
        static let appState = "Active"
    }
    
    static func showToast(message : String) {
        let view = UIApplication.topMostViewController?.view
        let toastLabel = UILabel(frame: CGRect(x: view!.frame.size.width/2 - 75, y:  view!.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view!.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    static func timeDifferenceFromString(timeA: String,timeB: String) -> Int{
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "hh:mm a"
        timeformatter.timeZone = TimeZone(identifier: "UTC")
        timeformatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let time1 = timeformatter.date(from: timeA),let time2 = timeformatter.date(from: timeB) else { return 0 }
        let interval = time2.timeIntervalSince(time1)
       // let hour = interval / 3600;
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
       // let intervalInt = Int(interval)
        
        return Int(minute)
    }
}
