//
//  SavedTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class SavedTableViewController: CoreDataTableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    fileprivate var savedRestaurants = [SavedMO]()
    fileprivate var filteredRestaurants = [SavedMO]()
    
    fileprivate var searchResultsVC: UITableViewController!
    fileprivate var searchController: UISearchController!
    
    fileprivate var rowCount = 0 {
        willSet {
            if newValue == 0 {
                //setEditing(false, animated: false)
                //editButtonItem.isEnabled = false
                navigationItem.rightBarButtonItem = nil
                navigationItem.titleView = nil
            } else {
                //editButtonItem.isEnabled = true
                if navigationItem.rightBarButtonItem == nil {
                    navigationItem.rightBarButtonItem = editButtonItem
                }
                if navigationItem.titleView == nil {
                    navigationItem.titleView = searchController?.searchBar
                }
            }
        }
    }
    
    fileprivate let appDelegate = UIApplication.shared.delegate as? AppDelegate
    fileprivate var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = appDelegate?.managedObjectContext
        
        navigationItem.rightBarButtonItem = editButtonItem

        initializeFetchedResultsController()
        
        let nib = UINib(nibName: "SavedTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "savedCell")
        
        searchResultsVC = UITableViewController(style: .grouped)
        searchResultsVC.tableView.register(nib, forCellReuseIdentifier: "savedCell")
        searchResultsVC.tableView.dataSource = self
        searchResultsVC.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = self
        //tableView.tableHeaderView = searchController?.searchBar
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.sizeToFit()
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
        */
        /*
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            let _ = searchController.view
        }
        */
    }
    
    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Saved")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "nameInitial", cacheName: nil)
    }
    
    fileprivate func updateSaved(cell: SavedTableViewCell) {
        
        let request: NSFetchRequest<SavedMO> = NSFetchRequest(entityName: "Saved")
        request.predicate = NSPredicate(format: "yelpUrl == %@", cell.yelpUrl)
        
        guard let object = try? moc.fetch(request).first else {
            fatalError("Error fetching from context")
        }
        
        guard let obj = object else {
            print("Didn't find object in context")
            return
        }
        
        moc.delete(obj)
        print("Deleted from Saved entity")
        
        if let index = filteredRestaurants.index(of: obj) {
            filteredRestaurants.remove(at: index)
            searchResultsVC.tableView.reloadData()
            print("Deleted from filtered")
        }
        
        appDelegate?.saveContext { error in
            if let err = error {
                let alert = UIAlertController(
                    title: "\(err)",
                    message: "Sorry, it appears that this restaurant couldn't be deleted from the favorite at this time, please try again later.",
                    actions: [.ok]
                )
                present(alert, animated: false, completion: nil)
            }
        }
        
        // Update Main table view controller cell like button status.
        guard let nav = tabBarController?.viewControllers?[0] as? UINavigationController else {
            fatalError("Couldn't get navigation controller from tab bar controller")
        }
        guard let vc = nav.viewControllers[0] as? MainTableViewController else {
            fatalError("Couldn't get Main view controller from navigation controller")
        }
        for item in vc.tableView.visibleCells {
            guard let mainCell = item as? MainTableViewCell else {
                fatalError("Couldn't convert cell to Main table view cell.")
            }
            if (mainCell.yelpUrl == cell.yelpUrl) {
                print("De-select like button")
                mainCell.likeButton.isSelected = false
            }
        }
    }
        
    // MARK: - Table view data source
    
    fileprivate func configureCell(_ cell: SavedTableViewCell, _ object: SavedMO) {
        
        cell.name.text = object.name
        cell.categories.text = object.categories
        cell.yelpUrl = object.yelpUrl
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return fetchedResultsController?.sections?.count ?? 0
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        } else {
            return filteredRestaurants.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant: SavedMO
        
        // Configure the cell...
        if tableView == self.tableView {
            guard let object = fetchedResultsController?.object(at: indexPath) as? SavedMO else {
                fatalError("Unexpected object in FetchedResultsController")
            }
            restaurant = object
        } else {
            restaurant = filteredRestaurants[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedCell", for: indexPath) as! SavedTableViewCell
        
        configureCell(cell, restaurant)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            guard let sectionInfo = fetchedResultsController?.sections?[section] else {
                return nil
            }
            return sectionInfo.name
        } else {
            return "Top Name Matches"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
            fatalError("Unexpected indexPath: \(indexPath)")
        }
        
        guard let url = cell.yelpUrl else {
            fatalError("Unexpected url: \(cell.yelpUrl)")
        }
        
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle:  UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            // Remove from DB and trigger row deletion.
            updateSaved(cell: cell)

        }
    }
    /*
    // Customize section header, make sure all the headers are rendered when they are inserted.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    */
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Add row index.
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.tableView {
            /*
            guard let restaurants = fetchedResultsController?.fetchedObjects as? [SavedMO] else {
                fatalError("Couldn't get Saved restaurants from Core Data")
            }
            return restaurants.map({ String($0.name!.characters.first!) }).unique
            */
            
            return fetchedResultsController?.sectionIndexTitles
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        /*
        guard let restaurants = fetchedResultsController?.fetchedObjects as? [SavedMO],
            let idx = getIndex(from: restaurants.map({ $0.name! }), by: title.characters.first!) else {
                fatalError("Saved restaurants doesn't have a name with the given first letter: \(title)")
        }
        //print("title: \(title), index: \(idx)")
        let indexPath = IndexPath(row: idx, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        return -1
        */
        
        guard let section = fetchedResultsController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section.")
        }
        return section
    }

    private func getIndex(from sorted: [String], by firstLetter: Character) -> Int? {
        for (index, element) in sorted.enumerated() {
            if element.characters.first == firstLetter {
                return index
            }
        }
        return nil
    }

    
    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filteredRestaurants = savedRestaurants.filter {
                guard let name = $0.name,
                    let categories = $0.categories else {
                    print("No restaurant found")
                    return false
                }
                return (name.lowercased().contains(inputText.lowercased()) || categories.lowercased().contains(inputText.lowercased()))
             }
        }
        searchResultsVC.tableView.reloadData()
    }
    
    // Notifications to remove/add bar button item.
    func willPresentSearchController(_ searchController: UISearchController) {
        savedRestaurants.removeAll()
        for obj in (fetchedResultsController?.fetchedObjects)! {
            savedRestaurants.append(obj as! SavedMO)
        }
        navigationItem.rightBarButtonItem = nil
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.rightBarButtonItem = editButtonItem
    }
 
    /*
    func didDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    */
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {

            guard let cell = sender as? MainAndSavedTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            let destinationVC = segue.destination

            if cell.address == "" {
                alert()
            } else {
                if let mapVC = destinationVC as? GoogleMapViewController {
                    
                    mapVC.setBizLocation(cell.address)
                    mapVC.setBizCoordinate2D(CLLocationCoordinate2DMake(cell.latitude
                        , cell.longitude))
                    mapVC.setBizName(cell.name.text!)
                    mapVC.setDepartureTime(Int(Date().timeIntervalSince1970))
                }
            }
        }
    }
    */
}
