//
//  AnalyticsTabViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/20.
//

import UIKit
import Charts

class AnalyticsTabViewController: ParentTabViewController, ChartViewDelegate {
    @IBOutlet weak var chartView: PieChartView!
    
    
    override func viewDidLoad() {
        setChart()
    }
    
    func setChart() {
        var pricePerCategory = Array(repeating: 0.0, count: MainHandler.category.count)
        var totalPrice = 0.0
        for t in transactionData {
            guard t.is_consumption == 1 else {
                continue
            }
            pricePerCategory[t.category] += Double(t.price)
            totalPrice += Double(t.price)
        }
        var dataEntries = [PieChartDataEntry]()
        for i in 0..<pricePerCategory.count {
            if pricePerCategory[i] == 0.0 {
                continue
            }
            dataEntries.append(PieChartDataEntry(value: pricePerCategory[i] / totalPrice, label: MainHandler.category[i]))
        }
        let dataset = PieChartDataSet(entries: dataEntries, label: "분류별 요약")
        dataset.colors = ChartColorTemplates.colorful() + ChartColorTemplates.pastel()
        let data = PieChartData(dataSet: dataset)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        self.chartView.data = data
        chartView.animate(xAxisDuration: 1.0)
    }
}
