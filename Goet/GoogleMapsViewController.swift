//
//  GoogleMapsViewController.swift
//  Goet
//
//  Created by Zhe Cui on 8/30/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapsViewController: UIViewController {
    
    fileprivate var location: String?
    fileprivate var bizCoordinate2D: CLLocationCoordinate2D?
    fileprivate var bizName: String?
    fileprivate var departureTime: Int?
    fileprivate var drawRoute = GoogleMapsGetDirection()
    fileprivate var mapView: GMSMapView!
    fileprivate var isNavigationBarHidden: Bool?

    fileprivate var label = UILabel()
    
    var businesses = [MainTableViewController.DataSource()]
    var markersOnly = false
    private var barButtonItem: UIBarButtonItem!
    
    private let edges = UIEdgeInsetsMake(50, 40, 70, 40)
    private var bounds: GMSCoordinateBounds!

    
    func getBusinesses(_ data: [MainTableViewController.DataSource]) {
        markersOnly = true
        businesses = data
    }
    
    func setBizLocation(_ location: String) {
        self.location = location
    }
    
    func setBizCoordinate2D(_ coordinate2D: CLLocationCoordinate2D) {
        self.bizCoordinate2D = coordinate2D
    }
    
    func setBizName(_ name: String) {
        self.bizName = name
    }

    func setDepartureTime(_ time: Int) {
        // Convert back from local time to UTC for Google Maps API departure_time use.
        self.departureTime = time - NSTimeZone.local.secondsFromGMT()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRoute.completionWithError = { error in
            let alert = UIAlertController(
                title: "Error: \(String(describing: error?.localizedDescription))",
                message: "Oops, looks like the Google Maps server is not available now, please try again at a later time.",
                actions: [.ok]
            )
            DispatchQueue.main.async {
                self.present(alert, animated: false, completion: { return })
            }
        }
        
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if markersOnly {
            barButtonItem = navigationItem.rightBarButtonItem
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.title = "Route"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !markersOnly {
            // Add label.
            let labelWidth: CGFloat = view.bounds.width / 3
            let labelHeight = labelWidth / 7.0
            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
            label.center = CGPoint(x: view.center.x, y: view.bounds.height - labelHeight / 2)
            label.backgroundColor = UIColor.lightGray
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            
            view.addSubview(label)
        }
    }

    // Restore navigation bar status.
    override func viewWillDisappear(_ animated: Bool) {
        if markersOnly {
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async {
            // Update camera to new bounds.
            let camera = GMSCameraUpdate.fit(self.bounds, with: self.edges)
            self.mapView.animate(with: camera)
            // Add label.
            let screenBounds = UIScreen.main.bounds
            let labelWidth: CGFloat
            let labelHeight: CGFloat
            if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
                labelWidth = screenBounds.width * 0.5
            } else {
                labelWidth = screenBounds.height * 0.5
            }
            labelHeight = labelWidth / 9.0

            self.label.frame = CGRect(x: screenBounds.width / 2.0 - labelWidth / 2.0, y: screenBounds.height - labelHeight , width: labelWidth, height: labelHeight)
        }
    }
    */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "myLocation" && object is GMSMapView {
            
            if markersOnly {
                var coordinates = [CLLocationCoordinate2D]()
                for member in businesses {
                    guard let location = member.location else {
                        fatalError("Couldn't get location from businesses.")
                    }
                    coordinates.append(location)
                }
                if let myCoordinate = mapView.myLocation?.coordinate {
                    coordinates.append(myCoordinate)
                } else {
                    print("Couldn't get my location.")
                    let alert = UIAlertController(
                        title: "Missing your location",
                        message: "The Google Maps can't get your location, please try again at a later time.",
                        actions: [.ok]
                    )
                    DispatchQueue.main.async {
                        self.present(alert, animated: false, completion: nil)
                    }
                }
                
                guard let minLat = coordinates.map({ $0.latitude }).min(by: { Swift.abs($0) < Swift.abs($1) }),
                let minLong = coordinates.map({ $0.longitude }).min(by: { Swift.abs($0) < Swift.abs($1) }),
                let maxLat = coordinates.map({ $0.latitude }).max(by: { Swift.abs($0) < Swift.abs($1) }),
                    let maxLong = coordinates.map({ $0.longitude }).max(by: { Swift.abs($0) < Swift.abs($1) }) else {
                        fatalError("Couldn't get min, max coordinates.")
                }
                
                let northeast = CLLocationCoordinate2DMake(minLat, minLong)
                let southwest = CLLocationCoordinate2DMake(maxLat, maxLong)
                
                DispatchQueue.main.async {
                    // Update camera to new bounds.
                    self.bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
                    let camera = GMSCameraUpdate.fit(self.bounds, with: self.edges)
                    
                    self.mapView.animate(with: camera)
                }
            } else {
                // Draw route.
                drawRoute.makeGoogleDirectionsUrl(
                    "https://maps.googleapis.com/maps/api/directions/json?",
                    origin: mapView.myLocation!.coordinate,
                    dest: bizCoordinate2D!,
                    depart: departureTime!,
                    key: "AIzaSyA-vPWnAEHdO3V4TwUbedRuJO1mDEgIjr0"
                )
                
                drawRoute.makeUrlRequest() { routesPoints, distances, durationInTraffic, viewport in
                    // Draw from returned polyline.
                    for points in routesPoints {
                        //print("poly points: \(points)")
                        DispatchQueue.main.async(execute: {
                            let path = GMSMutablePath(fromEncodedPath: points)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 5
                            polyline.strokeColor = UIColor(red: 88 / 255, green: 130 / 255, blue: 1, alpha: 1)
                            polyline.map = self.mapView
                        })
                    }
                    
                    DispatchQueue.main.async(execute: {
                        // Update camera to new bounds.
                        self.bounds = GMSCoordinateBounds(coordinate: viewport.northeast!, coordinate: viewport.southwest!)
                        let camera = GMSCameraUpdate.fit(self.bounds, with: self.edges)
                        
                        self.mapView.animate(with: camera)
                        self.label.text = "\(distances.first!), \(durationInTraffic)"
                    })
                }
            }

        }
        // Deregister observer, to stop myLocation from updating.
        view.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func loadView() {
        //super.loadView()
        
        // Create a GMSCameraPosition that tells the map to display the
        // business position at zoom level 12.
        //print("==loadview")
        let target: CLLocationCoordinate2D
        if markersOnly {
            target = businesses[0].location!
        } else {
            target = bizCoordinate2D!
        }
        let camera = GMSCameraPosition.camera(withTarget: target, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        view = mapView
        
        if markersOnly {
            for member in businesses {
                let marker = GMSMarker()
                marker.position = member.location!
                marker.title = member.name
                marker.snippet = member.address
                marker.map = mapView
            }
        } else {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = bizCoordinate2D!
            marker.title = bizName
            marker.snippet = location
            marker.map = mapView
        }
    }
    
    // Open Google Maps app for navigation. Need to add "comgooglemaps", and "comgooglemaps-x-callback" into plist "LSApplicationQueriesSchemes" array.
    @IBAction func StartNavigation(_ sender: UIBarButtonItem) {
        print("start navigation")
        let bizLat = bizCoordinate2D?.latitude
        let bizlng = bizCoordinate2D?.longitude
        let testURL = URL(string: "comgooglemaps-x-callback://")
        let app = UIApplication.shared
        if app.canOpenURL(testURL!) {
            let directionsRequest = "comgooglemaps-x-callback://" +
                "?daddr=\(bizLat!),\(bizlng!)" + "&x-success=sourceapp://?resume=true&x-source=AirApp";
            let directionsURL = URL(string: directionsRequest)
            UIApplication.shared.openURL(directionsURL!)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
