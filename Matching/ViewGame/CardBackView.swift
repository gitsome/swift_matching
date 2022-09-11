//
//  CardBackView.swift
//  Matching
//
//  Created by john martin on 9/5/22.
//

import UIKit

class CardBackView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init coder not setup")
    }
        
    func setupView() {
        backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }

}
