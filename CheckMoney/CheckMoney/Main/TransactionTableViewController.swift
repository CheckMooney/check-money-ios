//
//  TransactionTableViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/20.
//

import UIKit

class TransactionTableViewController: ChildViewController, UITableViewDelegate, UITableViewDataSource {
    var categorizingType: CategorizingType = .all
    var transactionData = [Transaction]()
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletSettingButton: UIButton!
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var categorizingButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    private var year = Calendar.current.component(.year, from: Date())
    private var month = Calendar.current.component(.month, from: Date())
    
    var pickerviewSetting = TransactionDatePickerSetting()
    private let toolbar = UIToolbar()
    
    private var _filteredData = [(Int, [Transaction])]()
    var filteredData: [(Int, [Transaction])] {
        get {
            return self._filteredData
        }
        set(value) {
            _filteredData = value
            self.tableView.reloadData()
            updateTotalLabel(transaction: _filteredData)
        }
    }
    
    override func viewDidLoad() {
        categorizingType = .all
        naviItem.title = "\(year)년 \(month)월"
        tableView.dataSource = self
        tableView.delegate = self
        walletName.text = TransactionHandler.activeAccount?.title
        TransactionHandler.getTransactionData(account_id: TransactionHandler.activeAccount!.id) { resData in
            self.transactionData = resData
            self.addMenuForCategorizingType()
            self.filteredData = TransactionHandler.filter(data: self.transactionData, year: self.year, month: self.month)
        }
    }
    
    @IBAction func walletSettingClicked(_ sender: Any) {
        let account = TransactionHandler.activeAccount
        let alert = UIAlertController(title: "계좌 설정", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: {_ in
            let innerAlert = UIAlertController(title: "계좌 소개 변경", message: "현재 이름: \(account?.title ?? "")", preferredStyle: .alert)
            innerAlert.addTextField { titleField in
                titleField.placeholder = "변경할 이름을 입력하세요."
            }
            innerAlert.addTextField { descriptionField in
                descriptionField.text = account?.description
                descriptionField.placeholder = "설명을 입력하세요."
            }
            innerAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            innerAlert.addAction(UIAlertAction(title: "변경", style: .default, handler: { action in
                let title = innerAlert.textFields?[0].text ?? account?.title ?? ""
                let desc = innerAlert.textFields?[1].text ?? ""
                let putRequest = AccountRequest(title: title, description: desc)
                NetworkHandler.request(method: .PUT, endpoint: "/accounts/\(account!.id)", request: putRequest, callback: { (success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    DispatchQueue.main.async {
                        TransactionHandler.activeAccount = MainHandler.accounts.changeAccountData(id: account!.id, title: title, description: desc)
                        self.walletName.text = title
                    }
                    
                })
            }))
            self.present(innerAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            let innerAlert = UIAlertController(title: "\(account!.title) 삭제", message: "해당 계좌를 삭제하시겠습니까?", preferredStyle: .alert)
            innerAlert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: {_ in
                NetworkHandler.request(method: .DELETE, endpoint: "/accounts/\(account!.id)", request: EmptyRequest(), callback: {(success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    MainHandler.accounts.deleteAccount(id: account!.id)
                    TransactionHandler.activeAccount = nil
                    DispatchQueue.main.async {
                        self.parentDelegate?.updateView(type: .Summary)
                    }
                })
            }))
            innerAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(innerAlert, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transaction_cell") as? TransactionTableViewCell else {
            fatalError("not exist cell")
        }
        let transaction = filteredData[indexPath.section].1[indexPath.row]
        cell.explain.text = transaction.detail
        cell.category.text = transaction.is_consumption == 1 ? MainHandler.category[transaction.category] : ""
        cell.price.text = "\(transaction.is_consumption == 1 ? "-" : "+")\(transaction.price)"
        cell.price.textColor = transaction.is_consumption == 1 ? UIColor.red : UIColor.blue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredData[section].1.first?.date
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedData = filteredData[indexPath.section].1[indexPath.row]
        print(selectedData)
        var elements = Array<UIMenuElement>()
        elements.append(UIAction(title: "수정", handler: { _ in
            let alert = UIAlertController(title: "거래 내역 수정", message: nil, preferredStyle: .alert)
            alert.addTextField { priceField in
                priceField.text = String(selectedData.price)
                priceField.placeholder = "가격을 수정하세요."
            }
            alert.addTextField { descriptionField in
                descriptionField.text = selectedData.detail
                descriptionField.placeholder = "변경할 설명을 입력하세요."
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
                guard let newPrice = Int(alert.textFields?[0].text ?? ""), let newDetail = alert.textFields?[1].text else {
                    let innerAlert = UIAlertController(title: nil, message: "정보가 올바르지 않습니다.", preferredStyle: .alert)
                    innerAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(innerAlert, animated: true, completion: nil)
                    return
                }
                let req = AddTransactionRequest(is_consumption: selectedData.is_consumption, price: newPrice, detail: newDetail, category: selectedData.category, date: selectedData.date, account_id: selectedData.account_id)
                NetworkHandler.request(method: .PUT, endpoint: "/transactions/\(selectedData.id)", request: req) { (success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.filteredData[indexPath.section].1[indexPath.row].price = newPrice
                        self.filteredData[indexPath.section].1[indexPath.row].detail = newDetail
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        elements.append(UIAction(title: "삭제", attributes: .destructive ,handler: { _ in
            let alert = UIAlertController(title: "'\(selectedData.detail)' 삭제", message: "거래 내역을 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                NetworkHandler.request(method: .DELETE, endpoint: "/transactions/\(selectedData.id)", request: EmptyRequest()) { (success, response: DefaultResponse?) in
                    guard success else {
                        print("거래 내역 제거 실패")
                        return
                    }
                    DispatchQueue.main.async {
                        self.filteredData[indexPath.section].1.remove(at: indexPath.row)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(options: .displayInline, children: elements)
        }
    }
    
    func addMenuForCategorizingType() {
        switch categorizingType {
        case .all: categorizingButton.title = "전체"
        case .income: categorizingButton.title = "수입"
        case .consumption: categorizingButton.title = "지출"
        }
        var menuElement = [UIMenuElement]()
        menuElement.append(UIAction(title: "전체", image: nil, state: categorizingType == .all ? .on : .off, handler: {_ in
            self.categorizingType = .all
            self.addMenuForCategorizingType()
            self.filteredData = TransactionHandler.filter(data: self.transactionData, categorizing: .all, year: self.year, month: self.month)
        }))
        menuElement.append(UIAction(title: "수입", image: nil, state: categorizingType == .income ? .on : .off, handler: {_ in
            self.categorizingType = .income
            self.addMenuForCategorizingType()
            print("수입 선택")
            self.filteredData = TransactionHandler.filter(data: self.transactionData, categorizing: .income, year: self.year, month: self.month)
            
        }))
        menuElement.append(UIAction(title: "지출", image: nil, state: categorizingType == .consumption ? .on : .off, handler: {_ in
            self.categorizingType = .consumption
            self.addMenuForCategorizingType()
            self.filteredData = TransactionHandler.filter(data: self.transactionData, categorizing: .consumption, year: self.year, month: self.month)
        }))
        self.categorizingButton.primaryAction = nil
        self.categorizingButton.menu = UIMenu(title: "보기 설정", image: nil, options: .displayInline, children: menuElement)
    }
    
    @IBAction func changingDateRequested(_ sender: Any) {
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
    
    func updateTotalLabel(transaction: [(Int, [Transaction])]) {
        DispatchQueue.main.async {
            var sum: Int = 0
            for trans in transaction {
                for data in trans.1 {
                    if data.is_consumption == 1 {
                        sum -= data.price
                    } else {
                        sum += data.price
                    }
                }
            }
            self.totalLabel.text = String(sum) + "원"
        }
    }
    
    @IBAction func preDateButtonClicked(_ sender: Any) {
        let cntMonth = month
        if (cntMonth - 1 == 0) {
            year -= 1
            month = 12
        } else {
            month -= 1
        }
        viewDidLoad()
    }
    @IBAction func postDateButtonClicked(_ sender: Any) {
        let cntMonth = month
        if (cntMonth + 1 == 13) {
            year += 1
            month = 1
        } else {
            month += 1
        }
        viewDidLoad()
    }
}

enum CategorizingType {
    case all
    case income
    case consumption
}

