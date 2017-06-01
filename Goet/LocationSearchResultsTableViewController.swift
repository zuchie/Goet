//
//  LocationSearchResultsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/22/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class LocationSearchResultsTableViewController: UITableViewController, UISearchResultsUpdating {

    
    fileprivate var location: CLLocationCoordinate2D!
    private var currentLocationCoordinations: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()

    
    let googlePlaceDetails = GooglePlaceDetails()
    
    var filteredLocations = [[(name: String, placeID: String)](), [(name: String, placeID: String)]()]
    
    // Used for Google Places Autocomplete feature.
    fileprivate var fetcher: GMSAutocompleteFetcher!
    
    fileprivate enum Locations: Int {
        case current, other
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // Allocate cache here for URL responses so that cache data won't get lost.
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        URLCache.shared = urlCache
        
        // Create the Google Places Autocomplete Fetcher.
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.090308, longitude: -66.966982)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 22.567078, longitude: -125.75968)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher.delegate = self
        
        filteredLocations[Locations.current.rawValue].append((name: "Current Location", placeID: ""))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            fetcher?.sourceTextHasChanged(inputText)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return filteredLocations.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocations[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "locationCell2"
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        // Configure the cell...
        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row: \(indexPath.row)")
        // Get coordinates of chosen location.
        if indexPath.section == Locations.current.rawValue {
            //YelpUrlQueryParameters.coordinates = currentLocationCoordinations
            location = currentLocationCoordinations
            //performSegue(withIdentifier: "backFromWhere", sender: self)
        } else {
            let placeID = filteredLocations[indexPath.section][indexPath.row].placeID
            googlePlaceDetails.getCoordinates(from: placeID) { coordinates in
                
                //YelpUrlQueryParameters.coordinates = coordinates
                self.location = coordinates
                //print("***coordinates updated")
                /*
                 DispatchQueue.main.async {
                 self.performSegue(withIdentifier: "backFromWhere", sender: self)
                 }
                 */
            }
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getLocationCoordinates() -> CLLocationCoordinate2D {
        return location
    }
}
// Google Places autocomplete.
extension LocationSearchResultsTableViewController: GMSAutocompleteFetcherDelegate {
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    public func didFailAutocompleteWithError(_ error: Error) {
        print("autocomplete error: \(error.localizedDescription)")
    }
    
    // Google Places autocomplete.
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        // Clear previously appended places.
        filteredLocations[Locations.other.rawValue].removeAll(keepingCapacity: false)
        
        for prediction in predictions {
            let placeID = prediction.placeID
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[Locations.other.rawValue].append((name: resultsStr, placeID: placeID!))
        }
        tableView.reloadData()
    }
}
