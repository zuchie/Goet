//
//  SavedViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class SavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainer: UIView!

    fileprivate var savedRestaurants = [SavedMO]()
    fileprivate var filteredRestaurants = [SavedMO]()
    
    fileprivate var searchResultsVC: UITableViewController!
    fileprivate var searchController: UISearchController!
    fileprivate let appDelegate = UIApplication.shared.delegate as? AppDelegate
    fileprivate var moc: NSManagedObjectContext!
    // Retrieve the initial data to be displayed, and start monitoring moc for changes.
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            if let frc = fetchedResultsController {
                frc.delegate = self
                do {
                    try frc.performFetch()
                } catch {
                    print("Failed to initialize FetchedResultsController: \(error)")
                }
            }
        }
    }
    
    private var isTableEmpty: Bool = true {
        willSet {
            if newValue == true {
                setEditing(false, animated: true)
                navigationItem.rightBarButtonItem = nil
            } else {
                navigationItem.rightBarButtonItem = editButtonItem
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = appDelegate?.managedObjectContext
        
        // The navigation bar's shadowImage is set to a transparent image.  In
        // addition to providing a custom background image, this removes
        // the grey hairline at the bottom of the navigation bar.  The
        // ExtendedNavBarView will draw its own hairline.
        navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        // "Pixel" is a solid white 1x1 image.
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        initializeFetchedResultsController()
        
        let nib = UINib(nibName: "SavedTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "savedCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        searchResultsVC = UITableViewController(style: .grouped)
        searchResultsVC.tableView.register(nib, forCellReuseIdentifier: "savedCell")
        searchResultsVC.tableView.dataSource = self
        searchResultsVC.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.searchBar.searchBarStyle = .default
        //searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search names, categories..."
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .any, barMetrics: .default)
        searchController.searchBar.barTintColor = UIColor(red: 80 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)
        searchBarContainer.addSubview(searchController.searchBar)
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        //extendedLayoutIncludesOpaqueBars = true
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
         */
        /*
         if #available(iOS 9.0, *) {
         searchController.loadViewIfNeeded()
         } else {
         let _ = searchController.view
         }
         */
        
        //tableView.reloadData()
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
    
    // Edit tableView when editButtonItem is tapped.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("table view begin updates")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        print("insert section: \(sectionIndex)")
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        print("delete section: \(sectionIndex)")
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            print("insert row \((newIndexPath! as NSIndexPath).row)")
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            print("delete row \((indexPath! as NSIndexPath).row)")
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            print("update row \((indexPath! as NSIndexPath).row)")
        case .move:
            print("move row \((indexPath! as NSIndexPath).row) to row \((newIndexPath! as NSIndexPath).row)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadSectionIndexTitles()
        print("table view end updates")
        tableView.endUpdates()
    }
    
    
    // MARK: - Table view data source
    
    fileprivate func configureCell(_ cell: SavedTableViewCell, _ object: SavedMO) {
        
        cell.name.text = object.name
        cell.categories.text = object.categories
        cell.yelpUrl = object.yelpUrl
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            let sectionCount = fetchedResultsController?.sections?.count ?? 0
            isTableEmpty = (sectionCount == 0) ? true : false
            return sectionCount
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
        } else {
            return filteredRestaurants.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            guard let sectionInfo = fetchedResultsController?.sections?[section] else {
                return nil
            }
            return sectionInfo.name
        } else {
            return "Top Matches"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
            fatalError("Unexpected indexPath: \(indexPath)")
        }
        
        guard let url = cell.yelpUrl else {
            fatalError("Unexpected url: \(cell.yelpUrl)")
        }
        
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle:  UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            // Remove from DB and trigger row deletion.
            updateSaved(cell: cell)
            
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Add row index.
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.tableView {
            return fetchedResultsController?.sectionIndexTitles
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
