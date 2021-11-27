//
//  TransactionTableViewCell.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/21.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var explain: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
