//
//  ProgressViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import Charts

class ProgressViewController: ViewController {
  @IBOutlet weak var barChartView: HorizontalBarChartView!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  var labels = [String]()
  var completedGoals = [Double]()
  var completedTasks = [Double]()
  var goalDataSet: BarChartDataSet!
  var taskDataSet: BarChartDataSet!
  private var model: Progress!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    model = Progress(self.dataController)
    segmentControl.selectedSegmentIndex = 0
    
    barChartView.noDataText = "You need to provide data for this chart."
    //legend
    let legend = barChartView.legend
    legend.enabled = true
    legend.horizontalAlignment = .center
    legend.verticalAlignment = .top
    legend.yOffset = 0
    legend.xOffset = 0
    legend.orientation = .horizontal
    
    let xaxis = barChartView.xAxis
    xaxis.drawGridLinesEnabled = false
    xaxis.labelPosition = .bottom
    xaxis.centerAxisLabelsEnabled = true
    xaxis.valueFormatter = IndexAxisValueFormatter(values: self.labels)
    xaxis.setLabelCount(self.labels.count, force: false)
    
    barChartView.drawValueAboveBarEnabled = true
    
    let rightAxis = barChartView.rightAxis
    rightAxis.enabled = false
    
    let leftAxis = barChartView.leftAxis
    leftAxis.axisMinimum = 0
    leftAxis.axisMaximum = 100
    leftAxis.drawGridLinesEnabled = true
    
    // Background colors
    barChartView.backgroundColor = Constant.selectionBackgroundColor
    barChartView.tintColor = .white
    barChartView.drawGridBackgroundEnabled = true
    barChartView.gridBackgroundColor = UIColor.white
    // Disabling user interaction features
    barChartView.scaleYEnabled = false
    barChartView.scaleXEnabled = false
    barChartView.pinchZoomEnabled = false
    barChartView.doubleTapToZoomEnabled = false
    barChartView.highlightPerTapEnabled = true
    
    barChartView.minOffset = 30
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.loadDataInGraph()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.loadDataInGraph(isEmpty: true)
  }
  
  @IBAction func periodChanged() {
    self.loadDataInGraph()
  }
  
  /// Setup horizontal barchart accordingly to the data
  ///
  /// - Parameter isEmpty: if graph should be empty
  private func loadDataInGraph(isEmpty: Bool = false) {
    let index = isEmpty ? -1 : self.segmentControl.selectedSegmentIndex
    switch index {
    case Constant.monthlySegmentIndex:
      let tuple = model.completedFocuses(isWeekly: false)
      self.completedGoals = tuple.0
      self.completedTasks = tuple.1
      self.labels = model.labels
    case Constant.weeklySegmentIndex:
      let tuple = model.completedFocuses(isWeekly: true)
      self.completedGoals = tuple.0
      self.completedTasks = tuple.1
      self.labels = model.labels
    default:
      self.labels = [String]()
      self.completedGoals = [Double]()
      self.completedTasks = [Double]()
    }
    
    let xaxis = barChartView.xAxis
    xaxis.valueFormatter = IndexAxisValueFormatter(values: self.labels)
    xaxis.setLabelCount(self.labels.count, force: false)
    
    setChart()
  }
  
  // Load or remove data
  private func setChart() {
    if completedGoals.isEmpty && completedTasks.isEmpty {
      barChartView.data = nil
      barChartView.notifyDataSetChanged()
    } else {
      updateDataSet()
      updateBarChartData()
      barChartView.notifyDataSetChanged()
    }
  }
  // Setup bars
  private func updateBarChartData() {
    let chartData = BarChartData(dataSets: [taskDataSet, goalDataSet])
    chartData.setValueFormatter(Formatter())
    let barWidth = 0.4
    let barSpace = 0.0
    let groupSpace = 0.2
    chartData.barWidth = barWidth
    // (0.4 + 0.00) * 2 + 0.2 = 1.00 -> interval per "group"
    // (barWidth + barSpace) * (no.of.bars) + groupSpace = 1.00 -> interval per "group"
    let groupCount = self.labels.count
    let startYear = 0
    
    barChartView.xAxis.axisMinimum = Double(startYear)
    barChartView.xAxis.axisMaximum = Double(startYear) + Double(groupCount)
    chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
    barChartView.data = chartData
  }
  // Setup legend, grid and data
  private func updateDataSet() {
    var goalDataEntries: [BarChartDataEntry] = []
    var taskDataEntries: [BarChartDataEntry] = []
    
    for i in 0..<self.labels.count {
      
      let dataEntry = BarChartDataEntry(x: Double(i) , y: self.completedGoals[i])
      goalDataEntries.append(dataEntry)
      
      let dataEntry1 = BarChartDataEntry(x: Double(i) , y: self.completedTasks[i])
      taskDataEntries.append(dataEntry1)
    }
    
    goalDataSet = BarChartDataSet(entries: goalDataEntries, label: "% goals completed")
    taskDataSet = BarChartDataSet(entries: taskDataEntries, label: "% tasks completed")
    
    goalDataSet.colors = [UIColor.black]
    goalDataSet.highlightColor = .clear
    goalDataSet.drawValuesEnabled = true
    
    taskDataSet.colors = [UIColor.lightGray]
    taskDataSet.highlightColor = .clear
    taskDataSet.drawValuesEnabled = true
  }
}

/// Needed class conforming to ValueFormatter protocol.
/// Used to round value and show it on graph if not equal to 0.0
class Formatter: ValueFormatter {
  func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
    return value == 0.0 ? "" : String.init(format: "%.0f", value.rounded())
  }
}
