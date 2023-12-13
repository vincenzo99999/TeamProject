//
//  GameMenuScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 12/12/23.
//

import Foundation
import SpriteKit

class GameMenuScene: SKScene {

    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
    }

    private func setupBackground() {
        let backgroundImage = SKSpriteNode(imageNamed: "backgroundImage") //cambiare il nome qui se necessario 
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY) //DOVREBBE essere centrata
        backgroundImage.zPosition = -1 //lascia a -1
        backgroundImage.size = self.frame.size
        addChild(backgroundImage)
    }

    func setupUI() {
        let titleLabel = SKLabelNode(text: "Game Menu")
        titleLabel.fontSize = 50.0
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(titleLabel)

        let playButton = SKLabelNode(text: "Play")
        playButton.fontSize = 30.0
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        playButton.name = "play"
        addChild(playButton)

        let shopButton = SKLabelNode(text: "Shop")
        shopButton.fontSize = 30.0
        shopButton.position = CGPoint(x: frame.midX, y: frame.midY - 25)
        shopButton.name = "shop"
        addChild(shopButton)

        let leaderboardButton = SKLabelNode(text: "Leaderboard")
        leaderboardButton.fontSize = 30.0
        leaderboardButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        leaderboardButton.name = "leaderboard"
        addChild(leaderboardButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "play" {
                startGame()
            } else if node.name == "shop" {
                showShop()
            } else if node.name == "leaderboard" {
                showLeaderboard()
            }
        }
    }


    private func startGame() {
        if let skView = self.view as? SKView { //non guardare sti warning, fai finta di nulla >_>
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }

    private func showShop() {
        //hOI!!! i'm TEMMIE!!
        let shopLabel = SKLabelNode(text: "Shop Coming Soon!")
        shopLabel.fontSize = 40
        shopLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        shopLabel.name = "shopLabel"
        addChild(shopLabel)
    }
    private func showLeaderboard() {
        if let skView = self.view as? SKView { //non guardare sti warning, fai finta di nulla >_>
            let scene = LeaderboardScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
    
    private func goToMenu() {
        if let skView = self.view as? SKView { //non guardare sti warning, fai finta di nulla >_>
            let scene = GameMenuScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

}
