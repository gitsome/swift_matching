//
//  CardManagerViewController.swift
//  Matching
//
//  Created by john martin on 9/1/22.
//

import UIKit

class CardManagerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var cardModelController: CardsModelController!
    
    var collectionView: UICollectionView?
        
    // additional load-time tasks after the root view is created
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Manage Cards"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Card", style: .plain, target: self, action: #selector(editCardNavPressed))
        
        view.backgroundColor = .systemBackground
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 75, height: 110)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else { return }
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.clipsToBounds = true
        
        view.addSubview(collectionView)
        
        // contraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setEmptyMessage(_ message: String) {
        
        if let collectionView = collectionView {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            messageLabel.text = message
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.sizeToFit()
            collectionView.backgroundView = messageLabel;
            collectionView.backgroundColor = .systemBackground
        }
    }

    func clearEmptyMessage() {
        collectionView?.backgroundView = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (cardModelController.cards.count == 0) {
            setEmptyMessage("Press the \"Add Card\" button to start your card collection!")
        } else {
            clearEmptyMessage()
        }
        
        return cardModelController.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell
        let card = cardModelController.cards[indexPath.item]
        cell.configure(card)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = cardModelController.cards[indexPath.item]
        // send in a copy so they can mutate it and thow it aways
        editCard(card, indexPath: indexPath)
    }
    
    @objc func editCardNavPressed () {
        editCard(Card())
    }
    
    func editCard (_ cardToEdit: Card, indexPath: IndexPath? = nil) {
                
        let originalFileName = cardToEdit.imageFileName
        
        let editCardViewController = EditCardViewController() {
            
            // onEditComplete handler
            [weak self] cardToSaveCadidate, newJpegData in
            
            // lets continue to edit or add if the card was returned
            if let cardToSave = cardToSaveCadidate {
                                
                // if they updated the image
                if let newJpegData = newJpegData {
                                        
                    // if the original image was not nill then we need to delete the olde one
                    if originalFileName != nil {
                        if let imagePath = CardsModelController.getImagePathNameForCard(cardToEdit) {
                            do {
                                try FileManager.default.removeItem(at: imagePath)
                            } catch let error as NSError {
                                print("Error could not save file (maybe not found): \(error.domain)")
                            }
                        }
                    }
                    
                    // add the new image
                    if let imagePath = CardsModelController.getImagePathNameForCard(cardToSave) {
                        try? newJpegData.write(to: imagePath)
                    }
                }
                
                // is this an add or an edit
                if let unwrappedIndexPath = indexPath {
                    self?.onCardEditComplete(cardToSave, indexPath: unwrappedIndexPath)
                } else {
                    self?.onCardAddComplete(cardToSave)
                }
                
            // if cardToSave came back nil, then it should be deleted
            } else {
                
                // first delete the image
                if let imagePath = CardsModelController.getImagePathNameForCard(cardToEdit) {
                    do {
                        try FileManager.default.removeItem(at: imagePath)
                    } catch let error as NSError {
                        print("Error could not save file (maybe not found): \(error.domain)")
                    }
                }
                
                self?.onCardDeleteComplete(cardToEdit)
            }
        }
               
        // launch the edit card view controller and set the card to a copy so it can be safely mutated and throw away
        editCardViewController.card = cardToEdit.copy()
        navigationController?.pushViewController(editCardViewController, animated: true)
    }
       
    func onCardAddComplete(_ card: Card) {
        navigationController?.popViewController(animated: true)
        cardModelController.upsertCard(card)
        collectionView?.reloadData()
    }
    
    func onCardEditComplete(_ card: Card, indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        cardModelController.upsertCard(card)
        collectionView?.reloadItems(at: [indexPath])
    }
    
    func onCardDeleteComplete(_ card: Card) {
        navigationController?.popViewController(animated: true)
        cardModelController.deleteCard(card)
        collectionView?.reloadData()
    }
}
