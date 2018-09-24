//
//  TodayViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import CoreData

class TodayViewController: UIViewController, ViewControllerProtocol {
  
  var dataController: DataController!
  private var goalFecthResultsController: NSFetchedResultsController<Goal>!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    
    hideKeyboardWhenTappedAround()
    registerForKeyboardNotifications()
    
    configure()
  }
  
  private func configure() {
    let goalFecthRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
    let goalSortDescription = NSSortDescriptor(key: "creationDate", ascending: true)
    goalFecthRequest.sortDescriptors = [goalSortDescription]
    goalFecthRequest.predicate = datePredicate()
    
    goalFecthResultsController = NSFetchedResultsController(fetchRequest: goalFecthRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: "Goal")
  }
  
  private func datePredicate() -> NSCompoundPredicate {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local
    
    // Get today's beginning & end
    let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
    guard let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
      else {fatalError("Date invalid")}
    // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
    
    // Set predicate as date being today's date
    let fromPredicate = NSPredicate(format: "creationDate >= %@", dateFrom as NSDate)
    let toPredicate = NSPredicate(format: "creationDate < %@", dateTo as NSDate)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
  }
}

// -------------------------------------------------------------------------
// MARK: - Table view delegate
extension TodayViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section != 0
  }
}

// -------------------------------------------------------------------------
// MARK: - Table view data source
extension TodayViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.goalCellId) as? GoalTableViewCell {
        cell.textField.text = goalFecthResultsController.object(at: indexPath).title
        return cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.taskCellId) as? TaskTableViewCell {
        let goal: Goal = goalFecthResultsController.object(at: IndexPath(row: 0, section: 0))
        var title = ""
        cell.textField.text = ""
        cell.numberLabel.text = "\(indexPath.row + 1)"
        return cell
      }
    default: break
    }
    let identifier = indexPath.section == 0 ? Constant.goalCellId : Constant.taskCellId
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
      else { return UITableViewCell() }
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Goal for the day to focus on:" : "3 tasks to achieve your goal"
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return section == 0 ? Constant.goalCompletion : Constant.taskAttempt
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard layout
extension TodayViewController {
  private func registerForKeyboardNotifications() {
    let keyboardWillShowNotification = UIResponder.keyboardWillShowNotification
    let keyboardWillHideNotification = UIResponder.keyboardWillHideNotification
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
  }
  
  @objc func keyboardWillHide(notification: NSNotification){
    adjustLayoutForKeyboard(targetHeight: UIEdgeInsets.zero.bottom)
  }
  
  private func adjustLayoutForKeyboard(targetHeight: CGFloat) {
    tableView.contentInset.bottom = targetHeight
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard dismissal
extension TodayViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}
