//
//  MainTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 2/19/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class MainTableViewController: UITableViewController, MainTableViewCellDelegate {
    
    // Properties
    var titleVC = NavItemTitleViewController()
    var category: String?
    
    let countLimit = 5
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var moc: NSManagedObjectContext!

    fileprivate var locationManager = LocationManager.shared
    fileprivate var yelpQueryURL: YelpQueryURL?
    fileprivate var yelpQuery: YelpQuery!
    
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var imgCache = [String: UIImage]()
    
    struct DataSource {
        var imageUrl: String?
        var name: String?
        var category: String?
        var rating: Float?
        var reviewCount: String?
        var price: String?
        var yelpUrl: String?
        var location: CLLocationCoordinate2D?
        var address: String?
    }
    
    var dataSource = [DataSource]()
    
    fileprivate let yelpStars: [Float: String] = [0.0: "small_0", 1.0: "small_1", 1.5: "small_1_half", 2.0: "small_2", 2.5: "small_2_half", 3.0: "small_3", 3.5: "small_3_half", 4.0: "small_4", 4.5: "small_4_half", 5.0: "small_5"]
    
    struct QueryParams {
        var hasChanged: Bool {
            return categoryChanged || dateChanged || locationChanged || radiusChanged
        }
        var categoryChanged = false
        var dateChanged = false
        var locationChanged = false
        var radiusChanged = false
        
        var category = (name: "All", id: "restaurants") {
            didSet { categoryChanged = (category != oldValue) }
        }
        var date = Date() {
            didSet { dateChanged = (date != oldValue) }
        }
        var location = CLLocation() {
            didSet { locationChanged = (location != oldValue) }
        }
        var radius = 1609 {
            didSet { radiusChanged = (radius != oldValue) }
        }
    }
    
    var queryParams = QueryParams()
    fileprivate var indicator: IndicatorWithContainer!
    
    fileprivate var noResultImgView: UIImageView!
    private var barButtonItem: UIBarButtonItem?
    private var everQueried = false
    
    private let metersToMiles: [Int: String] = [805: "0.5", 1609: "1", 8045: "5", 16090: "10", 32180: "20"]

    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBar.backgroundColor = UIColor(red: 80 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)
        */
        barButtonItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
        addViewToNavBar()
        
        noResultImgView = UIImageView(image: UIImage(named: "NoResults"))
        noResultImgView.frame = CGRect(x: 0, y: 0, width: 120 * 2, height: 200 * 2)
        noResultImgView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        titleVC.completionForCategoryChoose = {
            self.performSegue(withIdentifier: "segueToCategories", sender: self)
        }
        titleVC.completionForRadiusChoose = {
            self.performSegue(withIdentifier: "segueToRadius", sender: self)
        }
        
        moc = appDelegate?.managedObjectContext

        // tableView Cell
        let cellNib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "mainCell")
        
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // Start query once location has been got.
        locationManager.completion = { currentLocation in
            let distance = currentLocation.distance(from: self.queryParams.location)
            if distance > 50.0 {
                self.queryParams.location = currentLocation
            }
            // Start Yelp Query
            self.doYelpQuery()
        }
        
        locationManager.completionWithError = { error in
            let alert: UIAlertController
            
            switch error._code {
            case CLError.network.rawValue:
                alert = UIAlertController(
                    title: "I couldn't find your current location.",
                    message: "You might be offline, please connect to the internet and try again.",
                    actions: [.ok]
                )
            case CLError.denied.rawValue:
                alert = UIAlertController(
                    title: "Please allow me to have permission to use your current location.",
                    message: "In order to get your current location, please open Settings and set location access of me to 'While Using the App'.",
                    actions: [.cancel, .openSettings]
                )
            case CLError.locationUnknown.rawValue:
                alert = UIAlertController(
                    title: "I cannot determine your current location.",
                    message: "It might be caused by slow network or server, please try again at a later time.",
                    actions: [.ok]
                )
            default:
                alert = UIAlertController(
                    title: "I cannot find your current location.",
                    message: "There might be some issues with location services, please try again at a later time.",
                    actions: [.ok]
                )
            }
            self.present(alert, animated: false, completion: { self.stopRefreshOrIndicator() })
        }
        
        indicator = IndicatorWithContainer()
        
        getRadiusAndUpdateTitleView(queryParams.radius)
        getCategoryAndUpdateTitleView(queryParams.category)
        getDate()
    }

    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        getDate()
        getLocationAndStartQuery()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func startIndicator() {
        DispatchQueue.main.async {
            // Scroll to top, otherwise the activity indicator may be shown outside the top of the screen.
            //self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
            self.indicator.start()
        }
    }
    
    fileprivate func stopRefreshOrIndicator() {
        DispatchQueue.main.async {
            if self.refreshControl!.isRefreshing {
                self.refreshControl!.endRefreshing()
            }
            if self.indicator.isAnimating {
                self.indicator.stop()
            }
        }
    }
    
    fileprivate func addViewToNavBar() {
        let navBar = navigationController!.navigationBar
        titleVC.view.frame = navBar.frame
        titleVC.view.frame.size.height = navBar.frame.height /*- navBar.layoutMargins.top*/ /*- navBar.layoutMargins.bottom*/

        DispatchQueue.main.async {
            self.navigationItem.titleView = self.titleVC.view
        }
    }
    
    enum ImageDownloadingError: Error {
        case noDownloadingUrl
        case invalidImageUrl
    }
    
    // Download images from given urls.
    // TODO: Unit test.
    private func downloadImages(with imageUrls: [String], completionHandler: @escaping ([UIImage]?, ImageDownloadingError?) -> Void) {
        if imageUrls.isEmpty {
            completionHandler(nil, ImageDownloadingError.noDownloadingUrl)
            return
        }
        
        var cache = [UIImage]()
        let downloadImageGroup = DispatchGroup()
        
        for url in imageUrls {
            guard let urlString = URL(string: url) else {
                completionHandler(nil, ImageDownloadingError.invalidImageUrl)
                return
            }
            downloadImageGroup.enter()
            URLSession.shared.dataTask(with: urlString) { data, response, error in
                guard error == nil, let imageData = data else {
                    print("Error while getting image url response: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                guard let image = UIImage(data: imageData) else {
                    print("Couldn't create image from data: \(imageData)")
                    return
                }
                
                cache.append(image)
                downloadImageGroup.leave()
                
            }.resume()
        }
        
        downloadImageGroup.notify(queue: DispatchQueue.main) {
            completionHandler(cache, nil)
        }

    }
    
    // Core Data
    func updateSaved(cell: MainTableViewCell, button: UIButton) {
        if button.isSelected {
            print("Save object")
            let saved = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: moc) as! SavedMO
            
            guard let nameText = cell.name.text else {
                print("Couldn't get text from cell.")
                return
            }
            let index = nameText.index(nameText.startIndex, offsetBy: 1)
            saved.name = nameText
            saved.nameInitial = cell.name.text?.substring(to: index).uppercased()
            saved.categories = cell.category.text
            saved.yelpUrl = cell.yelpUrl
        } else {
            let request: NSFetchRequest<SavedMO> = NSFetchRequest(entityName: "Saved")
            request.predicate = NSPredicate(format: "yelpUrl == %@", cell.yelpUrl)
            
            guard let object = try? moc.fetch(request).first else {
                fatalError("Error fetching object in context")
            }
            
            guard let obj = object else {
                print("Didn't find object in context")
                return
            }
            
            moc.delete(obj)
            print("Deleted from Saved entity")
        }
        
        appDelegate?.saveContext { error in
            if let err = error {
                let alert = UIAlertController(
                    title: "\(err)",
                    message: "Sorry, it appears that this restaurant couldn't be added to the favorite at this time, please try again later.",
                    actions: [.ok]
                )
                present(alert, animated: false, completion: nil)
            }
        }
    }
    
    // Is the object already in Saved?
    fileprivate func objectSaved(url: String) -> Bool {
        let request = NSFetchRequest<SavedMO>(entityName: "Saved")
        request.predicate = NSPredicate(format: "yelpUrl == %@", url)
        guard let object = try? moc.fetch(request).first else {
            fatalError("Error fetching from context")
        }
        
        guard (object != nil) else {
            return false
        }
        
        return true
    }
    
    // Prepare params and do query
    fileprivate func getCategoryAndUpdateTitleView(_ category: (name: String, id: String)) {
        getCategory(category)
        updateTitleViewCategoryLabel(category.name)
    }
    
    fileprivate func getCategory(_ category: (name: String, id: String)) {
        queryParams.category = category
    }
    
    fileprivate func getRadiusAndUpdateTitleView(_ radius: Int) {
        getRadius(radius)
        updateTitleViewRadiusLabel(radius)
    }
    
    fileprivate func getRadius(_ radius: Int) {
        queryParams.radius = radius
    }
    
    fileprivate func updateTitleViewCategoryLabel(_ category: String) {
        guard let stackView = titleVC.view.subviews[0] as? UIStackView else {
            fatalError("Couldn't get stack view from view.")
        }
        guard let chooseCategoryStackView = stackView.arrangedSubviews[1] as? UIStackView else {
            fatalError("Couldn't get category stack view from stack view.")
        }
        guard let label = chooseCategoryStackView.arrangedSubviews[1].subviews[0] as? UILabel else {
            fatalError("Couldn't get label from stack view.")
        }
        label.text = category
    }

    fileprivate func updateTitleViewRadiusLabel(_ radius: Int) {
        guard let stackView = titleVC.view.subviews[0] as? UIStackView else {
            fatalError("Couldn't get stack view from view.")
        }
        guard let chooseRadiusStackView = stackView.arrangedSubviews[0] as? UIStackView else {
            fatalError("Couldn't get radius stack view from stack view.")
        }
        guard let label = chooseRadiusStackView.arrangedSubviews[1].subviews[0] as? UILabel else {
            fatalError("Couldn't get label from stack view.")
        }
        label.text = metersToMiles[radius]
    }
    
    fileprivate func getDate() {
        let calendar = Calendar.current
        let myDate = Date()
        let hour = calendar.component(.hour, from: myDate)
        let min = calendar.component(.minute, from: myDate)
        
        guard let date = calendar.date(bySettingHour: hour, minute: min, second: 0, of: myDate) else {
            fatalError("Couldn't get date")
        }
        queryParams.date = date
    }
    
    fileprivate func getLocationAndStartQuery() {
        locationManager.requestLocation()
    }
    
    fileprivate func doYelpQuery() {
        everQueried = true
        if queryParams.hasChanged {
            yelpQuery = YelpQuery(
                latitude: queryParams.location.coordinate.latitude,
                longitude: queryParams.location.coordinate.longitude,
                category: queryParams.category.id == "" ? queryParams.category.name.lowercased() : queryParams.category.id,
                radius: queryParams.radius,
                limit: countLimit,
                openAt: Int(queryParams.date.timeIntervalSince1970),
                sortBy: "rating"
            )
            
            yelpQuery.completionWithError = { error in
                var alert: UIAlertController
                switch error {
                case YelpQuery.UnknownError.unknown:
                    alert = UIAlertController(
                        title: "Couldn't get restaurants from Yelp server.",
                        message: "There might be some issues with the Yelp server, please try again later.",
                        actions: [.ok]
                    )
                case YelpQuery.UnknownError.dataSerialization:
                    alert = UIAlertController(
                        title: "Couldn't get the restaurants data.",
                        message: "There are some issues when processing the restaurants data, please try again.",
                        actions: [.ok]
                    )
                default:
                    alert = UIAlertController(
                        title: "\(error.localizedDescription)",
                        message: "You might be disconnected, please connect to the internet and try again.",
                        actions: [.ok]
                    )
                }
                self.present(alert, animated: false, completion: { self.stopRefreshOrIndicator(); return })
            }
            
            yelpQuery.completion = { results in
                print("Query completed")
                if results.isEmpty {
                    if self.noResultImgView.superview == nil {
                        DispatchQueue.main.async {
                            self.view.addSubview(self.noResultImgView)
                        }
                    }
                    if self.navigationItem.rightBarButtonItem != nil {
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = nil
                        }
                    }
                } else {
                    //print("results: \(results)")
                    self.restaurants = results
                    self.processDataSource(from: self.restaurants) { dataSource in
                        self.dataSource = dataSource
                        
                        if self.dataSource.isEmpty {
                            if self.noResultImgView.superview == nil {
                                DispatchQueue.main.async {
                                    self.view.addSubview(self.noResultImgView)
                                }
                            }
                            if self.navigationItem.rightBarButtonItem != nil {
                                DispatchQueue.main.async {
                                    self.navigationItem.rightBarButtonItem = nil
                                }
                            }
                        } else {
                            var imageUrls = [String]()
                            for member in self.dataSource {
                                guard let url = member.imageUrl else {
                                    return
                                }
                                imageUrls.append(url)
                            }
                            self.downloadImages(with: imageUrls) { images, error in
                                if let err = error {
                                    switch err {
                                    case ImageDownloadingError.noDownloadingUrl:
                                        print("No downloading image url.")
                                        return
                                    case ImageDownloadingError.invalidImageUrl:
                                        print("Invalid Image url.")
                                        return
                                    }
                                }
                                
                                guard let imgs = images else {
                                    print("No imgages got.")
                                    return
                                }
                                
                                for (idx, url) in imageUrls.enumerated() {
                                    self.imgCache.updateValue(imgs[idx], forKey: url)
                                }
                                
                                if self.noResultImgView.superview != nil {
                                    self.noResultImgView.removeFromSuperview()
                                }
                                if self.navigationItem.rightBarButtonItem == nil {
                                    self.navigationItem.rightBarButtonItem = self.barButtonItem
                                }
                                self.tableView.reloadData()
                                self.stopRefreshOrIndicator()
                            }
                        }
                    }
                }
            }

            yelpQuery.startQuery()
            
            queryParams.categoryChanged = false
            queryParams.dateChanged = false
            queryParams.locationChanged = false
            queryParams.radiusChanged = false
        } else {
            print("Params no change, skip query")
            stopRefreshOrIndicator()
        }
    }
    
    fileprivate func process(dict: [String: Any], key: String) -> Any? {
        switch key {
        case "image_url", "name", "price", "url", "rating":
            return dict[key]
        case "coordinates":
            guard let coordinate = dict[key] as? [String: Double] else {
                fatalError("Couldn't get coordinate from \(dict[key]!)")
            }
            guard let lat = coordinate["latitude"],
                let long = coordinate["longitude"] else {
                    fatalError("Couldnt' get latitude and longitude.")
            }
            return CLLocationCoordinate2DMake(lat, long)
        case "review_count":
            return String(dict[key] as! Int) + " reviews"
        case "categories":
            guard let categories = dict[key] as? [[String: String]] else {
                fatalError("Couldn't get categories from: \(String(describing: dict[key]))")
            }
            let categoriesString = categories.reduce("", { $0 + $1["title"]! + ", " }).characters.dropLast(2)
            return String(categoriesString)
        case "location":
            guard let location = dict[key] as? [String: Any] else {
                fatalError("Couldn't get location from: \(String(describing: dict[key]))")
            }
            guard let address = Address(of: location) else {
                fatalError("Couldn't compose address from location: \(location)")
            }
            return address.composeAddress()
        default:
            fatalError("Key not expected: \(key)")
        }
    }
    
    private func getDistance(_ origin: CLLocationCoordinate2D, _ dest: CLLocationCoordinate2D, _ time: Int, completion: @escaping (Double) -> Void) {
        let getDistance = GoogleMapsGetDirection()
        var distance = 0.0
        
        getDistance.makeGoogleDirectionsUrl(
            "https://maps.googleapis.com/maps/api/directions/json?",
            origin: origin,
            dest: dest,
            depart: time,
            key: "AIzaSyA-vPWnAEHdO3V4TwUbedRuJO1mDEgIjr0"
        )
        
        getDistance.makeUrlRequest() { _, distances, _, _ in
            distance = Double(distances.first!.components(separatedBy: " ").first!) ?? -1
            completion(distance)
        }
    }

    fileprivate func processDataSource(from data: [[String: Any]], completionHandler: @escaping ([DataSource]) -> Void) {
        var processedData = [DataSource]()
        let getDistanceGroup = DispatchGroup()
        
        for member in data {
            let data = DataSource(
                imageUrl: process(dict: member, key: "image_url") as? String,
                name: process(dict: member, key: "name") as? String,
                category: process(dict: member, key: "categories") as? String,
                rating: process(dict: member, key: "rating") as? Float,
                reviewCount: process(dict: member, key: "review_count") as? String,
                price: process(dict: member, key: "price") as? String,
                yelpUrl: process(dict: member, key: "url") as? String,
                location: process(dict: member, key: "coordinates") as? CLLocationCoordinate2D,
                address: process(dict: member, key: "location") as? String
            )
            getDistanceGroup.enter()
            getDistance(queryParams.location.coordinate, data.location!, Int(queryParams.date.timeIntervalSince1970)) { distance in
                print("**distance: \(distance)")
                if distance < Double(self.queryParams.radius) / 1609.34 {
                    processedData.append(data)
                }
                getDistanceGroup.leave()
            }
        }
        
        getDistanceGroup.notify(queue: DispatchQueue.main) {
            completionHandler(processedData)
        }
    }
    
    fileprivate func getRatingStar(from rating: Float) -> UIImage {
        guard let name = yelpStars[rating] else {
            fatalError("Couldn't get image name from rating: \(rating)")
        }
        guard let image = UIImage(named: name) else {
            fatalError("Couldn't get image from name: \(name)")
        }
        return image
    }
    
    // Table view
    fileprivate func configureCell(_ cell: MainTableViewCell, _ indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        cell.imageUrl = data.imageUrl
        var image: UIImage?
        if let value = imgCache[cell.imageUrl] {
            image = value
        }
        cell.mainImage.image = image
        cell.name.text = data.name
        cell.category.text = data.category
        cell.rating = data.rating
        cell.ratingImage.image = getRatingStar(from: cell.rating)
        cell.reviewCount.text = data.reviewCount
        cell.price.text = data.price
        cell.yelpUrl = data.yelpUrl
        cell.latitude = data.location?.latitude
        cell.longitude = data.location?.longitude
        cell.address = data.address
        cell.likeButton.isSelected = objectSaved(url: cell.yelpUrl)
        cell.delegate = self

    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count == 0 ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainTableViewCell
        
        configureCell(cell, indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.count == 0 ? 0 : 380.0
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "segueToMap" || identifier == "segueToRoute"), ((sender is MainTableViewCell) || (sender is UIBarButtonItem)) {
            return true
        } else {
            return false
        }
    }

    @IBAction func handleMapTap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "segueToMap", sender: sender)
    }

    // Segue to Map view controller
    func showMap(cell: MainTableViewCell) {
        performSegue(withIdentifier: "segueToRoute", sender: cell)
    }
    
    // Link to Yelp app/website
    func linkToYelp(cell: MainTableViewCell) {
        if cell.yelpUrl != "" {
            UIApplication.shared.open(URL(string: cell.yelpUrl)!, options: [:]) { succeeded in
                if !succeeded {
                    print("Open Yelp URL failed.")
                    let alert = UIAlertController(title: "Couldn't find a restaurant.",
                                                  message: "I couldn't load restaurant data from Yelp server, please try again later.",
                                                  actions: [.ok]
                    )
                    self.present(alert, animated: false, completion: { return })
                }
            }
        } else {
            let alert = UIAlertController(title: "Couldn't find a restaurant.",
                                          message: "I couldn't find a restaurant from Yelp server, please try again later.",
                                          actions: [.ok]
            )
            self.present(alert, animated: false, completion: { return })
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRoute", sender is MainTableViewCell {
            guard let cell = sender as? MainTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            let destinationVC = segue.destination
            if cell.address == "" {
                let alert = UIAlertController(title: "Couldn't find a restaurant.",
                                  message: "I couldn't find a restaurant from Yelp server, please try again later.",
                                  actions: [.ok]
                )
                self.present(alert, animated: false, completion: { return })
            } else {
                if let mapVC = destinationVC as? GoogleMapsViewController {
                    mapVC.setBizLocation(cell.address)
                    mapVC.setBizCoordinate2D(CLLocationCoordinate2DMake(cell.latitude
                        , cell.longitude))
                    mapVC.setBizName(cell.name.text!)
                    mapVC.setDepartureTime(Int(queryParams.date.timeIntervalSince1970))
                }
            }
        }
        if segue.identifier == "segueToMap", sender is UIBarButtonItem {
            guard let vc = segue.destination as? GoogleMapsViewController else {
                print("Couldn't show Google Maps VC.")
                return
            }
            vc.getBusinesses(dataSource)
        }
        if segue.identifier == "segueToRadius", sender is MainTableViewController {
            guard let vc = segue.destination as? RadiusViewController else {
                fatalError("Couldn't show Radius VC.")
            }
            vc.getRadius(radius: queryParams.radius)
        }
    }
    
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {
        let sourceVC = sender.source
        switch sender.identifier! {
        case "unwindFromCategories":
            guard let category = (sourceVC as! CategoriesViewController).getCategory() else {
                fatalError("Couldn't get category.")
            }
            startIndicator()
            
            getCategoryAndUpdateTitleView(category)
            getDate()
            getLocationAndStartQuery()
        case "unwindFromRadius":
            guard let radius = (sourceVC as! RadiusViewController).radius else {
                fatalError("Couldn't get radiusVC.")
            }
            
            startIndicator()
            
            getRadiusAndUpdateTitleView(radius)
            getDate()
            getLocationAndStartQuery()
        default:
            break
        }
    }
}
