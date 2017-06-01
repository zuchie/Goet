//
//  GoetTests.swift
//  GoetTests
//
//  Created by Zhe Cui on 3/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Goet

class GoetTests: XCTestCase {
    
    //var mainViewController: MainTableViewController!
    
    override func setUp() {
        super.setUp()
        print("===Setup===")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as! MainTableViewController
        
        //let _ = mainViewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        print("===Teardown===")
        
        //mainViewController = nil
    }
    
    /*
    /**
     
     MainTableViewController test
     
     - Expectations:
     The view of MainTableViewController is not nil after app launches and 
     location services is ready to use.
     
     */
    let readyToLocate = CLLocationManager.locationServicesEnabled() &&
                            (CLLocationManager.authorizationStatus() ==
                                .authorizedWhenInUse)
    func testMainView() {
        // Setup
        if readyToLocate {
            var mainViewController: MainTableViewController! = UIApplication.topViewController() as! MainTableViewController
            
            // Test
            XCTAssertNotNil(mainViewController.view, "Cannot find Main Tableview controller instance")
            
            // Teardown
            mainViewController = nil
        } else {
            print("Location services not ready for use.")
            return
        }
    }
    */
    /*
    /**
     
     LocationManagerDelegate test
     
     - Expectations: 
     Delegate can receive a non-nil location asynchronously when location 
     services is ready to use.
     
     */
    var expectation: XCTestExpectation!
    
    func testLocation() {
        var locationManager: LocationManager! = LocationManager.shared
        
        locationManager.delegate = self
        
        expectation = expectation(description: "Got location successfully")
        
        locationManager.requestLocation()
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Waiting for expectations timed out, error: \(String(describing: error))")
            
            locationManager.delegate = nil
            locationManager = nil
            
            print("Locaton test done")
        }
    }
    
    func updateLocation(location: CLLocation?) {
        print("Location updated")
        XCTAssertNotNil(location, "Location is nil")
        
        expectation.fulfill()
    }
    
    func updateLocationError(error: Error?) {
        print("Location error")
        guard let error = error else {
            fatalError("Couldn't get error")
        }

        let authorization = CLLocationManager.authorizationStatus()
        switch authorization {
        case .denied:
            XCTAssert(error._code == CLError.Code.denied.rawValue, "Authorization denied was not correctly reported.")
        default:
            print("Other error: \(error)")
        }
        
        expectation.fulfill()
    }
    */
    
    /*
    /**
     
     YelpUrlQueryParameters test
     
     - Expectations:
     Build legit Yelp query string from input parameters.
     
     */
    func testQueryStrFormatter() {
        // Setup
        let latitude = 133.33
        let longitude = -22.22
        let category = "American"
        let radius = 10000
        let limit = 3
        let openAt = 12345
        let sortBy = "rating"
        
        var categoryAmerican: YelpUrlQueryParameters! = YelpUrlQueryParameters(latitude: latitude, longitude: longitude, category: category, radius: radius, limit: limit, openAt: openAt, sortBy: sortBy)

        // Test
        let american = categoryAmerican.queryString
        XCTAssert(american == "https://api.yelp.com/v3/businesses/search?" +
            "&latitude=\(latitude)" +
            "&longitude=\(longitude)" +
            "&categories=newamerican,tradamerican" +
            "&radius=\(radius)" +
            "&limit=\(limit)" +
            "&open_at=\(openAt)" +
            "&sort_by=\(sortBy)", "Failed")
        
        // Teardown
        categoryAmerican = nil
    }
    */
    
    /*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print("test done")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
