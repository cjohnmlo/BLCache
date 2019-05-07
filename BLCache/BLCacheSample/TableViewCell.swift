//
//  TableViewCell.swift
//  BLCacheSample
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var bgImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
