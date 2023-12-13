//
//  GameOverScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 11/12/23.
//


// Inside GameOverScene.swift

import SpriteKit
import UIKit
import Foundation

class GameOverScene: SKScene {
    var score: Int = 0
    var watermelonCollected: Int = 0

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
        gameOverLabel.fontSize = 50.0
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(gameOverLabel)

        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 30.0
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(scoreLabel)

        let watermelonLabel = SKLabelNode(text: "Watermelon Collected: \(watermelonCollected)")
        watermelonLabel.fontSize = 30.0
        watermelonLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        addChild(watermelonLabel)

        let playAgainButton = SKLabelNode(text: "Play Again")
        playAgainButton.fontSize = 30.0
        playAgainButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        playAgainButton.name = "playAgain"
        addChild(playAgainButton)
        
        let enterNameButton = SKLabelNode(text: "Enter Name")
        enterNameButton.fontSize = 30.0
        enterNameButton.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        enterNameButton.name = "enterName"
        addChild(enterNameButton)
    }

    func restartGame() {
        if let skView = self.view as? SKView {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = SKSceneScaleMode.aspectFill
                skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
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
