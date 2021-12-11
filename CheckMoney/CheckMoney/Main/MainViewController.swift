//
//  MainViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/31.
//

import UIKit
import SwiftUI
import JJFloatingActionButton

class MainViewController: UIViewController, UITabBarDelegate {
    let handler = MainHandler()
    private var _activeAccount: Account? = nil
    var activeAccount: Account? {
        get { return _activeAccount }
        set(value) {
            _activeAccount = value
            self.tabBar.selectedItem = tabBar.items?.first
            DispatchQueue.main.async {
                self.walletName.text = value?.title
                if value != nil {
                    self.handler.getTransactionData(account_id: value!.id)
                }
            }
        }
    }
    
    private var _currentAccountTransaction = [Transaction]()
    var currentAccountTransaction: [Transaction] {
        get { return _currentAccountTransaction }
        set(value) {
            _currentAccountTransaction = value
            self.setContainerViewController(self.tabBar.selectedItem?.tag == 0 ? TabViewList.Analytics : TabViewList.TransactionList, data: value)
        }
    }
    
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletSettingButton: UIButton!
    
    let buttonColor = UIColor(named: "AppColor") ?? UIColor.blue
    let actionButton = JJFloatingActionButton()
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        print("MainViewController load!")
        setFloatingButtons()
        
//        setContainerViewController(TabViewList.Analytics)
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?.first
    }
    
    func initViewData() {
        print("init MainView")
        activeAccount = MainHandler.accounts.getDefaultAccount()
    }
    
    func updateTransactionData() {
        self.handler.getTransactionData(account_id: activeAccount!.id)
    }
    
    @IBAction func walletSettingButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "계좌 설정", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: {_ in
            let innerAlert = UIAlertController(title: "계좌 소개 변경", message: "현재 이름: \(self.activeAccount?.title ?? "")", preferredStyle: .alert)
            innerAlert.addTextField { titleField in
                titleField.placeholder = "변경할 이름을 입력하세요."
            }
            innerAlert.addTextField { descriptionField in
                descriptionField.text = self.activeAccount?.description
                descriptionField.placeholder = "설명을 입력하세요."
            }
            innerAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            innerAlert.addAction(UIAlertAction(title: "변경", style: .default, handler: { action in
                let title = innerAlert.textFields?[0].text ?? self.activeAccount?.title ?? ""
                let desc = innerAlert.textFields?[1].text ?? ""
                let putRequest = AccountRequest(title: title, description: desc)
                NetworkHandler.request(method: .PUT, endpoint: "accounts/\(self.activeAccount!.id)", request: putRequest, callback: { (success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    self.activeAccount = MainHandler.accounts.changeAccountData(id: self.activeAccount!.id, title: title, description: desc)
                })
            }))
            self.present(innerAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            let innerAlert = UIAlertController(title: "\(self.activeAccount!.title) 삭제", message: "해당 계좌를 삭제하시겠습니까?", preferredStyle: .alert)
            innerAlert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: {_ in
                NetworkHandler.request(method: .DELETE, endpoint: "accounts/\(self.activeAccount!.id)", request: EmptyRequest(), callback: {(success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    MainHandler.accounts.deleteAccount(id: self.activeAccount!.id)
                    self.activeAccount = MainHandler.accounts.getDefaultAccount()
                })
            }))
            innerAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(innerAlert, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        self.view.addConstraint(NSLayoutConstraint(item: tabBar!, attribute: .top, relatedBy: .equal, toItem: actionButton, attribute: .bottom, multiplier: 1, constant: 12))
    }
    
    private func addNewTransaction(isConsumption: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "addTransactionVC") as? AddTransactionViewController
        nextVC?.modalTransitionStyle = .coverVertical
        nextVC?.isConsumption = isConsumption
        nextVC?.accountName = self.activeAccount!.title
        
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            setContainerViewController(TabViewList.Analytics, data: currentAccountTransaction)
        } else {
            setContainerViewController(TabViewList.TransactionList, data: currentAccountTransaction)
        }
    }
    
    func setContainerViewController(_ view: TabViewList, data: [Transaction] = [Transaction]()) {
//        switch view {
//        case .Analytics:
//            self.walletName.isHidden = true
//            self.walletSettingButton.isHidden = true
//        case .TransactionList:
//            self.walletName.isHidden = false
//            self.walletSettingButton.isHidden = false
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: view.rawValue) as! ParentTabViewController
        addViewController.transactionData = data
        self.addChild(addViewController)
        containerView.addSubview(addViewController.view)
        addViewController.view.frame = containerView.bounds
        addViewController.didMove(toParent: self)
    }
}

enum TabViewList: String {
    case Analytics = "AnalyticsView"
    case TransactionList = "TransactionListView"
}
