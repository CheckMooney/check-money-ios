//
//  SubscriptionTableViewCell.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2022/01/01.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var date: UILabel!
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
