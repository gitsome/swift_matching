//
//  CardFrontView.swift
//  Matching
//
//  Created by john martin on 9/5/22.
//

import UIKit

class CardFrontCaptionView: UIView {
    
    let card: Card!
    
    var captionLabel: UILabel?
    
    init(card: Card) {
        self.card = card
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init coder not setup")
    }
        
    func setupView() {
                
        // root view styles
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.backgroundColor = UIColor.white.cgColor
        
        // load the image view
        captionLabel = UILabel()
        if let captionLabel = captionLabel {
            captionLabel.textAlignment = .center
            captionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            captionLabel.text = card.caption
            captionLabel.lineBreakMode = .byWordWrapping
            captionLabel.numberOfLines = 0
            captionLabel.textAlignment = .center
            captionLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(captionLabel)
            
            captionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
            captionLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9).isActive = true
            captionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            captionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }

}

