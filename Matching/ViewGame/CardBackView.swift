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
        backgroundColor = .systemGray5
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }

}
