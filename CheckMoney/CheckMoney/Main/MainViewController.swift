//
//  MainViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/31.
//

import UIKit
import SwiftUI
import JJFloatingActionButton

class MainViewController: UIViewController {
    let handler = MainHandler()
    var activeWallet: Account? = nil
    
    @IBOutlet weak var walletName: UILabel!
    
    let buttonColor = UIColor(named: "AppColor") ?? UIColor.blue
    let actionButton = JJFloatingActionButton()
    
    override func viewDidLoad() {
        print("MainViewController load!")
        setFloatingButtons()
    }
    
    func setViewData() {
        activeWallet = handler.getDefaultAccount()
        walletName.text = activeWallet?.title
    }
    
    @IBAction func walletSettingButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "지갑 설정", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: nil))
        
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
    }
    
    private func addNewTransaction(isConsumption: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "addTransactionVC") as? AddTransactionViewController
        nextVC?.modalTransitionStyle = .coverVertical
        nextVC?.isConsumption = isConsumption
        
        self.present(nextVC!, animated: true, completion: nil)
    }
}
