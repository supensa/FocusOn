//
//  HistoryViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, ViewControllerProtocol {
  
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var completion: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var dataController: DataController!
  var fetchedResultsController: NSFetchedResultsController<Focus>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("SPENCER: disappeared")
    super.viewDidDisappear(animated)
    fetchedResultsController = nil
    tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("SPENCER: Did appear")
    super.viewDidAppear(animated)
    setupFetchResultsController()
    tableView.reloadData()
  }
  
  private func setupFetchResultsController() {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let orderSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
    fetchRequest.sortDescriptors = [dateSortDescriptor, orderSortDescriptor]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: "date", cacheName: nil)
    
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("The fetchcould not performed: \(error.localizedDescription)")
    }
  }
}

extension HistoryViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if fetchedResultsController == nil { return 0 }
    return fetchedResultsController.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fetchedResultsController == nil { return 0 }
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if fetchedResultsController == nil { return UITableViewCell() }
    let focus: Focus = fetchedResultsController.object(at: indexPath)
        
    print("SPENCER: \(String(describing: focus.title))")
    print("SPENCER: \(String(describing: focus.date))")
    print("SPENCER: \(String(describing: focus.order))")
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellId") as? HistoryTableViewCell {
      cell.textView.text = focus.title!
      cell.label.text = focus.isCompleted ? "\u{2714} "  : ""
      if focus.type == Type.goal.rawValue {
        cell.textView?.font = cell.textView?.font?.withSize(30)
      } else {
        cell.textView?.font = cell.textView?.font?.withSize(15)
      }
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "default"
  }
}

extension HistoryViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let focus: Focus  = fetchedResultsController.sections?[section].objects?.first as! Focus
    let text = dateString(date: focus.date!)
    return header(text: text)
  }
  
  private func header(text: String?) -> UIView {
    let view = UIView()
    let label = UILabel()
    label.text = text
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    return view
  }
  
  private func dateString(date: Date) -> String {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local
    
    // Get beginning & end
    let day = calendar.startOfDay(for: date) // eg. 2016-10-10 00:00:00
    let today = calendar.startOfDay(for: Date())
    
    return today == day ? Constant.today : formatDateToString(date: day)
  }
  
  private func formatDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.dateFormat
    return dateFormatter.string(from: date)
  }
}
