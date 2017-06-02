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
        ("All", "restaurants"), ("Chinese", "chinese"), ("Indian", "indpak")
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
    
    fileprivate var searchResultsVC: UITableViewController!
    fileprivate var searchController: UISearchController!
    //private var leftBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("==category view did load")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //leftBarButtonItem = navigationItem.leftBarButtonItem
        //navigationItem.leftBarButtonItem = nil
        
        tableView.contentInset.top = 20
        
        moc = appDelegate?.managedObjectContext
        initializeFetchedResultsController()
        mostSearched = fetchedResultsController?.fetchedObjects as! [MostSearchedCategories]
        //print("most searched: \(String(describing: mostSearched))")
        
        // Configure search controller and search results vc.
        searchResultsVC = UITableViewController(style: .plain)
        //searchResultsVC.tableView.register(nib, forCellReuseIdentifier: "savedCell")
        searchResultsVC.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoriesCell")
        searchResultsVC.tableView.dataSource = self
        searchResultsVC.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        //navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.sizeToFit()
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
         */
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            let _ = searchController.view
        }
    }

    /*
    override func viewDidDisappear(_ animated: Bool) {
        //navigationItem.titleView = nil
        //navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    */
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
        searchResultsVC.tableView.reloadData()
    }

    private func addNewCategoryOrUpdateSearchCount(_ category: Category) {
        print("add new or update==")
        for (index, member) in mostSearched.enumerated() {
            if member.name == category.name {
                print("update==")
                mostSearched[index].searchCount += 1
                print("search count==: \(Int(mostSearched[index].searchCount))")
                updateSearchCount(for: member.name!, value: Int(mostSearched[index].searchCount))
                return
            }
        }
        print("add new==")
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
        
        print("save updated==")
        appDelegate?.saveContext()
    }
    
    private func addCategory(name: String, id: String, searchCount: Int) {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "MostSearchedCategories", into: moc) as? MostSearchedCategories else {
            fatalError("Error adding new category.")
        }

        obj.name = name
        obj.id = id
        obj.searchCount = Int64(searchCount)

        print("save newly added==")
        appDelegate?.saveContext()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if tableView == self.tableView {
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
        if tableView == self.tableView {
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
        if tableView == self.tableView {
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
        if tableView == self.tableView {
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
        
        if tableView == self.tableView {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}