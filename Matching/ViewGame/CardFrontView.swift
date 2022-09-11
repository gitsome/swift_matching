//
//  CardFrontView.swift
//  Matching
//
//  Created by john martin on 9/5/22.
//

import UIKit

class CardFrontView: UIView {
    
    let card: Card!
    
    private var imageView: UIImageView?
    
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
        imageView = UIImageView()
        addSubview(imageView!)
        imageView?.frame = CGRect(x: 5, y: 5, width: 70, height: 70)
        imageView?.clipsToBounds = true
        imageView?.layer.cornerRadius = 6
        imageView?.contentMode = .scaleAspectFit
        let imagesPath = CardsModelController.getImagePathNameForCard(card)
        if let imagesPath = imagesPath {
            imageView?.image = UIImage(contentsOfFile: imagesPath.path)
        }
        
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        imageView?.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9).isActive = true
        imageView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
//    an example of doing custom layout without constaints
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        imageView?.frame = CGRect(x: frame.size.width * 0.05, y: frame.size.width * 0.05, width: frame.size.width * 0.9, height: frame.size.width * 0.9)
//    }
}
