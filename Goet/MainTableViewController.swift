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
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var moc: NSManagedObjectContext!

    fileprivate var locationManager = LocationManager.shared
    fileprivate var yelpQueryURL: YelpQueryURL?
    fileprivate var yelpQuery: YelpQuery!
    
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var imgCache = Cache<String, UIImage>()
    
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
        var radius = 1600 {
            didSet { radiusChanged = (radius != oldValue) }
        }
    }
    
    var queryParams = QueryParams()
    fileprivate var indicator: IndicatorWithContainer!
    
    fileprivate var noResultImgView: UIImageView!
    private var barButtonItem: UIBarButtonItem?
    private var everQueried = false
    
    private let metersToMiles: [Int: String] = [800: "0.5 mi", 1600: "1 mi", 8000: "5 mi", 16000: "10 mi", 32000: "20 mi"]

    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        barButtonItem = navigationItem.rightBarButtonItem
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
                    title: "Location Services not available",
                    message: "Please make sure that your device is connected to the network",
                    actions: [.ok]
                )
            case CLError.denied.rawValue:
                alert = UIAlertController(
                    title: "Location Access Disabled",
                    message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                    actions: [.cancel, .openSettings]
                )
            case CLError.locationUnknown.rawValue:
                alert = UIAlertController(
                    title: "Location Unknown",
                    message: "Couldn't get location, please try again at a later time.",
                    actions: [.ok]
                )
            default:
                alert = UIAlertController(
                    title: "Bad location services",
                    message: "Location services got issue, please try again at a later time.",
                    actions: [.ok]
                )
            }
            self.present(alert, animated: false, completion: { self.stopRefreshOrIndicator() })
        }
        
        indicator = IndicatorWithContainer()
        startIndicator()
        
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
    /*
    override func viewWillAppear(_ animated: Bool) {
        //print("==view will appear frame: \(view.frame)")
        
        noResultImgView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    */
    /*
    override func viewDidAppear(_ animated: Bool) {
        //print("==view did appear frame: \(view.frame)")
        
        if shouldStartIndicator {
            startIndicator()
            shouldStartIndicator = false
        }
    }
    */
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.navigationItem.titleView?.frame = self.navigationController!.navigationBar.frame
            self.navigationItem.titleView?.frame.size.height -= self.navigationController!.navigationBar.layoutMargins.top + self.navigationController!.navigationBar.layoutMargins.bottom
            
            self.noResultImgView.frame = self.view.frame
            self.noResultImgView.center = self.view.center
        })
    }
    */
    fileprivate func startIndicator() {
        //indicator.container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        //indicator.center = indicator.container.center

        DispatchQueue.main.async {
            // Scroll to top, otherwise the activity indicator may be shown outside the top of the screen.
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: true)
            //self.view.addSubview(self.indicator.container)
            //self.appDelegate?.window?.addSubview(self.indicator.container)
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
                //self.indicator.container.removeFromSuperview()
            }
        }
    }
    
    fileprivate func addViewToNavBar() {
        let navBar = navigationController!.navigationBar
        titleVC.view.frame = navBar.frame
        titleVC.view.frame.size.height = navBar.frame.height - navBar.layoutMargins.top - navBar.layoutMargins.bottom

        navigationItem.titleView = titleVC.view
    }
    
    // Cache
    fileprivate func loadImagesToCache(from dataSource: [DataSource], completion: @escaping (_ cache: Cache<String, UIImage>) -> Void) {
        var cache = Cache<String, UIImage>()
        
        if dataSource.count == 0 { completion(cache) }
        
        for member in dataSource {
            guard let imgUrl = member.imageUrl,
                let urlString = URL(string: imgUrl) else {
                    fatalError("Unexpected url string while loading image: \(String(describing: member.imageUrl))")
            }
            
            URLSession.shared.dataTask(with: urlString) { data, response, error in
                guard error == nil, let imageData = data else {
                    print("Error while getting image url response: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                guard let image = UIImage(data: imageData) else {
                    print("Couldn't create image from data: \(imageData)")
                    return
                }
                
                cache.add(key: imgUrl, value: image)
                if cache.count == dataSource.count {
                    completion(cache)
                }
            }.resume()
        }

    }
    
    // Core Data
    func updateSaved(cell: MainTableViewCell, button: UIButton) {
        if button.isSelected {
            print("Save object")
            let saved = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: moc) as! SavedMO
            
            saved.name = cell.name.text
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
        
        appDelegate?.saveContext()
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
        //let title = (category == "All" ? "All" : category)
        guard let stackView = titleVC.view.subviews[0] as? UIStackView else {
            fatalError("Couldn't get stack view from view.")
        }
        guard let chooseCategoryStackView = stackView.arrangedSubviews[1] as? UIStackView else {
            fatalError("Couldn't get category stack view from stack view.")
        }
        guard let label = chooseCategoryStackView.arrangedSubviews[1] as? UILabel else {
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
        guard let label = chooseRadiusStackView.arrangedSubviews[1] as? UILabel else {
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
                limit: 5,
                openAt: Int(queryParams.date.timeIntervalSince1970),
                sortBy: "rating"
            )
            
            yelpQuery.completionWithError = { error in
                let alert = UIAlertController(
                    title: "Error: \(error.localizedDescription)",
                    message: "Oops, looks like the server is not available now, please try again at a later time.",
                    actions: [.ok]
                )
                self.present(alert, animated: false, completion: { self.stopRefreshOrIndicator(); return })
            }
            yelpQuery.completion = { results in
                print("Query completed")
                self.restaurants = results
                self.dataSource = self.processDataSource(from: self.restaurants)
                self.loadImagesToCache(from: self.dataSource) { cache in
                    self.imgCache = cache
                    DispatchQueue.main.async {
                        if self.dataSource.count == 0 {
                            if self.noResultImgView.superview == nil {
                                self.view.addSubview(self.noResultImgView)
                            }
                            if self.navigationItem.rightBarButtonItem != nil {
                                self.navigationItem.rightBarButtonItem = nil
                            }
                            
                        } else {
                            if self.noResultImgView.superview != nil {
                                self.noResultImgView.removeFromSuperview()
                            }
                            if self.navigationItem.rightBarButtonItem == nil {
                                self.navigationItem.rightBarButtonItem = self.barButtonItem
                            }
                        }
                        self.tableView.reloadData()
                    }
                    self.stopRefreshOrIndicator()
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
                fatalError("Couldn't get coordinate.")
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
    
    fileprivate func processDataSource(from data: [[String: Any]]) -> [DataSource] {
        var processedData = [DataSource]()
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
            processedData.append(data)
        }
        return processedData
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
        if let value = imgCache.get(by: cell.imageUrl) {
            image = value
        }
        DispatchQueue.main.async {
            cell.mainImage.image = image
        }
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
            let succeeded = UIApplication.shared.openURL(URL(string: cell.yelpUrl)!)
            if !succeeded {
                print("Open Yelp URL failed.")
            }
        } else {
            let alert = UIAlertController(title: "Alert",
                                          message: "Couldn't find a restaurant.",
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
                let alert = UIAlertController(title: "Alert",
                                  message: "Couldn't find a restaurant.",
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
            guard let category = (sourceVC as! CategoriesTableViewController).getCategory() else {
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
