//
//  TutorialScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 16/12/23.
// i'm sleepy. send coffee

import SpriteKit
import GameplayKit
import Foundation


class TutorialScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        // Titolo
        let titleLabel = SKLabelNode(text: "Tutorial")
        titleLabel.fontColor = .black
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 40.0
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(titleLabel)
        
        let descriptionText = [
            "Tony is in trouble! Help him gather as many watermelons as possible!",
            "Tap the screen to make the Trerote jump",
            "You can use the Gas tanks to go a bit faster.",
            "Every watermelon you collect will increase the score multiplier!"
            ]
        
        var currentYPosition = frame.midY + 60
        let spacing: CGFloat = 60.0
        
        for line in descriptionText {
            let lineLabel = SKLabelNode(text: line)
            lineLabel.fontColor = .black
            lineLabel.fontName = "Helvetica-Bold"
            lineLabel.fontSize = 30.0
            lineLabel.position = CGPoint(x: frame.midX, y: currentYPosition)
            lineLabel.numberOfLines = 8
            lineLabel.preferredMaxLayoutWidth = frame.width - 50
            addChild(lineLabel)
            currentYPosition -= spacing
        }
        
        let backButton = SKLabelNode(text: "Back")
        backButton.fontColor = .black
        backButton.fontName = "Helvetica-Bold"
        backButton.fontSize = 30.0
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "backButton" {
            goToMainMenu()
        }
    }

    func goToMainMenu() {
        if let skView = self.view as? SKView {
            let gameMenuScene = GameMenuScene(size: skView.bounds.size)
            gameMenuScene.scaleMode = .aspectFill
            skView.presentScene(gameMenuScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }

    
}
