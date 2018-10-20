//
//  DataController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class DataController {
  private let persistentContainer: NSPersistentContainer!
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  init(xcdatamodeldName name: String) {
    persistentContainer = PersistentContainer(name: name)
  }
  
  func load() {
    persistentContainer.loadPersistentStores {
      (description, error) in
      if let error = error {
        fatalError("Unable to load persistent stores: \(error)")
      }
    }
  }
  
  func saveContext() {
    do {
      try self.context.save()
    } catch {
      fatalError("Save context failed: \(error.localizedDescription)")
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Helping Functions
extension DataController {
  /// Create a predicate for a specific date
  ///
  /// - Parameter date: Specific date
  /// - Returns: compound predicate
  func datePredicate(from date: Date = Date(), to endDate: Date? = nil) -> NSCompoundPredicate {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    // Get beginning & end
    let dateFrom = calendar.startOfDay(for: date) // eg. 2018-10-10 00:00:00 (for current Time zone but different for UTC +0000)
    
    guard let dateTo = endDate == nil ? calendar.date(byAdding: .day, value: 1, to: dateFrom) : endDate
      else {fatalError("Date invalid")}
    // Note: Times are printed in UTC. UTC times can be converted to local time
    
    print("\nDateFrom: \(dateFrom)")
    print("DateTo: \(dateTo)\n")
    
    // Set predicates
    let dateFromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
    let dateToPredicate = NSPredicate(format: "date < %@", dateTo as NSDate)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [dateFromPredicate, dateToPredicate])
  }
}
  

