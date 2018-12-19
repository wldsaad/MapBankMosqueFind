//
//  MyCustomView.swift
//  MapTaskWaleedSaad
//
//  Created by Waleed Saad on 11/24/18.
//  Copyright © 2018 Waleed Saad. All rights reserved.
//

import UIKit

class MyCustomView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowOpacity = 0.2
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: -10, height: -10)
        
    }
}
