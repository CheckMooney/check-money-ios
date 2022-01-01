//
//  AnalyticsTabViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/20.
//

import UIKit
import Charts

class SummaryViewController: ChildViewController, ChartViewDelegate {
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var explainingLabel: UILabel!
    @IBOutlet weak var chartStackView: UIStackView!
    
    @IBOutlet weak var barChartLabel: UILabel!
    @IBOutlet weak var barChartSegControl: UISegmentedControl!
    @IBOutlet weak var pieChartLabel: UILabel!
    @IBOutlet weak var pieChartSegControl: UISegmentedControl!
    
    private var year = Calendar.current.component(.year, from: Date())
    private var month = Calendar.current.component(.month, from: Date())
    private var day = Calendar.current.component(.day, from: Date())
    var pickerviewSetting = TransactionDatePickerSetting()
    
    var transactionData = [Transaction]()
    
    override func viewDidLoad() {
        headLabel.text = "\(year)년 \(month)월"
        getTransactionData()
    }
    
    func getTransactionData() {
        NetworkHandler.request(method: .GET, endpoint: "/transactions", request: EmptyRequest(), parameters: ["page":"1", "limit":"10000", "date":"\(year)"]) { (success, response: QueryTransactionResponse?) in
            DispatchQueue.main.async {
                guard success, let res = response else {
                    print("fail to load data in SummaryViewController")
                    self.explainingLabel.isHidden = false
                    self.explainingLabel.text = "내역을 가져오는데 실패했어요."
                    self.chartStackView.isHidden = true
                    return
                }
                if res.count == 0 {
                    self.explainingLabel.isHidden = false
                    self.explainingLabel.text = "보여줄 내역이 없어요."
                    self.chartStackView.isHidden = true
                    return
                }
                self.explainingLabel.isHidden = true
                self.chartStackView.isHidden = false
                self.transactionData = res.rows
                self.setBarChart(segmentedControlIndex: 0)
                self.setPieChart(segmentedControlIndex: 0)
            }
        }
    }
    
    @IBAction func calenderButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "날짜 선택", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 40, width: 250, height: 140))
        
        alert.view.addSubview(pickerView)
        pickerView.delegate = pickerviewSetting
        pickerView.dataSource = pickerviewSetting
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "이동", style: .default, handler: { _ in
            self.month = pickerView.selectedRow(inComponent: 1) + 1
            self.year = Calendar.current.component(.year, from: Date()) - pickerView.numberOfRows(inComponent: 0) + pickerView.selectedRow(inComponent: 0) + 1
            DispatchQueue.main.async {
                self.viewDidLoad()
            }
        }))
        pickerView.selectRow(pickerviewSetting.yearList.count - 1, inComponent: 0, animated: true)
        pickerView.selectRow(Calendar.current.component(.month, from: Date()) - 1, inComponent: 1, animated: true)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func barChartOptionSelected(_ sender: Any) {
        setBarChart(segmentedControlIndex: barChartSegControl.selectedSegmentIndex)
    }
    
    @IBAction func pieChartOptionSelected(_ sender: Any) {
        setPieChart(segmentedControlIndex: pieChartSegControl.selectedSegmentIndex)
    }
    
    func setBarChart(segmentedControlIndex index: Int) {
        var consumptionData = Array(repeating: 0.0, count: index == 0 ? 12 : getMaxDate(month: month))
        var incomeData = Array(repeating: 0.0, count: index == 0 ? 12 : getMaxDate(month: month))
        var totalPrice = 0.0
        for t in transactionData {
            let date = t.date.split(separator: "-")
            if index == 0 {
                // 월별
                if t.is_consumption == 1 {
                    consumptionData[Int(date[1])! - 1] += Double(t.price)
                    if Int(date[1])! <= month || t.price > 0 {
                        totalPrice += Double(t.price)
                    }
                } else {
                    incomeData[Int(date[1])! - 1] += Double(t.price)
                }
            } else {
                // 일별
                if Int(date[1]) != month {
                    continue
                }
                if t.is_consumption == 1 {
                    consumptionData[Int(date[2])! - 1] += Double(t.price)
                    if Int(date[2])! <= day || t.price > 0 {
                        totalPrice += Double(t.price)
                    }
                } else {
                    incomeData[Int(date[2])! - 1] += Double(t.price)
                }
            }
        }
        let nonZeroCount = consumptionData.filter{$0 > 0.0}.count
        barChartLabel.text = "\(index == 0 ? "한 달" : "하루")에 평균 \(nonZeroCount == 0 ? 0 : (Int(totalPrice) / nonZeroCount))원 정도 소비해요."
        
        var count = 0
        let outcomeEntries = consumptionData.map { price -> BarChartDataEntry in
            count += 1
            return BarChartDataEntry(x: Double(count), y: price)
        }
        count = 0
        let incomeEntries = incomeData.map { price -> BarChartDataEntry in
            count += 1
            return BarChartDataEntry(x: Double(count), y: price)
        }
        
        let consumption = BarChartDataSet(entries: outcomeEntries, label: "지출")
        consumption.setColor(UIColor(red: 1, green: 100/255, blue: 175/255, alpha: 1))
        let income = BarChartDataSet(entries: incomeEntries, label: "수입")
        income.setColor(UIColor(red: 120/255, green: 228/255, blue: 1, alpha: 1))
        
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        // (groupSpace * barSpace) * n + groupSpace = 1
        
        let data = BarChartData(dataSets: [consumption, income])
        data.highlightEnabled = false
        data.barWidth = barWidth
        self.barChartView.xAxis.axisMinimum = 1
        self.barChartView.xAxis.granularity = 1
        self.barChartView.xAxis.centerAxisLabelsEnabled = true
        self.barChartView.xAxis.axisMaximum = 1 + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * (Double(consumptionData.count))
        data.groupBars(fromX: 1, groupSpace: groupSpace, barSpace: barSpace)
        self.barChartView.data = data
        self.barChartView.xAxis.setLabelCount(consumptionData.count, force: false)
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.leftAxis.axisMinimum = 0
        self.barChartView.rightAxis.enabled = false
        self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.barChartView.zoom(scaleX: index == 0 ? 0 : 3, scaleY: 1, x: 0, y: 0)
    }
    
    func setPieChart(segmentedControlIndex index: Int) {
        var pricePerCategory = Array(repeating: 0.0, count: MainHandler.category.count)
        var totalPrice = 0.0
        for t in transactionData {
            if index == 1 {
                let monthStr = t.date.split(separator: "-")[1]
                if Int(monthStr) != month {
                    continue
                }
            }
            guard t.is_consumption == 1 else {
                continue
            }
            pricePerCategory[t.category] += Double(t.price)
            totalPrice += Double(t.price)
        }
        var dataEntries = [PieChartDataEntry]()
        var highestEntry = 0.0
        var highestCategory = ""
        for i in 0 ..< pricePerCategory.count {
            if pricePerCategory[i] == 0.0 {
                continue
            }
            dataEntries.append(PieChartDataEntry(value: pricePerCategory[i] / totalPrice, label: MainHandler.category[i]))
            if pricePerCategory[i] > highestEntry {
                highestCategory = MainHandler.category[i]
                highestEntry = pricePerCategory[i]
            }
        }
        let dataset = PieChartDataSet(entries: dataEntries, label: "")
        dataset.colors = ChartColorTemplates.joyful() + ChartColorTemplates.colorful()
        dataset.valueTextColor = .black
        let data = PieChartData(dataSet: dataset)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 100
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        self.pieChartView.data = data
        self.pieChartView.entryLabelColor = .black
        self.pieChartView.highlightValues(nil)
        self.pieChartView.highlightPerTapEnabled = false
        pieChartView.animate(xAxisDuration: 1.0)
        self.pieChartLabel.text = "\(index == 0 ? "이번 연도" : "이번 달")에는\n\(highestCategory)에 가장 많이 사용하였어요."
    }
    
    func getMaxDate(month: Int) -> Int {
        switch month {
        case 1,3,5,7,8,10,12: return 31
        case 4,6,9,11: return 31
        default:
            let year = year
            if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
                return 29
            } else {
                return 28
            }
        }
    }
}
