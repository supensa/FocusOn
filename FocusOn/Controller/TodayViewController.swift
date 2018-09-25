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
  private var goal: Focus?
  private var tasks: [Focus]?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureDelegation()
    
    hideKeyboardWhenTappedAround()
    registerForKeyboardNotifications()
    
    configureDataRequest()
  }
  
  private func configureDelegation() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private func configureDataRequest() {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let sortDescriptior = NSSortDescriptor(key: "date", ascending: true)
    let todayPredicate = datePredicate()
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [todayPredicate])
    fetchRequest.sortDescriptors = [sortDescriptior]
    let results = try! dataController.context.fetch(fetchRequest)
    
    goal = results.filter { return $0.type == Type.goal.rawValue }.first
    let filteredTasks = results.filter { return $0.type == Type.task.rawValue }
    tasks = filteredTasks.isEmpty ? nil : filteredTasks
    
    print(goal ?? "NO GOAL")
    print(tasks ?? "NO TASK")
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
    let dateFromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
    let dateToPredicate = NSPredicate(format: "date < %@", dateTo as NSDate)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [dateFromPredicate, dateToPredicate])
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
        cell.textField.text = goal?.title
        cell.delegate = self
        return cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.taskCellId) as? TaskTableViewCell {
        cell.textField.text = tasks?[indexPath.row].title
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
      }
    default: break
    }
    
    return UITableViewCell()
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
  
  @objc private func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
  }
  
  @objc private func keyboardWillHide(notification: NSNotification){
    adjustLayoutForKeyboard(targetHeight: UIEdgeInsets.zero.bottom)
  }
  
  private func adjustLayoutForKeyboard(targetHeight: CGFloat) {
    tableView.contentInset.bottom = targetHeight
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard dismissal
extension TodayViewController {
  private func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

// -------------------------------------------------------------------------
// MARK: - Goal tableview cell delegate
extension TodayViewController: GoalTableViewCellDelegate {
  func saveGoal(text: String?) {
    let goal = self.goal == nil ? Focus(context: dataController.context) : self.goal
    goal?.type = Type.goal.rawValue
    goal?.date = Date()
    goal?.title = text
    try? dataController.context.save()
  }
}
// FIXME: Similar functions - Tasks does not work
// -------------------------------------------------------------------------
// MARK: - Task tableview cell delegate
extension TodayViewController: TaskTableViewCellDelegate {
  func saveTask(text: String?, type: Type, tag index: Int) {
    let task = tasks == nil ? Focus(context: dataController.context) : tasks?[index]
    task?.type = type.rawValue
    task?.date = Date()
    task?.title = text
    try? dataController.context.save()
  }
}
