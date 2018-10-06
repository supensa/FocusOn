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
  
  private var goalHeaderLabel: UILabel!
  private var taskHeaderLabel: UILabel!
  private var triggerGoalAnimation = false
  private var triggerTaskAnimation = false
  private var taskUnchecked = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    requestData()
    tableViewDelegation()
    hideKeyboardWhenTappedAround()
    registerForKeyboardNotifications()
    setupAccessoryView()
  }
  
  private func tableViewDelegation() {
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
      updateDates(results)
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
    
    print("SPENCER: \(String(describing: goal))")
    print("SPENCER: \(tasks)")
  }
  
  private func updateDates(_ results: [Focus]?) {
    let date = Date()
    for result in results ?? [] {
      result.date = date
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
    let sortDescriptior = NSSortDescriptor(key: "date", ascending: false)
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
    clearButton.setTitleColor(UIColor.red, for: .normal)
    clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    clearButton.showsTouchWhenHighlighted = true
  }
  
  private func setupSaveButton() {
    saveButton = UIButton(type: .custom)
    saveButton.setTitle("Save", for: .normal)
    saveButton.setTitleColor(UIColor.darkGreen, for: .normal)
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
      let cell = textView.superview?.superview as! TableViewCell
      cell.isSelected = false
      cell.setCheckmark(false)
      textView.text = ""
      updateTableViewUI()
    }
  }
  
  private func trimming(textView: UITextView) {
    textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    self.updateTableViewUI()
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
    
    saveContext()
  }
  
  /// Only remove this focus if it is a task.
  /// Otherwise, remove all focuses for today
  ///
  /// - Parameter focus: focus to be removed
  private func remove(focus: Focus) {
    dataController.context.delete(focus)
  }
  
  /// Update this focus
  /// Update all the focuses'date
  ///
  /// - Parameters:
  ///   - focus: focus to update
  ///   - type: type of focus (goal or task)
  ///   - text: title of focus
  ///   - isCompleted: completion of focus
  ///   - index: order of task
  private func update(focus: Focus, type: Type, text: String?, index: Int) {
    focus.type = type.rawValue
    focus.title = text
    if type == .task { focus.order = Int16(index) }
    
    let date = Date()
    for (_,task) in tasks {
      task.date = date
    }
    goal?.date = date
  }
  
  private func saveContext() {
    do {
      try dataController.context.save()
    } catch {
      fatalError("Save context failed: \(error.localizedDescription)")
    }
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
  // Process data when row is selected and checked
  // and textView is not empty.
  // If goal is selected and become checked then all tasks will be.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    
    trimming(textView: cell.textView)
    
    if cell.textView.text != "" {
      view.endEditing(true)
    }
    
    let isGoalCell = indexPath.section == 0
    let hasTitle = !(cell.isPlaceHolderSet() || cell.textView.text == "")
    
    switch (isGoalCell, hasTitle) {
    case (true, true):
      manageGoalCellSelection(cell)
    case (false, true):
      manageTaskCellSelection(cell, indexPath: indexPath)
    default:
      cell.isSelected = false
      cell.setCheckmark(false)
      return
    }
    tableView.reloadData()
    saveContext()
  }
  
  // Process data when row is deselected and unchecked.
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    trimming(textView: cell.textView)
    if cell.textView.text != "" {
      view.endEditing(true)
    }
    switch indexPath.section {
    case 0:
      goal?.isCompleted = false
    default:
      manageTaskCellDeSelection(row: indexPath.row)
    }
    tableView.reloadData()
    saveContext()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      goalHeaderLabel = UILabel()
    } else {
      taskHeaderLabel = UILabel()
    }
    
    let view = UIView()
    
    let label: UILabel = section == 0 ? goalHeaderLabel : taskHeaderLabel
    
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    
    var title: String?
    
    if section == 0 {
      label.font = label.font.withSize(23)
      title = goal?.isCompleted ?? false ? Constant.goalCompleted : Constant.goalUncompleted
      label.textColor = goal?.isCompleted ?? false ? UIColor.red : UIColor.black
    }
    if section == 1 {
      let count = countCompletedTasks()
      let condition = tasks.count == count && tasks.count != 0
      title = condition ? Constant.taskCompleted : "\(tasks.count - count)" + Constant.taskUncompleted
    }
    
    label.text = title
    
    if triggerGoalAnimation && section == 0 { goalCompletionAnimation() }
    if triggerTaskAnimation && section == 1 { taskAnimation(isUncheckedTask: taskUnchecked) }
    
    return view
  }
  
  private func taskAnimation(isUncheckedTask: Bool) {
    let temporaryMessage = taskUnchecked ? "Ah, no biggie, you’ll get it next time!" : "Great job on making progress!"
    let color = taskUnchecked ? UIColor.red : UIColor.darkGreen
    
    let text = self.taskHeaderLabel.text
    self.taskHeaderLabel.alpha = 0
    self.taskHeaderLabel.textColor = color
    self.taskHeaderLabel.text = temporaryMessage
    
    let animation = { self.taskHeaderLabel.alpha = 0 }
    
    let completion = {
      (completed: Bool) in
      if completed {
        self.taskHeaderLabel.textColor = UIColor.black
        self.taskHeaderLabel.text = text
        UIView.animate(withDuration: 0.5) { self.taskHeaderLabel.alpha = 1 }
      }
    }
    
    let mainCompletion = {
      (completed: Bool) in
      if completed {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: animation, completion: completion)
      }
    }
    
    UIView.setAnimationsEnabled(true)
    UIView.animate(withDuration: 0.5, animations: { self.taskHeaderLabel.alpha = 1 }, completion: mainCompletion)
    
    triggerTaskAnimation = false
    taskUnchecked = false
  }
  
  private func goalCompletionAnimation() {
    UIView.setAnimationsEnabled(true)
    
    UIView.animate(withDuration: 0.6) { () -> Void in
      self.goalHeaderLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
      self.goalHeaderLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    UIView.animate(withDuration: 0.6, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations: {
      () -> Void in
      self.goalHeaderLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
//      self.goalHeaderLabel.transform = CGAffineTransform.identity
    }, completion: nil)
    
    triggerGoalAnimation = false
  }
  
  /// Request tableView to update its UI
  ///
  /// - Parameter bool: Default value is false
  private func updateTableViewUI(withAnimation bool: Bool = false) {
    // Request tableView to update its UI
    UIView.setAnimationsEnabled(bool)
    tableView.beginUpdates()
    tableView.endUpdates()
    UIView.setAnimationsEnabled(true)
  }
  
  /// Return the number of tasks without an empty title
  ///
  /// - Returns: Count of tasks
  private func countTasksWithTitle() -> Int {
    return tasks.filter {
      let result = $1.title != ""
      return result
      }.count
  }
  
  private func countCompletedTasks() -> Int {
    return tasks.filter {
      let result = $1.isCompleted
      return result
      }.count
  }
  
  /// check mark goal and tasks cell if all tasks have a title.
  /// Otherwise, only check mark gaol cell.
  /// Save changes into persistent store. (chekmark = isCompleted)
  ///
  /// - Parameter cell: goal cell to process
  private func manageGoalCellSelection(_ cell: TableViewCell) {
    let allTasksHaveTitle = countTasksWithTitle() == tasks.count
    if allTasksHaveTitle {
      updateFocusesAs(isCompleted: allTasksHaveTitle)
    } else {
      updateFocusAsCompleted()
    }
  }
  
  /// Check mark task and goal cell if all tasks are completed.
  /// Otherwise, only check mark task cell.
  /// Save changes into persistent store. (chekmark = isCompleted)
  ///
  /// - Parameter cell: task cell to process
  private func manageTaskCellSelection(_ cell: TableViewCell, indexPath: IndexPath) {
    let areCompletedTasks = countCompletedTasks() == tasks.count - 1
    if areCompletedTasks {
      if goal?.title != "" {
        updateFocusesAs(isCompleted: areCompletedTasks)
      }
    } else {
      updateFocusAsCompleted(row: indexPath.row)
    }
  }
  
  /// Set task as uncomplete and goal cell, if needed.
  /// Save changes into persistent store. (chekmark = isCompleted)
  ///
  /// - Parameter cell: task cell to process
  private func manageTaskCellDeSelection(row: Int) {
    tasks[row]?.isCompleted = false
    if goal?.isCompleted ?? false {
      goal?.isCompleted = false
    }
    taskUnchecked = true
    triggerTaskAnimation = true
  }
  
  /// Set goal and all tasks as completed or uncompleted and
  /// save them into persistent store.
  /// Then, reload the tableView's data.
  ///
  /// - Parameter isCompleted: true if tasks are completed
  private func updateFocusesAs(isCompleted: Bool) {
    goal?.isCompleted = isCompleted
    for (_, task) in tasks {
      task.isCompleted = isCompleted
    }
    triggerGoalAnimation = true
  }
  
  /// set Focus (Goal or Task) as completed.
  ///
  /// - Parameters:
  ///   - row: task's row
  private func updateFocusAsCompleted(row: Int? = nil) {
    if let row = row {
      tasks[row]?.isCompleted = true
      triggerTaskAnimation = true
    } else {
      goal?.isCompleted = true
      triggerGoalAnimation = true
    }
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
  
  // Implemented without returning "" or nil gives a dynamic height to header sections
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "default"
  }
  
  /// Setup goal cell's text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - row: cell's in table view
  private func setupGoalCell(cell: GoalTableViewCell, indexPath: IndexPath) {
    if let title = goal?.title {
      cell.textView.text = title
      cell.textView.textColor = UIColor.black
    } else {
      cell.setPlaceHolder()
    }
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    setCellSelectionColor(cell: cell)
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
    if let title = tasks[row]?.title {
      cell.textView.text = title
      cell.textView.textColor = UIColor.black
    } else {
      cell.setPlaceHolder()
    }
    cell.numberLabel.text = "\(row + 1)"
    cell.tag = row
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    setCellSelectionColor(cell: cell)
    let isSelected = tasks[row]?.isCompleted ?? false
    selectionRow(isSelected: isSelected, cell: cell, indexPath: indexPath)
  }
  
  /// Select or deselect a row in tableView.
  /// check mark or uncheck mark a cell
  ///
  /// - Parameters:
  ///   - isSelected: cell should be selected
  ///   - cell: cell to select or deselect
  ///   - indexPath: indexPath of cell in TableView
  private func selectionRow(isSelected: Bool, cell: TableViewCell, indexPath: IndexPath) {
    if isSelected {
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      cell.setCheckmark(true)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
      cell.setCheckmark(false)
    }
  }
  
  /// Set the selection color that will apply
  ///
  /// - Parameters:
  ///   - color: Selection color
  ///   - cell: cell to apply it
  private func setCellSelectionColor(cell: UITableViewCell) {
    cell.selectedBackgroundView = UIView()
    cell.selectedBackgroundView?.backgroundColor = Constant.selectionBackgroundColor
  }
}

// -------------------------------------------------------------------------
// MARK: - Tableview cell delegate
extension TodayViewController: TableViewCellDelegate {
  func dynamicSize(cell: TableViewCell) {
    updateTableViewUI()
    // Keep the bottom of the cell visible on the screen
    if let indexPath = tableView.indexPath(for: cell) {
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
  }
  
  func textViewDidFinishEditing(cell: TableViewCell, tag index: Int) {
    updateTableViewUI()
    // No need to save if no changes
    guard cell.formerText != cell.textView.text else { return }
    processData(from: cell, index: index)
  }
  
  /// Update or remove a "Focus" from context and persistent store
  ///
  /// - Parameters:
  ///   - cell: cell containing the data
  ///   - index: Order of the cell (for tasks cell)
  private func processData(from cell: TableViewCell, index: Int) {
    var focus: Focus!
    var typeCell: Type!
    var isNewTask: Bool = false
    // Check if input comes from a GoalTableViewCell or TaskTableViewCell
    // Get NSManagedObject accordingly
    if let _ = cell as? GoalTableViewCell {
      goal = goal ?? Focus(context: dataController.context)
      focus = goal
      typeCell = .goal
    }
    if let _ = cell as? TaskTableViewCell {
      if tasks[index] == nil { isNewTask = true }
      tasks[index] = tasks[index] ?? Focus(context: dataController.context)
      focus = tasks[index]
      typeCell = .task
    }
    // NSManagedObject will be removed if text is empty.
    // Otherwise, it will be updated
    if cell.textView.text == "" {
      remove(focus: focus)
      if typeCell == .task { tasks[index] = nil }
      if typeCell == .goal { goal = nil }
    } else {
      update(focus: focus, type: typeCell, text: cell.textView.text, index: index)
      deselectGoalCell(isNewTask)
    }
    tableView.reloadData()
    // Commit the change to context and persistent store
    saveContext()
  }
  
  /// Set goal as not completed,
  /// then reload the tableView's data.
  ///
  /// - Parameter isNeeded: force the deselection
  private func deselectGoalCell(_ forced: Bool) {
    if forced {
      goal?.isCompleted = false
    }
  }
}
