//
//  History.swift
//  FocusOn
//
//  Created by Spencer Forrest on 18/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class History {
  private let dataController: DataController!
  init(_ dataController: DataController) {
    self.dataController = dataController
  }
  /// Request all the Goals and their tasks sorted and group by date in descending order.
  /// - Returns: NSFetchedResultsController containing all the focuses
  func historyFetchResultsController() -> NSFetchedResultsController<Focus> {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let orderSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
    fetchRequest.sortDescriptors = [dateSortDescriptor, orderSortDescriptor]
    
    let fetchedResultsController: NSFetchedResultsController<Focus> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: "date", cacheName: nil)
    try? fetchedResultsController.performFetch()
    return fetchedResultsController
  }
}
