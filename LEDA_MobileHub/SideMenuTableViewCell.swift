//
//  SideMenuTableViewCell.swift
//  LEDA
//
//  Created by Mengying Feng on 21/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(txt: String) {
        menuLabel.text = txt
    }

}
