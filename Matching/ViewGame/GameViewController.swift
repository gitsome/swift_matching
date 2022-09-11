//
//  GameViewController.swift
//  Matching
//
//  Created by john martin on 9/1/22.
//

import UIKit
import AVFoundation

let LAYOUT_CONFIGS = [
    "PORTRAIT": [
        12: ["rows": 3, "cols": 4],
        16: ["rows": 4, "cols": 4],
        24: ["rows": 4, "cols": 6]
    ],
    "LANDSCAPE": [
        12: ["rows": 4, "cols": 3],
        16: ["rows": 4, "cols": 4],
        24: ["rows": 6, "cols": 4]
    ]
]

enum SCREEN_ORIENTATION {
    case LANDSCAPE
    case PORTRAIT
}

class GameViewController: UIViewController {

    var audioPlayer = AVAudioPlayer()
    var wrongSound = URL(fileURLWithPath: Bundle.main.path(forResource: "wrong", ofType: "mp3")!)
    var correctSound = URL(fileURLWithPath: Bundle.main.path(forResource: "correct", ofType: "wav")!)
    var gameOverSound = URL(fileURLWithPath: Bundle.main.path(forResource: "gameOver", ofType: "wav")!)
    var gameStarted = URL(fileURLWithPath: Bundle.main.path(forResource: "gameStarted", ofType: "wav")!)
    
    var totalCards: Int = 0
    var totalPlayers: Int = 1
    var matchWithCaption = false
    var cardModelController: CardsModelController!
    var gameCardData: [Card] = []
    var cardViews: [CardView] = []
    
    var portraitConstraints:[NSLayoutConstraint] = []
    var landscapeConstraints:[NSLayoutConstraint] = []
        
    private var currentPlayer = 0
    private var playerScores: [Int] = []
    private var cardsSelected: [CardView] = []
    private var processing = false
    
    private var buttonsPanel: UIView!
    private var gamePanel: UIView!
    
    private var playersStackView: UIStackView!
    private var playerViews: [PlayerView] = []
        
    // load the root view programatically
    // if no view is automatically provided ( via Nib / Interface Builder ), then the view controller
    // will be asked for one, the default is to return an empty UIView,
    // you can override the default, but you must set the view property to something
    override func loadView() {
        super.loadView()
        let view = UIView()
        view.backgroundColor = .systemBackground
        self.view = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation bar for this view
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(animated)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        // hide the navigation bar for this view
        self.navigationController?.isNavigationBarHidden = false
                
        // the main containers
        setupGameSections()
        
        // the players
        setupGameButtons()
        
        // okay reset all the variables, create the cards and lay everything out
        startNewGame()
        
        // now lay everything out with the current frame
        setupConstraints()
    }

    override func viewWillLayoutSubviews () {
        print("viewWillLayoutSubviews")
        super.viewWillLayoutSubviews()
        activateOrientationConstraints()
    }
    
    override func viewDidLayoutSubviews () {
        print("viewDidLayoutSubviews")
        // we need to make sure the constraints from the main layout of this screen are in place before we layout the game cards within the gamePanel view
        layoutGameCards()
        super.viewDidLayoutSubviews()
    }
    
    func getScreenOrientation() -> SCREEN_ORIENTATION {
        
        if view.frame.size.width > view.frame.size.height {
            return SCREEN_ORIENTATION.LANDSCAPE
        } else {
            return SCREEN_ORIENTATION.PORTRAIT
        }
    }
    
    func startNewGame () {
        
        // load our random card data
        let randomCards = cardModelController.cards.choose(totalCards / 2)
        let randomCardsCopy = randomCards.compactMap({ $0.copy() })
        
        if matchWithCaption {
            for card in randomCardsCopy {
                card.viewType = CARD_VIEW_TYPE.CAPTION
            }
        }
        
        gameCardData = (randomCards + randomCardsCopy).shuffled()

        // reset the scores and score labels
        resetScores()
        updateScoreLabels()
        
        // reset the game cards
        resetGameCards()
        
        // it's player one's turn
        currentPlayer = 0
        cardsSelected = []
        processing = false
        playerViews[0].setIsActive(true)
        
        playGameStarted()
    }
    
    func setupGameSections() {
        
        // buttons panel
        buttonsPanel = UIView()
        buttonsPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsPanel)
        
        // game panel
        gamePanel = UIView()
        gamePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gamePanel)
    }
        
    func setupGameButtons() {
        
        playersStackView = UIStackView()
        playersStackView.axis = .horizontal
        playersStackView.distribution = .fillEqually
        playersStackView.spacing = 20
        playersStackView.alignment = .fill
        playersStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsPanel.addSubview(playersStackView)
        
        // player labels and score labels
        for i in 0..<totalPlayers {
            
            let playerView = PlayerView(playerNum: i)
            playerView.translatesAutoresizingMaskIntoConstraints = false
            playersStackView.addArrangedSubview(playerView)
            playerViews.append(playerView)
        }
    }
        
    func resetGameCards () {
        
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        cardViews = []
        
        for card in gameCardData {
            let cardView = CardView(card: card, onPress: onCardPressed(cardView:))
            gamePanel.addSubview(cardView)
            cardViews.append(cardView)
        }
    }
    
    func resetScores () {
        playerScores = []
        for i in 0..<totalPlayers {
            playerScores.append(0)
            playerViews[i].setIsActive(false)
        }
    }
    
    func updateScoreLabels () {
        for (index, playerView) in playerViews.enumerated() {
            playerView.setScore(playerScores[index])
        }
    }
    
    
    func playGameStarted () {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: gameStarted)
            audioPlayer.play()
       } catch {}
    }
    
    func playWrongSound () {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: wrongSound)
            audioPlayer.play()
       } catch {}
    }
    
    func playCorrectSound () {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: correctSound)
            audioPlayer.play()
       } catch {}
    }
    
    func playGameOverSound () {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: gameOverSound)
            audioPlayer.play()
       } catch {}
    }
    
    func launchGamesIsOver () {
        
        playGameOverSound()
        
        let gameOverView = GameOverView(playerScores: playerScores) {
            [weak self] overlayResultAction in
            
            if overlayResultAction == GAME_OVER_COMPLETION_ACTION.QUIT {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.startNewGame()
            }
        }
        
        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameOverView)
        
        gameOverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gameOverView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gameOverView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gameOverView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupConstraints () {
                        
        portraitConstraints = [
            buttonsPanel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            buttonsPanel.heightAnchor.constraint(equalToConstant: 90),
            buttonsPanel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            buttonsPanel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            playersStackView.leftAnchor.constraint(equalTo: buttonsPanel.leftAnchor),
            playersStackView.rightAnchor.constraint(equalTo: buttonsPanel.rightAnchor),
            playersStackView.topAnchor.constraint(equalTo: buttonsPanel.topAnchor),
            playersStackView.bottomAnchor.constraint(equalTo: buttonsPanel.bottomAnchor),
                    
            gamePanel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            gamePanel.bottomAnchor.constraint(equalTo: buttonsPanel.topAnchor, constant: -15),
            gamePanel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            gamePanel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ]
        
        
        landscapeConstraints = [
            buttonsPanel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonsPanel.widthAnchor.constraint(equalToConstant: 120),
            buttonsPanel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            buttonsPanel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -5),
            
            playersStackView.leftAnchor.constraint(equalTo: buttonsPanel.leftAnchor),
            playersStackView.rightAnchor.constraint(equalTo: buttonsPanel.rightAnchor),
            playersStackView.topAnchor.constraint(equalTo: buttonsPanel.topAnchor),
            playersStackView.bottomAnchor.constraint(equalTo: buttonsPanel.bottomAnchor),
            
            gamePanel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            gamePanel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -5),
            gamePanel.leftAnchor.constraint(equalTo: buttonsPanel.rightAnchor, constant: 15),
            gamePanel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ]
        
        activateOrientationConstraints()
    }
        
    func activateOrientationConstraints() {
                
        let isLandscape = getScreenOrientation() == SCREEN_ORIENTATION.LANDSCAPE
                
        if isLandscape {
            playersStackView.axis = .vertical
        } else {
            playersStackView.axis = .horizontal
        }
                
        // order matters or we get a constraint warning
        // deactivate first, then activate
        if isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }
        
    func layoutGameCards () {
                
        let isLandscape = getScreenOrientation() == SCREEN_ORIENTATION.LANDSCAPE
        
        var cardsPerRow = LAYOUT_CONFIGS["PORTRAIT"]![totalCards]!["rows"]!
        var cardsPerCol = LAYOUT_CONFIGS["PORTRAIT"]![totalCards]!["cols"]!
        
        if isLandscape  {
            cardsPerRow = LAYOUT_CONFIGS["LANDSCAPE"]![totalCards]!["rows"]!
            cardsPerCol = LAYOUT_CONFIGS["LANDSCAPE"]![totalCards]!["cols"]!
        }
                
        let marginSize = CGFloat(10.0)
        
        let maxWidth = gamePanel.frame.width
        let maxHeight = gamePanel.frame.height
                
        let cardAreaWidth = maxWidth - CGFloat(cardsPerRow - 1) * marginSize
        let maxCardWidth = cardAreaWidth / CGFloat(cardsPerRow)
        
        let cardAreaHeight = maxHeight - CGFloat(cardsPerCol - 1) * marginSize
        let maxCardHeight = cardAreaHeight / CGFloat(cardsPerCol)
        
        let maxCardSize = min(maxCardWidth, maxCardHeight)
           
        let marginX = (maxWidth - CGFloat(cardsPerRow) * maxCardSize - (CGFloat(cardsPerRow) - 1.0) * marginSize) / 2
        let marginY = (maxHeight - CGFloat(cardsPerCol) * maxCardSize - (CGFloat(cardsPerCol) - 1.0) * marginSize) / 2
                
        let chunkedCardViews = cardViews.chunked(into: cardsPerRow)
        
        // load the cardViews
        for (rowIndex, chunk) in chunkedCardViews.enumerated() {
            
            for (colIndex, cardView) in chunk.enumerated() {
                let newX = marginX + CGFloat(colIndex) * (maxCardSize + marginSize)
                let newY = marginY + CGFloat(rowIndex) * (maxCardSize + marginSize)
                cardView.frame = CGRect(x: newX, y: newY, width: maxCardSize, height: maxCardSize)
            }
        }
    }
    
    func playerScored (_ playerNum: Int) {
        
        playerScores[playerNum] = playerScores[playerNum] + 1
        updateScoreLabels()
        
        let playerView = playerViews[playerNum]
                
        let layer = CAEmitterLayer()
        layer.emitterPosition = CGPoint(x: playerView.playerScoreLabel.center.x, y: playerView.playerScoreLabel.center.y)
        layer.scale = 0.15
        
        layer.beginTime = CACurrentMediaTime();
        
        let colors: [UIColor] = [
            PLAYER_COLORS[playerNum]!
        ]
        
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
        
        layer.emitterCells = cells
        
        playerView.layer.insertSublayer(layer, at: UInt32(playerView.layer.sublayers?.count ?? 0))
        
        playCorrectSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            layer.removeFromSuperlayer()
        }
    }
    
    func onCardPressed(cardView: CardView) {
                        
        if processing {
            return
        }
        
        // prevents them from selecting the same card instance twice
        if cardsSelected.count == 1 && cardsSelected[0].cardViewId == cardView.cardViewId {
            return
        }
        
        cardView.showCard()
        cardsSelected.append(cardView)
        
        // if they have only selected one card, then we are done here, let the player play
        if cardsSelected.count == 1 {
            return
        }
        
        if cardsSelected.count == 2 {
            
            // delay to allow card to flip
            processing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                [weak self] in
                
                if let self = self {
                    
                    // wrong
                    if self.cardsSelected[0].card.uuid != self.cardsSelected[1].card.uuid {
                    
                        self.playWrongSound()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            [weak self] in
                            
                            if let self = self {
                            
                                for cardView in self.cardsSelected {
                                    cardView.hideCard()
                                }
                                
                                self.cardsSelected = []
                                
                                self.playerViews[self.currentPlayer].setIsActive(false)
                                
                                self.currentPlayer = self.currentPlayer + 1
                                if (self.currentPlayer > self.totalPlayers - 1) {
                                    self.currentPlayer = 0
                                }
                                
                                self.playerViews[self.currentPlayer].setIsActive(true)
                                
                                self.processing = false
                            }
                        }
                        
                    // right
                    } else {
                              
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                            [weak self] in
                                
                            if let self = self {
                            
                                for cardView in self.cardsSelected {
                                    
                                    cardView.isUserInteractionEnabled = false
                                    self.gamePanel.bringSubviewToFront(cardView)
                                    
                                    let cardGlobalPoint = cardView.globalPoint()!
                                    let playerGlobalPoint = self.playerViews[self.currentPlayer].playerScoreLabel.globalPoint()!
                                    
                                    let originalTransform = cardView.transform
                                    let finalTransform = originalTransform.translatedBy(x: playerGlobalPoint.x - cardGlobalPoint.x, y: playerGlobalPoint.y - cardGlobalPoint.y).scaledBy(x: 0.1, y: 0.1)
                                                                        
                                    UIView.animate(withDuration: 0.3, animations: {
                                        cardView.transform = finalTransform
                                        cardView.layer.opacity = 0
                                    }) {
                                        _ in
                                        cardView.isHidden = true
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            [weak self] in
                            
                            if let self = self {
                                
                                self.playerScored(self.currentPlayer)
                                
                                // no determine if the game is over
                                let totalPoints = self.playerScores.reduce(0, +)
                                
                                let gameIsOver = totalPoints == self.totalCards / 2
                                
                                if gameIsOver {
                                                                        
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        [weak self] in
                                        self?.launchGamesIsOver()
                                    }
                                
                                // if the game is not over then just continue on
                                } else {
                                    self.processing = false
                                    self.cardsSelected = []
                                }
                            }

                        }
                    }
                }
            }
        }
    }
    
}
