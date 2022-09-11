//
//  CardView.swift
//  Matching
//
//  Created by john martin on 9/5/22.
//

import UIKit

class CardView: UIView {
    
    let card: Card!
    let onPress: (CardView) -> Void
    var isFrontShowing = false
    let cardViewId: String!
        
    private var cardFrontView: UIView!
    private var cardBackView: CardBackView!
    
    init(card: Card, onPress: @escaping (CardView)-> Void) {
        self.card = card
        self.onPress = onPress
        self.cardViewId = UUID().uuidString
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init coder not setup")
    }
        
    func setupView() {
        
        // setup card front view
        if (card.viewType == CARD_VIEW_TYPE.IMAGE) {
            
            cardFrontView = CardFrontView(card: card)
            cardFrontView.translatesAutoresizingMaskIntoConstraints = false
            cardFrontView.isHidden = true
            addSubview(cardFrontView)
            
        } else {
            cardFrontView = CardFrontCaptionView(card: card)
            cardFrontView.translatesAutoresizingMaskIntoConstraints = false
            cardFrontView.isHidden = true
            addSubview(cardFrontView)
        }
        
        // setup card back view
        cardBackView = CardBackView(frame: frame)
        cardBackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardBackView)
        
        NSLayoutConstraint.activate([

            cardFrontView.topAnchor.constraint(equalTo: topAnchor),
            cardFrontView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardFrontView.leftAnchor.constraint(equalTo: leftAnchor),
            cardFrontView.rightAnchor.constraint(equalTo: rightAnchor),
            
            cardBackView.topAnchor.constraint(equalTo: topAnchor),
            cardBackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardBackView.leftAnchor.constraint(equalTo: leftAnchor),
            cardBackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
            
        // setup tap handler
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        onPress(self)
    }
    
    @objc func flip () {
        let toView = (isFrontShowing ?  cardFrontView : cardBackView)!
        let fromView = (isFrontShowing ? cardBackView : cardFrontView)!
        let options: UIView.AnimationOptions  = isFrontShowing ? [.transitionFlipFromRight, .showHideTransitionViews] : [.transitionFlipFromLeft, .showHideTransitionViews]
        UIView.transition(from: fromView, to: toView, duration: 0.4, options: options, completion: nil)
    }
    
    public func hideCard (_ withDelay: CGFloat = 0.1) {
        isFrontShowing = false
        perform(#selector(flip), with: nil, afterDelay: withDelay)
    }
    
    public func showCard (_ withDelay: CGFloat = 0.1) {
        isFrontShowing = true
        perform(#selector(flip), with: nil, afterDelay: withDelay)
    }
}
