//
//  GoogleMapsGetDirection.swift
//  Goet
//
//  Created by Zhe Cui on 8/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import GoogleMaps

class GoogleMapsGetDirection {
    
    // MARK: Properties.
    
    fileprivate var googleDirectionUrl: String?
    fileprivate var routesPoints = [String]()
    fileprivate var distances = [String]()
    fileprivate var durationInTraffic = ""
    struct Bounds {
        var northeast: CLLocationCoordinate2D?
        var southwest: CLLocationCoordinate2D?
    }
    
    fileprivate var viewport = Bounds()
    var completionWithError: ((_ error: Error?) -> Void)?
    
    // MARK: Helper functions.
    
    func makeGoogleDirectionsUrl(_ baseUrl: String, origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D, depart: Int, key: String) {
        
        googleDirectionUrl = "\(baseUrl)" + "origin=\(origin.latitude),\(origin.longitude)" + "&destination=\(dest.latitude),\(dest.longitude)" + "&departure_time=\(depart)" + "&key=\(key)"
    }
    
    fileprivate func getRoutesPoints(_ routes: [[String: Any]]) {
        for route in routes {
            guard let routePoints = route["overview_polyline"] as? [String: Any] else {
                fatalError("Couldn't get route polyline.")
            }
            guard let points = routePoints["points"] as? String else {
                fatalError("Couldn't get route points")
            }
            routesPoints.append(points)
        }
    }
    
    fileprivate func getDistancesAndDurations(_ routes: [[String: Any]]) {
        for route in routes {
            guard let legs = route["legs"] as? [[String: Any]]  else {
                fatalError("Couldn't get legs")
            }
            
            for leg in legs {
                guard let distance = leg["distance"] as? [String: Any] else {
                    fatalError("Couldn't get distance")
                }
                distances.append(distance["text"] as! String)
                
                // duration_in_traffic only exists in single leg.
                guard let durationInTraffic = leg["duration_in_traffic"] as? [String: Any] else {
                    fatalError("Couldn't get duration.")
                }
                self.durationInTraffic = durationInTraffic["text"] as! String
            }
        }
    }
    
    fileprivate func getViewport(_ routes: [[String: Any]]) {
        for route in routes {
            guard let bounds = route["bounds"] as? [String: Any] else {
                fatalError("Couldn't get bounds")
            }
            guard let northeast = bounds["northeast"] as? [String: Any],
                let southwest = bounds["southwest"] as? [String: Any] else {
                    fatalError("Couldn't get northeast and southwest.")
            }
            viewport.northeast = CLLocationCoordinate2DMake(northeast["lat"] as! CLLocationDegrees, northeast["lng"] as! CLLocationDegrees)
            viewport.southwest = CLLocationCoordinate2DMake(southwest["lat"] as! CLLocationDegrees, southwest["lng"] as! CLLocationDegrees)
        }
    }
    
    func makeUrlRequest(_ completionHandler: @escaping (_ routesPoints: [String], _ distances: [String], _ durationInTraffic: String, _ viewport: Bounds) -> Void) {
        
        let urlObj = URL(string: googleDirectionUrl!)
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.timeoutInterval = 120

        request.makeRequest { error, data in
            
            if error != nil {
                self.completionWithError?(error!)
                return
            }
            
            guard let convertedJsonIntoDict = data?.jsonToDictionary() else {
                fatalError("Couldn't process data.")
            }
            
            let status = convertedJsonIntoDict["status"] as? String
            let routes = convertedJsonIntoDict["routes"] as? [[String: Any]]
            
            if status == "OK" {
                self.getRoutesPoints(routes!)
                self.getDistancesAndDurations(routes!)
                self.getViewport(routes!)
                
                completionHandler(self.routesPoints, self.distances, self.durationInTraffic, self.viewport)
            } else {
                print("Google Directions returned status: \(String(describing: status))")
                return
            }
        }        
    }
}
