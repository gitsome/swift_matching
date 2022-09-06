//
//  GameOverView.swift
//  Matching
//
//  Created by john martin on 9/6/22.
//

import UIKit

enum GAME_OVER_COMPLETION_ACTION {
    case NEW_GAME
    case QUIT
}

class GameOverView: UIView {
    
    var playerScores: [Int]!
    var onComplete: (GAME_OVER_COMPLETION_ACTION) -> Void
    
    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        v.layer.shadowRadius = 10
        return v
    }()
    
    private let gameOverLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        label.text = "Congrats!"
        label.textAlignment = .center
        return label
    }()
    
    private let playersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.text = ""
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    private let newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Play Again", for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return button
    }()
    
    private let quitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back to Menu", for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return button
    }()
    
    init(playerScores: [Int], onComplete: @escaping (GAME_OVER_COMPLETION_ACTION) -> Void) {
        
        self.playerScores = playerScores
        self.onComplete = onComplete
        
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        setupSubViews()
        setPlayersLabelText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        animateIn()
        playConfetti()
    }
    
    func setupSubViews () {
        
        self.alpha = 0
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        addSubview(container)
        
        container.addSubview(gameOverLabel)
        gameOverLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15).isActive = true
        gameOverLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true
        gameOverLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
        
        container.addSubview(playersLabel)
        playersLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15).isActive = true
        playersLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true
        playersLabel.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: 10).isActive = true
                
        container.addSubview(quitButton)
        quitButton.addTarget(self, action: #selector(closeQuit), for: .touchUpInside)
        quitButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15).isActive = true
        quitButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15).isActive = true
        quitButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true
        
        container.addSubview(newGameButton)
        newGameButton.addTarget(self, action: #selector(closeNewGame), for: .touchUpInside)
        newGameButton.bottomAnchor.constraint(equalTo: quitButton.topAnchor, constant: -10).isActive = true
        newGameButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15).isActive = true
        newGameButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true
        
        container.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        container.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        container.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeNewGame)))
    }
    
    func setPlayersLabelText () {
        
        let maxScore = playerScores.max()
        let winningPlayers = playerScores.indices.filter { playerScores[$0] == maxScore }
                
        let styledPlayers: [NSAttributedString] = winningPlayers.compactMap({
            let playerString = "Player\u{a0}\($0 + 1)"
            let attributes = [NSAttributedString.Key.foregroundColor: PLAYER_COLORS[$0]!]
            return NSAttributedString(string: playerString, attributes: attributes)
        })
        
        var winAttrString: NSMutableAttributedString
        
        if playerScores.count == 1 {
        
            let winString = "You Won!"
            let attributes = [NSAttributedString.Key.foregroundColor: PLAYER_COLORS[winningPlayers[0]]!]
            winAttrString =  NSMutableAttributedString(string: winString, attributes: attributes)
        
        } else if winningPlayers.count == 1 {
            
            winAttrString = NSMutableAttributedString()
            winAttrString.append(styledPlayers[0])
            winAttrString.append(NSAttributedString(string: " is the winner! ", attributes: [:]))
            
        } else if winningPlayers.count == 2 {
            
            winAttrString = NSMutableAttributedString()
            winAttrString.append(styledPlayers[0])
            winAttrString.append(NSAttributedString(string: " and ", attributes: [:]))
            winAttrString.append(styledPlayers[1])
            winAttrString.append(NSAttributedString(string: " tied!", attributes: [:]))
            
        } else {
            
            winAttrString = NSMutableAttributedString()
            winAttrString.append(styledPlayers[0])
            winAttrString.append(NSAttributedString(string: " , ", attributes: [:]))
            winAttrString.append(styledPlayers[1])
            winAttrString.append(NSAttributedString(string: " and ", attributes: [:]))
            winAttrString.append(styledPlayers[2])
            winAttrString.append(NSAttributedString(string: " tied!", attributes: [:]))
        }
        
        playersLabel.attributedText = winAttrString
    }
    
    func animateOut () {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height / 2)
            self.alpha = 0
        }) {
            isComplete in
            self.removeFromSuperview()
        }
    }
    
    func animateIn () {
        
        self.alpha = 0
        self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height / 2)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.alpha = 1
            self.container.transform = .identity
        })
    }
    
    func playConfetti () {
        
        let maxScore = playerScores.max()
        let winningPlayers = playerScores.indices.filter { playerScores[$0] == maxScore }
        
        let emitLayer = CAEmitterLayer()
        emitLayer.emitterPosition = CGPoint(x: frame.width / 2, y: 0)
        emitLayer.scale = 0.1
        emitLayer.beginTime = CACurrentMediaTime();
        
        let colors: [UIColor] = winningPlayers.compactMap({
            return PLAYER_COLORS[$0]
        })
                
        let cells: [CAEmitterCell] = colors.compactMap {
            
            the_color in
            
            let cell = CAEmitterCell()
            cell.lifetime = 2
            cell.duration = 1
            cell.birthRate = 30
            cell.beginTime = 0.01
            cell.velocity = 300
            cell.contents = UIImage(named:"confetti")!.cgImage
            cell.color = the_color.cgColor
            cell.emissionRange = .pi * 2
            cell.yAcceleration = 1000
            cell.spin = CGFloat(Int.random(in: 0 ..< 30)) - 15.0
            
            return cell
        }
        
        emitLayer.emitterCells = cells
        
        layer.insertSublayer(emitLayer, at: 0)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            emitLayer.removeFromSuperlayer()
        }
    }
    
    @objc func closeNewGame() {
        self.animateOut()
        onComplete(GAME_OVER_COMPLETION_ACTION.NEW_GAME)
    }
    
    @objc func closeQuit () {
        self.animateOut()
        onComplete(GAME_OVER_COMPLETION_ACTION.QUIT)
    }
}
