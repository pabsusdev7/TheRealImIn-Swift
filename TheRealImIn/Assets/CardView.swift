//
//  CardView.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 8/24/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation
import UIKit

class CardView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 20.0
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 12.0
        layer.shadowOpacity = 0.7
    }
    
}
