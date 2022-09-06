//
//  CardsModelController.swift
//  Matching
//
//  Created by john martin on 9/4/22.
//

import Foundation

class CardsModelController {
    var cards: [Card] = []
    
    func load () {
        // get the cards from user defaults and default to empty array
        let defaults = UserDefaults.standard
        if let savedCards = defaults.object(forKey: "cards") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                cards = try jsonDecoder.decode([Card].self, from: savedCards)
            } catch {
                cards = []
            }
        }
    }
    
    func upsertCard (_ card: Card) {
                
        let matchingIndex = cards.firstIndex(where: {
            existingCard in
            return existingCard.uuid == card.uuid
        })
                
        if let matchingIndex = matchingIndex {
            cards[matchingIndex] = card
        } else {
            cards.append(card)
        }
        
        save()
    }
    
    func deleteCard (_ card: Card) {
                
        let matchingIndex = cards.firstIndex(where: {
            existingCard in
            return existingCard.uuid == card.uuid
        })
                
        if let matchingIndex = matchingIndex {
            cards.remove(at: matchingIndex)
            save()
        } else {
            fatalError("We could not find the card to delete. Something is wrong.")
        }
    }
        
    func save () {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(cards) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "cards")
        } else {
            print("Failed to save")
        }
    }
    
    static func getImagePathNameForCard(_ card: Card) -> URL? {
        guard let imageFileName = card.imageFileName else { return nil }
        return CardsModelController.getDocumentsDirectory().appendingPathComponent(imageFileName)
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
