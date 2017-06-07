//
//  LocationManager.swift
//  Goet
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import CoreLocation
import UIKit

// Singleton class
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    fileprivate var locationManager = CLLocationManager()
    var completion: ((_ location: CLLocation) -> Void)?
    var completionWithError: ((_ error: Error) -> Void)?
    var updateCount = 0
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        print("Requesting location...")
        updateCount = 0
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("authorization not determined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("authorized when in use")
            self.requestLocation()
        case .denied, .restricted:
            print("authorization denied or restricted")
            // Still updating location, propagating corresponding error to locationManger(_:didFailWithError:) method to handle.
            self.requestLocation()
        default:
            print("Access not authorized, status: \(status.rawValue)")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updating error: \(error.localizedDescription)")
        
        manager.stopUpdatingLocation()
        completionWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update location...")
        updateCount += 1
        
        // Only report the initial location fix.
        if updateCount == 1 {
            manager.stopUpdatingLocation()
            guard let location = locations.last else {
                fatalError("No locations updated.")
            }
            completion?(location)
        }
    }
}
