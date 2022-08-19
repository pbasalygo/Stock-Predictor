//
//  TableViewCell.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 27/05/2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var CompanyNameLabel: UILabel!
    @IBOutlet weak var StockPriceLabel: UILabel!
    @IBOutlet weak var ShortNameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
