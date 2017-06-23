//
//  CategoriesTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/1/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainer: UIView!
    
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
        ("French", ""),
        ("Game Meat", "gamemeat"),
        ("Gastropubs", ""),
        ("German", ""),
        ("Gluten-Free", "gluten_free"),
        ("Greek", ""),
        ("Guamanian", ""),
        ("Halal", ""),
        ("Hawaiian", ""),
        ("Himalayan/Nepalese", "himalayan"),
        ("Honduran", ""),
        ("Hong Kong Style Cafe", "hkcafe"),
        ("Hot Dogs", "hotdog"),
        ("Hot Pot", "hotpot"),
        ("Hungarian", ""),
        ("Iberian", ""),
        ("Indian", "indpak"),
        ("Indonesian", ""),
        ("Irish", ""),
        ("Italian", ""),
        ("Japanese", ""),
        ("Kebab", ""),
        ("Korean", ""),
        ("Kosher", ""),
        ("Laotian", ""),
        ("Latin American", "latin"),
        ("Live/Raw Food", "raw_food"),
        ("Malaysian", ""),
        ("Mediterranean", ""),
        ("Mexican", ""),
        ("Middle Eastern", "mideastern"),
        ("Modern European", "modern_european"),
        ("Mongolian", ""),
        ("Moroccan", ""),
        ("New Mexican Cuisine", "newmexican"),
        ("Nicaraguan", ""),
        ("Noodles", ""),
        ("Pakistani", ""),
        ("Pan Asian", "panasian"),
        ("Persian/Iranian", "persian"),
        ("Peruvian", ""),
        ("Pizza", ""),
        ("Polish", ""),
        ("Pop-Up Restaurants", "popuprestaurants"),
        ("Portuguese", ""),
        ("Poutineries", ""),
        ("Russian", ""),
        ("Salad", ""),
        ("Sandwiches", ""),
        ("Scandinavian", ""),
        ("Scottish", ""),
        ("Seafood", ""),
        ("Singaporean", ""),
        ("Slovakian", ""),
        ("Soul Food", "soulfood"),
        ("Soup", ""),
        ("Southern", ""),
        ("Spanish", ""),
        ("Sri Lankan", "srilankan"),
        ("Steakhouses", "steak"),
        ("Supper Clubs", "supperclubs"),
        ("Sushi Bars", "sushi"),
        ("Syrian", ""),
        ("Taiwanese", ""),
        ("Tapas Bars", "tapas"),
        ("Tapas/Small Plates", "tapasmallplates"),
        ("Tex-Mex", ""),
        ("Thai", ""),
        ("Turkish", ""),
        ("Ukrainian", ""),
        ("Uzbek", ""),
        ("Vegan", ""),
        ("Vegetarian", ""),
        ("Vietnamese", ""),
        ("Waffles", ""),
        ("Wraps", "")        
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
    //private var searchResultsVC: UITableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.hidesBackButton = true
        
        //tableView.sectionIndexMinimumDisplayRowCount
        
        //navigationController!.hidesBarsOnSwipe = true
        
        moc = appDelegate?.managedObjectContext
        
        // The navigation bar's shadowImage is set to a transparent image.  In
        // addition to providing a custom background image, this removes
        // the grey hairline at the bottom of the navigation bar.  The
        // ExtendedNavBarView will draw its own hairline.
        navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        // "Pixel" is a solid white 1x1 image.
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)

        initializeFetchedResultsController()
        mostSearched = fetchedResultsController?.fetchedObjects as! [MostSearchedCategories]
        
        tableView.dataSource = self
        tableView.delegate = self
        /*
        searchResultsVC = UITableViewController(style: .grouped)
        searchResultsVC.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoriesCell")
        searchResultsVC.tableView.dataSource = self
        searchResultsVC.tableView.delegate = self
        //searchResultsVC.extendedLayoutIncludesOpaqueBars = true
        //searchResultsVC.automaticallyAdjustsScrollViewInsets = true
        //searchResultsVC.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        */
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.searchBar.barStyle = .default
        searchController.searchBar.placeholder = "Search categories..."
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .any, barMetrics: .default)
        searchController.searchBar.barTintColor = UIColor(red: 80 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)
        //searchController.searchBar.delegate = self
        searchBarContainer.addSubview(searchController.searchBar)
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        //extendedLayoutIncludesOpaqueBars = true
        //edgesForExtendedLayout = .bottom
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
         */
        searchController.loadViewIfNeeded()
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

    // Edit tableView when editButtonItem is tapped.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    /*
    func willPresentSearchController(_ searchController: UISearchController) {
        searchResultsVC.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        /*
        if navigationItem.title != "Searching categories..." {
           navigationItem.title = "Searching categories..."
        }
        if navigationController!.navigationBar.isHidden {
            navigationController!.setNavigationBarHidden(false, animated: false)
        }
        */
    }
    */
    /*
    func willDismissSearchController(_ searchController: UISearchController) {
        if navigationItem.title != "Categories" {
            navigationItem.title = "Categories"
        }
    }
    */
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filtered = categories.filter {
                return $0.name.lowercased().contains(inputText.lowercased())
            }
        }
        // Scroll table to top. Otherwise search results might be overlapped by search bar.
        if tableView.contentOffset != CGPoint.zero {
            tableView.setContentOffset(CGPoint.zero, animated: false)
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
        
        appDelegate?.saveContext { error in
            if let err = error {
                let alert = UIAlertController(
                    title: "\(err)",
                    message: "Sorry, it appears that there are some issues updating this search count. This search won't be counted.",
                    actions: [.ok]
                )
                present(alert, animated: false, completion: nil)
            }
        }
    }
    
    private func addCategory(name: String, id: String, searchCount: Int) {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "MostSearchedCategories", into: moc) as? MostSearchedCategories else {
            fatalError("Error adding new category.")
        }
        obj.name = name
        obj.id = id
        obj.searchCount = Int64(searchCount)

        appDelegate?.saveContext { error in
            if let err = error {
                let alert = UIAlertController(
                    title: "\(err)",
                    message: "Sorry, it appears that this search couldn't be counted and saved, but you can still use the app.",
                    actions: [.ok]
                )
                present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            UIView.animate(
                withDuration: 0.8,
                animations: {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                },
                completion: nil
            )
        } else {            
            UIView.animate(
                withDuration: 0.8,
                animations: {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                },
                completion: nil
            )
        }
    }
 
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            if !mostSearched.isEmpty {
                return 2
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != "" {
            return filtered.count
        } else {
            if !mostSearched.isEmpty {
                if section == 0 {
                    return mostSearched.count > 3 ? 3 : mostSearched.count
                } else {
                    return categories.count
                }
            } else {
                return categories.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath)

        // Configure the cell...
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel?.text = filtered[indexPath.row].name
        } else {
            if !mostSearched.isEmpty {
                if indexPath.section == 0 {
                    cell.textLabel?.text = mostSearched[indexPath.row].name!
                } else {
                    cell.textLabel?.text = categories[indexPath.row].name
                }
            } else {
                cell.textLabel?.text = categories[indexPath.row].name
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            category = filtered[indexPath.row]
        } else {
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
        }
        
        guard let selectedCategory = category else {
            fatalError("Unexpected category")
        }
        addNewCategoryOrUpdateSearchCount(selectedCategory)
        
        performSegue(withIdentifier: "unwindFromCategories", sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return "Suggestions"
        } else {
            if !mostSearched.isEmpty {
                if section == 0 {
                    return "Top 3 Searches"
                } else {
                    return "Categories"
                }
            } else {
                return "Categories"
            }
        }
    }
    /*
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            print("Couldn't get section view.")
            return
        }
        headerView.textLabel?.font.withSize(10)
        headerView.textLabel?.textColor = UIColor.lightGray
        headerView.textLabel?.alignmentRectInsets
    }
    */
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return navigationController!.navigationBar.bounds.height
    }
    */
    
    // Add row index.
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        return categories.map({ String($0.name.characters.first!) }).unique
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let idx = getIndex(from: categories.map({ $0.name }), by: title.characters.first!) else {
            fatalError("categories doesn't have a name with the given first letter: \(title)")
        }
        //print("title: \(title), index: \(idx)")
        let section = mostSearched.isEmpty ? 0 : 1
        let indexPath = IndexPath(row: idx, section: section)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        return -1
    }
    
    private func getIndex(from sorted: [String], by firstLetter: Character) -> Int? {
        for (index, element) in sorted.enumerated() {
            if element.characters.first == firstLetter {
                return index
            }
        }
        return nil
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
        //navigationController!.hidesBarsOnSwipe = false
        /**
         Force to pop CategoriesVC from navigation stack when using unwind segue, otherwise warning: popToViewController:transition: called on <UINavigationController 0x7fcef101b000> while an existing transition or presentation is occurring; the navigation stack will not be updated.
         */
        if searchController.isActive {
            if navigationController!.navigationBar.isHidden {
                //navigationController!.navigationBar.isHidden = false
                navigationController!.setNavigationBarHidden(false, animated: false)
            }
            navigationController?.popViewController(animated: false)
        }
    }

}

extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var dict = Dictionary<Iterator.Element, Bool>()
        return self.filter({ dict.updateValue(true, forKey: $0) == nil })
    }
}
