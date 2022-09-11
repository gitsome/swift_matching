//
//  ViewController.swift
//  Matching
//
//  Created by john martin on 9/1/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    var cardModelController = CardsModelController()
    
    @IBOutlet var matchByCaptionSwitch: UISwitch!
    
    @IBOutlet var play12Button: UIButton!
    @IBAction func play12ButtonPressed(_ sender: UIButton) {
        startNewGame(12, sender)
    }
    
    @IBOutlet var play16Button: UIButton!
    @IBAction func play16ButtonAPressed(_ sender: UIButton) {
        startNewGame(16, sender)
    }
    
    @IBOutlet var play24Button: UIButton!
    @IBAction func play24ButtonPressed(_ sender: UIButton) {
        startNewGame(24, sender)
    }
    
    @IBOutlet var addCardsButton: UIButton!
    @IBAction func addCardsButtonPressed(_ sender: Any) {
        navigateToCardManager()
    }
    
    @IBOutlet var instructionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Matching"
        
        loadImageCards()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit cards", style: .plain, target: self, action: #selector(showCardManagementView))
        
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // each time we come back to this view the underlying cards model could have changed
        updateGameButtons()
    }
    
    func loadImageCards() {
        cardModelController.load()
    }
    
    func updateGameButtons() {
        
        if cardModelController.cards.count < 12 {
            play24Button.isEnabled = false
            let cardsLeft = 12 - cardModelController.cards.count
            instructionsLabel.text = "Add \(cardsLeft) \(cardsLeft > 1 ? "cards" : "card") to unlock the 24 card game."
        } else {
            play24Button.isEnabled = true
        }
        
        if cardModelController.cards.count < 8 {
            play16Button.isEnabled = false
            let cardsLeft = 8 - cardModelController.cards.count
            instructionsLabel.text = "Add \(cardsLeft) \(cardsLeft > 1 ? "cards" : "card") to unlock the 16 card game."
        } else {
            play16Button.isEnabled = true
        }
        
        if cardModelController.cards.count < 6 {
            play12Button.isEnabled = false
            let cardsLeft = 6 - cardModelController.cards.count
            instructionsLabel.text = "You have \(cardModelController.cards.count) cards. You need at least \(cardsLeft) more \(cardsLeft > 1 ? "cards" : "card") to start playing"
        } else {
            play12Button.isEnabled = true
        }
        
        if cardModelController.cards.count >= 12 {
            addCardsButton.isHidden = true
            instructionsLabel.isHidden = true
        } else {
            addCardsButton.isHidden = false
            instructionsLabel.isHidden = false
        }
    }
        
    func navigateToCardManager() {
        let cardManagerViewController = CardManagerViewController()
        cardManagerViewController.cardModelController = cardModelController
        
        navigationController?.pushViewController(cardManagerViewController, animated: true)
    }
    
    @objc func showCardManagementView () {
        navigateToCardManager()
    }
    
    func loadNewGame(totalCards: Int, totalPlayers: Int) {
        
        let gameViewController = GameViewController()
        
        gameViewController.totalCards = totalCards
        gameViewController.totalPlayers = totalPlayers
        gameViewController.cardModelController = cardModelController
        gameViewController.matchWithCaption = matchByCaptionSwitch.isOn
        
        navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    func startNewGame(_ totalCards: Int, _ sender: UIButton) {
    
        let ac = UIAlertController(title: "How many players?", message: "How many people are playing this round?", preferredStyle: .actionSheet)
        
        // one player
        ac.addAction(UIAlertAction(title: "1", style: .default) {
            [weak self] action in
            self?.loadNewGame(totalCards: totalCards, totalPlayers: 1)
        })
        
        // two players
        ac.addAction(UIAlertAction(title: "2", style: .default) {
            [weak self] action in
            self?.loadNewGame(totalCards: totalCards, totalPlayers: 2)
        })
        
        // three players
        ac.addAction(UIAlertAction(title: "3", style: .default) {
            [weak self] action in
            self?.loadNewGame(totalCards: totalCards, totalPlayers: 3)
        })
                
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
}

