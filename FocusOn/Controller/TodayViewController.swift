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
  private var tasks = Dictionary<Int, Focus>()
  
  @IBOutlet weak var tableView: UITableView!
  
  private var accessoryView: UIView!
  private var saveButton: UIButton!
  private var clearButton: UIButton!
  private var deleteAllButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    requestData()
    configureDelegation()
    hideKeyboardWhenTappedAround()
    registerForKeyboardNotifications()
    setupAccessoryView()
  }
  
  private func configureDelegation() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  /// Retrieve a goal and its tasks
  private func requestData() {
    // Request previous day's unachieved goal
    let previousGoal = requestPreviousDayGoal()
    var results: [Focus]?
    
    if let goal = previousGoal {
      // Request previous day's unachieved goal and its tasks
      let previousDate = goal.date!
      results = requestData(date: previousDate)
      // Update (tasks and goal) dates to today
      // FIXME: Remove to update dates to today
      //      updateDates(results)
    } else {
      // Request today's goal and tasks
      results = requestData(date: Date())
    }
    // Filter out the the Goal
    goal = results?.filter { return $0.type == Type.goal.rawValue }.first
    // Filter out in "order" the Tasks
    results = results?.filter { return $0.type == Type.task.rawValue }
    for result in results ?? [] {
      let index: Int = Int(result.order)
      tasks[index] = result
    }
    
    print(goal ?? "NO GOAL")
    print(tasks)
  }
  
  private func updateDates(_ results: [Focus]?) {
    for result in results ?? [] {
      result.date = Date()
    }
  }
  
  /// Request a goal and its tasks for a specifice date
  ///
  /// - Parameter date: goal and tasks associated date
  /// - Returns: goal and tasks if any
  private func requestData(date: Date) -> [Focus]? {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let predicate = datePredicate(date: date)
    fetchRequest.predicate = predicate
    let results = try? dataController.context.fetch(fetchRequest)
    return results
  }
  
  /// Request the last unachieved Goal
  ///
  /// - Returns: last uncompleted goal if any
  private func requestPreviousDayGoal() -> Focus? {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let sortDescriptior = NSSortDescriptor(key: "date", ascending: true)
    let goalPredicate = NSPredicate(format: "type = %@", Type.goal.rawValue)
    let completedPredicate = NSPredicate(format: "isCompleted = %@", NSNumber(value: false))
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [goalPredicate, completedPredicate])
    fetchRequest.sortDescriptors = [sortDescriptior]
    fetchRequest.predicate = compoundPredicate
    fetchRequest.fetchLimit = 1
    let results = try? dataController.context.fetch(fetchRequest)
    
    return results?.first
  }
  
  /// Create a predicate for a specific date
  ///
  /// - Parameter date: Specific date
  /// - Returns: compound predicate
  private func datePredicate(date: Date = Date()) -> NSCompoundPredicate {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local
    
    // Get beginning & end
    let dateFrom = calendar.startOfDay(for: date) // eg. 2016-10-10 00:00:00
    guard let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
      else {fatalError("Date invalid")}
    // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
    
    // Set predicates
    let dateFromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
    let dateToPredicate = NSPredicate(format: "date < %@", dateTo as NSDate)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [dateFromPredicate, dateToPredicate])
  }
}

// -------------------------------------------------------------------------
// MARK: - Accesory View setup
extension TodayViewController {
  private func setupAccessoryView() {
    instantiateAccessoryView()
    
    setupSaveButton()
    setupClearButton()
    setupDeleteAllButton()
    
    accessoryView.addSubview(saveButton)
    accessoryView.addSubview(clearButton)
    accessoryView.addSubview(deleteAllButton)
    
    setupAccessoryViewConstraints()
  }
  
  private func instantiateAccessoryView() {
    accessoryView = UIView(frame: .zero)
    accessoryView.backgroundColor = .white
    accessoryView.alpha = 1
    accessoryView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
  }
  
  private func setupAccessoryViewConstraints() {
    accessoryView.translatesAutoresizingMaskIntoConstraints = false
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      deleteAllButton.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor),
      deleteAllButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
      clearButton.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor, constant: 16),
      clearButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
      saveButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -16),
      saveButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor)
      ])
  }
  
  private func setupClearButton() {
    clearButton = UIButton(type: .custom)
    clearButton.setTitle("Clear", for: .normal)
    clearButton.setTitleColor(UIColor.blue, for: .normal)
    clearButton.addTarget(self, action: #selector(clearCurrentTextView), for: .touchUpInside)
    clearButton.showsTouchWhenHighlighted = true
  }
  
  private func setupSaveButton() {
    saveButton = UIButton(type: .custom)
    saveButton.setTitle("Save", for: .normal)
    saveButton.setTitleColor(UIColor.blue, for: .normal)
    // Dismissing the keyboard will trigger "textFieldDidFinishEditing"
    saveButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    saveButton.showsTouchWhenHighlighted = true
  }
  
  private func setupDeleteAllButton() {
    deleteAllButton = UIButton(type: .custom)
    deleteAllButton.setTitle("Delete all", for: .normal)
    deleteAllButton.setTitleColor(UIColor.red, for: .normal)
    deleteAllButton.addTarget(self, action: #selector(deleteAllFocuses), for: .touchUpInside)
    deleteAllButton.showsTouchWhenHighlighted = true
  }
  
  @objc private func deleteAllFocuses() {
    clearCurrentTextView()
    removeAll()
    view.endEditing(true)
  }
  
  @objc private func clearCurrentTextView() {
    if let textView = view.firstResponder as? UITextView {
      textView.text = ""
      updateTableViewUI()
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Context updates
extension TodayViewController {
  
  /// Only remove this focus if it is a task.
  /// Otherwise, remove all focuses for today
  ///
  /// - Parameter focus: focus to be removed
  private func remove(focus: Focus) {
    dataController.context.delete(focus)
  }
  
  /// Remove today's goal and tasks
  @objc private func removeAll() {
    guard goal != nil || tasks.count > 0
      else { return }
    
    if let goal = goal {
      dataController.context.delete(goal)
    }
    goal = nil
    
    for (_, task) in tasks {
      dataController.context.delete(task)
    }
    tasks.removeAll()
    
    tableView.reloadData()
    
    try? dataController.context.save()
  }
  
  /// Update this focus
  ///
  /// - Parameters:
  ///   - focus: focus to update
  ///   - type: type of focus (goal or task)
  ///   - text: title of focus
  ///   - index: order of task
  private func update(focus: Focus, type: Type, text: String?, index: Int?) {
    focus.type = type.rawValue
    focus.date = Date()
    focus.title = text
    if let index = index {
      focus.order = Int16(index)
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard layout
extension TodayViewController {
  
  private func registerForKeyboardNotifications() {
    // FIXME: Remove Notification at the end
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
    tap.delegate = self
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

// -------------------------------------------------------------------------
// MARK: - Gesture recognizer delegate
extension TodayViewController: UIGestureRecognizerDelegate {
  // TableView's Cells won't trigger UITapGestureRecognizer.
  // No interference with keyboard dissmissal and edit textField.
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if let view = touch.view {
      for cell in tableView.visibleCells {
        if view.isDescendant(of: cell) {
          return false
        }
      }
    }
    return true
  }
}

// -------------------------------------------------------------------------
// MARK: - Table view delegate
extension TodayViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    print("Selected")
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
    print("Deselected")
  }
  
  /// Request tableView to update its UI
  ///
  /// - Parameter bool: Default value is false
  private func updateTableViewUI(withAnimation bool: Bool = false) {
    // Request tableView to update its UI
    UIView.setAnimationsEnabled(bool)
    tableView.beginUpdates()
    tableView.endUpdates()
    UIView.setAnimationsEnabled(bool)
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
        cell.textView.text = goal?.title
        cell.textView.inputAccessoryView = accessoryView
        cell.delegate = self
        return cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.taskCellId) as? TaskTableViewCell {
        setupTaskCell(cell: cell, row: indexPath.row)
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
  
  /// Setup task cell's label and text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - row: cell's in table view
  private func setupTaskCell(cell: TaskTableViewCell, row: Int) {
    cell.textView.text = tasks[row]?.title
    cell.numberLabel.text = "\(row + 1)"
    cell.tag = row
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
  }
}

// -------------------------------------------------------------------------
// MARK: - tableview cell delegate
extension TodayViewController: TableViewCellDelegate {
  
  func resize(cell: UITableViewCell) {
    updateTableViewUI()
    // Keep the bottom of the cell visible on the screen
    let indexPath = tableView.indexPath(for: cell)!
    tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
  }
  
  func textFieldDidFinishEditing(text: String?, typeCell: Type, tag index: Int? = nil) {
    var focus: Focus!
    // Check if input comes from a GoalTableViewCell or TaskTableViewCell
    // Get NSManagedObject accordingly
    switch typeCell {
    case .goal:
      goal = goal ?? Focus(context: dataController.context)
      focus = goal
    case .task:
      tasks[index!] = tasks[index!] ?? Focus(context: dataController.context)
      focus = tasks[index!]
    }
    // NSManagedObject will be removed if text is empty.
    // Otherwise, it will be updated
    if text == "" {
      remove(focus: focus)
      if typeCell == .task { tasks[index!] = nil }
    } else {
      update(focus: focus, type: typeCell, text: text, index: index)
    }
    // Commit the change to context and persistent store
    try? dataController.context.save()
  }
}
