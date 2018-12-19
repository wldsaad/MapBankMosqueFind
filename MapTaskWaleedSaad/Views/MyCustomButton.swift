//
//  MyCustomButton.swift
//  MapTaskWaleedSaad
//
//  Created by Waleed Saad on 11/24/18.
//  Copyright © 2018 Waleed Saad. All rights reserved.
//

import UIKit

class MyCustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = #colorLiteral(red: 0.4634746909, green: 0.6373595595, blue: 0.8999161124, alpha: 1).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 40
    
        
    }

}
