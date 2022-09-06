//
//  CardCollectionViewCell.swift
//  Matching
//
//  Created by john martin on 9/4/22.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    
    var captionLabelView: UILabel = {
        var uiLabel = UILabel()
        uiLabel.textAlignment = .center
        uiLabel.font = UIFont.systemFont(ofSize: 14)
        return uiLabel
    }()
    
    var imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(captionLabelView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure (_ card: Card) {
        captionLabelView.text = card.caption

        let imagesPath = CardsModelController.getImagePathNameForCard(card)
        
        if let imagesPath = imagesPath {
            imageView.image = UIImage(contentsOfFile: imagesPath.path)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.width)
        captionLabelView.frame = CGRect(x: 0, y: contentView.frame.size.width + 5, width: contentView.frame.size.width - 10, height: 20)
    }
    
}
