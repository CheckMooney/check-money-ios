//
//  SubscriptionTableViewController.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2022/01/01.
//

import UIKit

class SubscriptionTableViewController: UITableViewController {
    var account: Account? = nil
    private var subsTransactions = [Transaction]()
    
    override func viewDidLoad() {
        getSubsData()
    }
    
    func getSubsData() {
        NetworkHandler.request(method: .GET, endpoint: "/accounts/\(account!.id)/subscriptions", request: EmptyRequest(), parameters: ["page":"1", "limit":"100"]) { (success, response: QueryTransactionResponse?) in
            guard success, let res = response else {
                print("fail to load subs data")
                return
            }
            DispatchQueue.main.async {
                self.subsTransactions = res.rows
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subsTransactions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "subscriptionTableCell") as? SubscriptionTableViewCell else {
            fatalError("not exist cell")
        }
        
        let transaction = subsTransactions[indexPath.row]
        cell.detail.text = transaction.detail
        cell.category.text = transaction.is_consumption == 1 ? MainHandler.category[transaction.category] : ""
        cell.price.text = "\(transaction.price)"
        cell.date.text = "\(transaction.date) λΆν° μμ"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(account?.title ?? "") μλ μ§μΆ λ΄μ­"
    }
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedData = subsTransactions[indexPath.row]
        let endpoint = "/accounts/\(self.account!.id)/subscriptions/\(selectedData.id)"
        
        var elements = Array<UIMenuElement>()
        elements.append(UIAction(title: "μμ ", handler: { _ in
            let alert = UIAlertController(title: "κ±°λ λ΄μ­ μμ ", message: nil, preferredStyle: .alert)
            alert.addTextField { priceField in
                priceField.text = String(selectedData.price)
                priceField.placeholder = "κ°κ²©μ μμ νμΈμ."
            }
            alert.addTextField { descriptionField in
                descriptionField.text = selectedData.detail
                descriptionField.placeholder = "λ³κ²½ν  μ€λͺμ μλ ₯νμΈμ."
            }
            alert.addAction(UIAlertAction(title: "μ·¨μ", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "μμ ", style: .default, handler: { _ in
                guard let newPrice = Int(alert.textFields?[0].text ?? ""), let newDetail = alert.textFields?[1].text else {
                    let innerAlert = UIAlertController(title: nil, message: "μ λ³΄κ° μ¬λ°λ₯΄μ§ μμ΅λλ€.", preferredStyle: .alert)
                    innerAlert.addAction(UIAlertAction(title: "νμΈ", style: .default, handler: nil))
                    self.present(innerAlert, animated: true, completion: nil)
                    return
                }
                let req = AddTransactionRequest(is_consumption: selectedData.is_consumption, price: newPrice, detail: newDetail, category: selectedData.category, date: selectedData.date, account_id: selectedData.account_id)
                NetworkHandler.request(method: .PUT, endpoint: endpoint, request: req) { (success, response: DefaultResponse?) in
                    guard success else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.subsTransactions[indexPath.row].price = newPrice
                        self.subsTransactions[indexPath.row].detail = newDetail
                        self.tableView.reloadData()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        elements.append(UIAction(title: "μ­μ ", attributes: .destructive ,handler: { _ in
            let alert = UIAlertController(title: "'\(selectedData.detail)' μ­μ ", message: "κ±°λ λ΄μ­μ μ­μ νμκ² μ΅λκΉ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "μ­μ ", style: .destructive, handler: { _ in
                NetworkHandler.request(method: .DELETE, endpoint: endpoint, request: EmptyRequest()) { (success, response: DefaultResponse?) in
                    guard success else {
                        print("κ±°λ λ΄μ­ μ κ±° μ€ν¨")
                        return
                    }
                    DispatchQueue.main.async {
                        self.subsTransactions.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "μ·¨μ", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(options: .displayInline, children: elements)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
