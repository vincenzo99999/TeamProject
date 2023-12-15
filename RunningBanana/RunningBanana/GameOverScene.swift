//
//  GameOverScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 11/12/23.
//




import SpriteKit
import UIKit
import Foundation
import AVFoundation


class GameOverScene: SKScene {
    var score: Int = 0
    var watermelonCollected: Int = 0
    var backgroundMusicPlayer: AVAudioPlayer?

    init(size: CGSize, score: Int, watermelonCollected: Int) {
        super.init(size: size)
        self.score = score
        self.watermelonCollected = watermelonCollected
        setupUI()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUI() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontColor = .black
        gameOverLabel.fontName = "helvetica-bold"
        gameOverLabel.fontSize = 50.0
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(gameOverLabel)
        
        let backgroundImage = SKSpriteNode(imageNamed: "gameOverBackground")
           backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
           backgroundImage.zPosition = -1
           backgroundImage.size = self.frame.size
           addChild(backgroundImage)


        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontColor = .white
        scoreLabel.fontName = "helvetica-bold"
        scoreLabel.fontSize = 30.0
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(scoreLabel)

        let watermelonLabel = SKLabelNode(text: "Watermelon Collected: \(watermelonCollected)")
        watermelonLabel.fontColor = .white
        watermelonLabel.fontName="helvetica-bold"
        watermelonLabel.fontSize = 30.0
        watermelonLabel.position = CGPoint(x: frame.midX, y: frame.midY + 500)
        addChild(watermelonLabel)

        let playAgainButton = SKLabelNode(text: "Play Again")
        playAgainButton.fontColor = .white
        playAgainButton.fontName="helvetica-bold"
        playAgainButton.fontSize = 30.0
        playAgainButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playAgainButton.name = "playAgain"
        addChild(playAgainButton)
        
        let enterNameButton = SKLabelNode(text: "Enter Name")
        enterNameButton.fontColor = .white
        enterNameButton.fontName = "helvetica-bold"
        enterNameButton.fontSize = 30.0
        enterNameButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        enterNameButton.name = "enterName"
        addChild(enterNameButton)
        
        let menuButton = SKLabelNode(text: "Menu")
        menuButton.fontColor = .white
        menuButton.fontName = "helvetica-bold"
        menuButton.fontSize = 30.0
        menuButton.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        menuButton.name = "menuButton"
        addChild(menuButton)
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }


    func restartGame() {
        if let skView = self.view as? SKView {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = SKSceneScaleMode.aspectFill
                skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }

    func playBackgroundMusic(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Could not find file: \(filename)")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch let error as NSError {
            print("Error playing music: \(error.localizedDescription)")
        }
    }

    
    
    
    func askForName() {
        if let skView = self.view as? SKView {
            let enterNameScene = EnterNameScene(size: skView.bounds.size)
            enterNameScene.scaleMode = SKSceneScaleMode.aspectFill
            enterNameScene.score = score
            enterNameScene.watermelonCollected = watermelonCollected
            skView.presentScene(enterNameScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "playAgain" {
                restartGame()
            } else if node.name == "enterName" {
                askForName()
            }
        }
    }
}

/*
 
 
               _                           _
              | |                         | |
__      ____ _| |_ ___ _ __ _ __ ___   ___| | ___  _ __
\ \ /\ / / _` | __/ _ \ '__| '_ ` _ \ / _ \ |/ _ \| '_ \
 \ V  V / (_| | ||  __/ |  | | | | | |  __/ | (_) | | | |
  \_/\_/ \__,_|\__\___|_|  |_| |_| |_|\___|_|\___/|_| |_| :D /*
                                          


                                                              */*/
