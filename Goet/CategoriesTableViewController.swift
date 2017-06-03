//
//  CategoriesTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/1/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    typealias Category = (name: String, id: String)
    
    private let categories: [Category] = [
        ("All", "restaurants"),
        ("Afghan", "afghani"),
        ("African", ""),
        ("American(New)", "newamerican"),
        ("American(Traditional)", "tradamerican"),
        ("Arabian", ""),
        ("Argentine", ""),
        ("Armenian", ""),
        ("Asian Fusion", "asianfusion"),
        ("Australian", ""),
        ("Austrian", ""),
        ("Bangladeshi", ""),
        ("Barbeque", "bbq"),
        ("Basque", ""),
        ("Belgian", ""),
        ("Brasseries", ""),
        ("Brazilian", ""),
        ("Breakfast & Brunch", "breakfast_brunch"),
        ("British", ""),
        ("Buffets", ""),
        ("Burgers", ""),
        ("Burmese", ""),
        ("Cafes", ""),
        ("Cafeteria", ""),
        ("Cajun/Creole", "cajun"),
        ("Cambodian", ""),
        ("Caribbean", ""),
        ("Catalan", ""),
        ("Cheesesteaks", ""),
        ("Chicken Shop", "chickenshop"),
        ("Chicken Wings", "chicken_wings"),
        ("Chinese", ""),
        ("Comfort Food", "comfortfood"),
        ("Creperies", ""),
        ("Cuban", ""),
        ("Czech", ""),
        ("Delis", ""),
        ("Diners", ""),
        ("Dinner Theater", "dinnertheater"),
        ("Ethiopian", ""),
        ("Fast Food", "hotdogs"),
        ("Filipino", ""),
        ("Fish & Chips", "fishnchips"),
        ("Fondue", ""),
        ("Food Court", "food_court"),
        ("Food Stands", "foodstands"),
        ("Indian", "indpak")
    ]
    
    private var filtered = [Category]()
    private var mostSearched = [MostSearchedCategories]()

    private var category: Category?
    
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private var moc: NSManagedObjectContext!
    
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
    
    fileprivate var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        navigationItem.hidesBackButton = true
        
        moc = appDelegate?.managedObjectContext
        initializeFetchedResultsController()
        mostSearched = fetchedResultsController?.fetchedObjects as! [MostSearchedCategories]
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
         */
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            let _ = searchController.view
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MostSearchedCategories")
        let sortCount = NSSortDescriptor(key: "searchCount", ascending: false)
        let sortName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortCount, sortName]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }

    func getCategory() -> (name: String, id: String)? {
        print("return category: \(String(describing: category))")
        return category
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filtered = categories.filter {
                return $0.name.lowercased().contains(inputText.lowercased())
            }
        }
        tableView.reloadData()
    }

    private func addNewCategoryOrUpdateSearchCount(_ category: Category) {
        for (index, member) in mostSearched.enumerated() {
            if member.name == category.name {
                mostSearched[index].searchCount += 1
                updateSearchCount(for: member.name!, value: Int(mostSearched[index].searchCount))
                return
            }
        }
        addCategory(name: category.name, id: category.id, searchCount: 1)
        mostSearched = fetchedResultsController?.fetchedObjects as! [MostSearchedCategories]
    }

    private func updateSearchCount(for name: String, value: Int) {
        let request = NSFetchRequest<MostSearchedCategories>(entityName: "MostSearchedCategories")
        request.predicate = NSPredicate(format: "name == %@", name)
        
        guard let object = try? moc.fetch(request).first,
                let obj = object else {
            fatalError("Error fetching obj from MostSearchedCategories entity.")
        }
        obj.setValue(Int64(value), forKey: "searchCount")
        
        appDelegate?.saveContext()
    }
    
    private func addCategory(name: String, id: String, searchCount: Int) {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "MostSearchedCategories", into: moc) as? MostSearchedCategories else {
            fatalError("Error adding new category.")
        }
        obj.name = name
        obj.id = id
        obj.searchCount = Int64(searchCount)

        appDelegate?.saveContext()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if !searchController.isActive {
            if !mostSearched.isEmpty {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !searchController.isActive {
            if !mostSearched.isEmpty {
                if section == 0 {
                    return mostSearched.count > 3 ? 3 : mostSearched.count
                } else {
                    return categories.count
                }
            } else {
                return categories.count
            }
        } else {
            return filtered.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath)

        // Configure the cell...
        if !searchController.isActive {
            if !mostSearched.isEmpty {
                if indexPath.section == 0 {
                    cell.textLabel?.text = mostSearched[indexPath.row].name! + " " +  String(mostSearched[indexPath.row].searchCount)
                } else {
                    cell.textLabel?.text = categories[indexPath.row].name
                }
            } else {
                cell.textLabel?.text = categories[indexPath.row].name
            }
        } else {
            cell.textLabel?.text = filtered[indexPath.row].name
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searchController.isActive {
            if !mostSearched.isEmpty {
                if indexPath.section == 1 {
                    category = categories[indexPath.row]
                } else {
                    category = Category(name: "", id: "")
                    category?.name = mostSearched[indexPath.row].name!
                    category?.id = mostSearched[indexPath.row].id!
                }
            } else {
                category = categories[indexPath.row]
            }
        } else {
            category = filtered[indexPath.row]
        }
        
        guard let selectedCategory = category else {
            fatalError("Unexpected category")
        }
        addNewCategoryOrUpdateSearchCount(selectedCategory)
        
        performSegue(withIdentifier: "unwindFromCategories", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if !searchController.isActive {
            if !mostSearched.isEmpty {
                if section == 0 {
                    return "Most searched:"
                } else {
                    return "Categories:"
                }
            } else {
                return "Categories:"
            }
        } else {
            return "Filtered:"
        }
    }
    
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /**
         Force to pop CategoriesTableVC from navigation stack when using unwind segue, otherwise warning: popToViewController:transition: called on <UINavigationController 0x7fcef101b000> while an existing transition or presentation is occurring; the navigation stack will not be updated.
         */
        if searchController.isActive {
            navigationController?.popViewController(animated: false)
        }
    }

}
