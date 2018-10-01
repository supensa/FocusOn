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
    clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    clearButton.showsTouchWhenHighlighted = true
  }
  
  private func setupSaveButton() {
    saveButton = UIButton(type: .custom)
    saveButton.setTitle("Save", for: .normal)
    saveButton.setTitleColor(UIColor.blue, for: .normal)
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    saveButton.showsTouchWhenHighlighted = true
  }
  
  private func setupDeleteAllButton() {
    deleteAllButton = UIButton(type: .custom)
    deleteAllButton.setTitle("Delete all", for: .normal)
    deleteAllButton.setTitleColor(UIColor.red, for: .normal)
    deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
    deleteAllButton.showsTouchWhenHighlighted = true
  }
  
  @objc private func saveButtonTapped() {
    // Dismissing the keyboard will trigger "textFieldDidFinishEditing"
    dismissKeyboard()
  }
  
  @objc private func deleteAllButtonTapped() {
    clearButtonTapped()
    removeAll()
    view.endEditing(true)
  }
  
  @objc private func clearButtonTapped() {
    if let textView = view.firstResponder as? UITextView {
      let cell = textView.superview?.superview as! UITableViewCell
      cell.isSelected = false
      cell.accessoryType = .none
      textView.text = ""
      updateTableViewUI()
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Context updates
extension TodayViewController {
  
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
  
  /// Only remove this focus if it is a task.
  /// Otherwise, remove all focuses for today
  ///
  /// - Parameter focus: focus to be removed
  private func remove(focus: Focus) {
    dataController.context.delete(focus)
  }
  
  /// Update this focus
  ///
  /// - Parameters:
  ///   - focus: focus to update
  ///   - type: type of focus (goal or task)
  ///   - text: title of focus
  ///   - index: order of task
  private func update(focus: Focus, type: Type, text: String?, isCompleted: Bool? = nil, index: Int? = nil) {
    focus.type = type.rawValue
    focus.date = Date()
    focus.title = text
    if let index = index, type == .task {
      focus.order = Int16(index)
    }
    if let isCompleted = isCompleted {
      focus.isCompleted = isCompleted
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
  // TODO: Work on checkmarks
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    if cell.textView.text != nil && cell.textView.text != "" {
      cell.accessoryType = .checkmark
      processCoreData(from: cell, index: indexPath.row)
      print("Selected")
    } else {
      tableView.deselectRow(at: indexPath, animated: false)
      cell.accessoryType = .none
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    cell.accessoryType = .none
    processCoreData(from: cell, index: indexPath.row)
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
        setupGoalCell(cell: cell, indexPath: indexPath)
        return cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.taskCellId) as? TaskTableViewCell {
        setupTaskCell(cell: cell, indexPath: indexPath)
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
  
  /// Setup goal cell's text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - row: cell's in table view
  private func setupGoalCell(cell: GoalTableViewCell, indexPath: IndexPath) {
    cell.textView.text = goal?.title
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    let isSelected = goal?.isCompleted ?? false
    selectionRow(isSelected: isSelected, cell: cell, indexPath: indexPath)
  }
  /// Setup task cell's label and text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - row: cell's in table view
  private func setupTaskCell(cell: TaskTableViewCell, indexPath: IndexPath) {
    let row = indexPath.row
    cell.textView.text = tasks[row]?.title
    cell.numberLabel.text = "\(row + 1)"
    cell.tag = row
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    let isSelected = tasks[row]?.isCompleted ?? false
    selectionRow(isSelected: isSelected, cell: cell, indexPath: indexPath)
  }
  
  /// Select or deselect a row in tableView.
  /// Checkmark or uncheckmark a cell
  ///
  /// - Parameters:
  ///   - isSelected: cell should be selected
  ///   - cell: cell to select or deselect
  ///   - indexPath: indexPath of cell in TableView
  private func selectionRow(isSelected: Bool, cell: UITableViewCell, indexPath: IndexPath) {
    if isSelected {
      print("SPENCER: isCompleted loaded")
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      cell.accessoryType = .checkmark
    } else {
      print("SPENCER: NOT Completed loaded")
      tableView.deselectRow(at: indexPath, animated: true)
      cell.accessoryType = .none
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - tableview cell delegate
extension TodayViewController: TableViewCellDelegate {
  func resize(cell: TableViewCell) {
    updateTableViewUI()
    // Keep the bottom of the cell visible on the screen
    if let indexPath = tableView.indexPath(for: cell) {
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
  }
  
  func textViewDidFinishEditing(cell: TableViewCell, tag index: Int?) {
    updateTableViewUI()
    // No need to save if no changes
    guard cell.formerText != cell.textView.text else { return }
    processCoreData(from: cell, index: index)
  }
  
  /// Update or remove a "Focus" from context and persistent store
  ///
  /// - Parameters:
  ///   - cell: cell containing the data
  ///   - index: Order of the cell (for tasks cell)
  private func processCoreData(from cell: TableViewCell, index: Int?) {
    var focus: Focus!
    var typeCell: Type!
    // Check if input comes from a GoalTableViewCell or TaskTableViewCell
    // Get NSManagedObject accordingly
    if let _ = cell as? GoalTableViewCell {
      goal = goal ?? Focus(context: dataController.context)
      focus = goal
      typeCell = .goal
    }
    if let _ = cell as? TaskTableViewCell {
      tasks[index!] = tasks[index!] ?? Focus(context: dataController.context)
      focus = tasks[index!]
      typeCell = .task
    }
    // NSManagedObject will be removed if text is empty.
    // Otherwise, it will be updated
    if cell.textView.text == "" {
      remove(focus: focus)
      if typeCell == .task { tasks[index!] = nil }
      if typeCell == .goal { goal = nil }
    } else {
      let isCompleted = cell.accessoryType == .checkmark
      update(focus: focus, type: typeCell, text: cell.textView.text, isCompleted: isCompleted, index: index)
    }
    // Commit the change to context and persistent store
    try? dataController.context.save()
    print("SPENCER: Saved into Persistent Store")
  }
}
