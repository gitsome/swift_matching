//
//  Card.swift
//  Matching
//
//  Created by john martin on 9/1/22.
//

import UIKit

enum CARD_VIEW_TYPE: String, Codable {
    case IMAGE
    case CAPTION
}

class Card: Codable {
 
    var caption: String
    var imageFileName: String?
    var uuid: String
    var viewType: CARD_VIEW_TYPE
    
    init (caption: String = "", imageFileName: String? = nil, viewType: CARD_VIEW_TYPE = CARD_VIEW_TYPE.IMAGE, uuid: String = UUID().uuidString) {
        self.caption = caption
        self.viewType = viewType
        self.imageFileName = imageFileName
        self.uuid = uuid
    }
    
    func copy() -> Card {
        return Card(caption: self.caption, imageFileName: self.imageFileName, uuid: self.uuid)
    }
}
