//
//  CoreDataTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 9/17/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //view.addObserver(self, forKeyPath: "hasChanges", options: .new, context: nil)
        //print("added observer")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // Add KVO to context.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("context changes has been observed")
        if keyPath == "hasChanges" && object is NSManagedObjectContext? {
            // Save uncommitted changes to DB.
            if let objContext = object as? NSManagedObjectContext {
                do {
                    try objContext.save()
                    print("instance saved")
                } catch let error {
                    print("Core data saving error: \(error)")
                }
            }
        }
        // Deregister observer.
        view.removeObserver(self, forKeyPath: "hasChanges")
    }
    */
    
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
    /*
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name.uppercased()
    }
    */
    
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
        print("table view end updates")
        tableView.endUpdates()
    }

}
