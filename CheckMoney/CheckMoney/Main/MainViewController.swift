//
//  MainViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/31.
//

import UIKit
import SwiftUI
import JJFloatingActionButton

class MainViewController: UIViewController, ChildViewControllerDelegate {
    let handler = MainHandler()
    
    private var _currentviewContent = ViewContent.Summary
    var currentViewContent: ViewContent {
        get {
            return _currentviewContent
        }
        set {
            _currentviewContent = newValue
            setContainerViewController(newValue)
        }
    }
    
    let buttonColor = UIColor(named: "AppColor") ?? UIColor.blue
    let actionButton = JJFloatingActionButton()
    
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        print("MainViewController load!")
        setContainerViewController(.Summary)
        setFloatingButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setContainerViewController(currentViewContent)
    }
    
    func initViewData() {
        print("init MainView")
        TransactionHandler.activeAccount = MainHandler.accounts.getDefaultAccount()
    }

    func updateTransactionData() {
        setContainerViewController(.TransactionList)
    }
    
    func updateView(type: ViewContent) {
        setContainerViewController(type)
    }
    
    func setFloatingButtons() {
        let item1 = actionButton.addItem(title: "지출", image: UIImage(systemName:"arrowshape.turn.up.forward")) { _ in
            self.addNewTransaction(isConsumption: true)
        }
        item1.buttonColor = UIColor.systemBackground
        item1.buttonImageColor = buttonColor
        
        let item2 = actionButton.addItem(title: "수입", image: UIImage(systemName:"arrowshape.turn.up.backward"), action: {_ in
            self.addNewTransaction(isConsumption: false)
        })
        item2.buttonColor = UIColor.systemBackground
        item2.buttonImageColor = buttonColor
        
        actionButton.buttonColor = buttonColor
        actionButton.display(inViewController: self)
    }
    
    private func addNewTransaction(isConsumption: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "addTransactionVC") as? AddTransactionViewController
        nextVC?.modalTransitionStyle = .coverVertical
        nextVC?.isConsumption = isConsumption
        nextVC?.accountName = TransactionHandler.activeAccount?.title ?? ""
        
        self.present(nextVC!, animated: true, completion: nil)
    }

    func setContainerViewController(_ view: ViewContent) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: view.rawValue)
        self.addChild(addViewController)
        containerView.addSubview(addViewController.view)
        addViewController.view.frame = containerView.bounds
        addViewController.didMove(toParent: self)
        (addViewController as! ChildViewController).parentDelegate = self
    }
}

enum ViewContent: String {
    case Summary = "SummaryView"
    case TransactionList = "TransactionListView"
}

protocol ChildViewControllerDelegate: UIViewController {
    func updateView(type: ViewContent)
}
