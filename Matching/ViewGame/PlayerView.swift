//
//  PlayerView.swift
//  Matching
//
//  Created by john martin on 9/5/22.
//

import UIKit

class PlayerView: UIView {
            
    private var playerNameLabel: UILabel!
    public var playerScoreLabel: UILabel!
    private var isActive = false
    
    let playerNum: Int
    var playerScore: Int = 0 {
        didSet {
            playerScoreLabel.text = "\(playerScore)"
        }
    }
    
    init(playerNum: Int) {
        self.playerNum = playerNum
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Init coder not setup")
    }
        
    func setupView() {
                
        // add in our subviews
        playerNameLabel = UILabel()
        playerNameLabel.text = "Player \(playerNum + 1)"
        playerNameLabel.layer.cornerRadius = 5
        playerNameLabel.clipsToBounds = true
        playerNameLabel.textAlignment = .center
        playerNameLabel.font = UIFont.systemFont(ofSize: 20)
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerNameLabel)

        playerScoreLabel = UILabel()
        playerScoreLabel.textAlignment = .center
        playerScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        playerScoreLabel.font = UIFont.systemFont(ofSize: 40)
        addSubview(playerScoreLabel)
        
        setScore(0)
        
        setIsActive(isActive)
    }
    
    func setScore (_ newScore: Int) {
        playerScore = newScore
    }
    
    func setIsActive (_ isPlayerActive: Bool) {
        isActive = isPlayerActive
        if isActive {
            playerNameLabel.backgroundColor = PLAYER_COLORS[playerNum]
            playerNameLabel.textColor = .white
            playerScoreLabel.textColor = PLAYER_COLORS[playerNum]
        } else {
            playerNameLabel.backgroundColor = .systemGray4
            playerNameLabel.textColor = .systemGray
            playerScoreLabel.textColor = .systemGray
        }
    }
    
    func setupConstraints() {
        
        playerNameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playerNameLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        playerNameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        playerScoreLabel.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 5).isActive = true
        playerScoreLabel.centerXAnchor.constraint(equalTo: playerNameLabel.centerXAnchor).isActive = true
    }
}
