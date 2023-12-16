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
        backgroundColor = SKColor.white // Set a background color
        
        // Title
        let titleLabel = SKLabelNode(text: "Tutorial")
        titleLabel.fontColor = .black
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 40.0
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(titleLabel)
        
        // Description
        let descriptionText = [
            "Tony is in trouble! He has to recover his watermelons to sell them at the Market.",
            "Help him gather as many watermelons as possible!",
            "You can use the Gas tanks to go a bit faster.",
            "Every watermelon you pick, higher the score multiplier will be!"
        ]
        
        var currentYPosition = frame.midY + 70
        let spacing: CGFloat = 50.0
        
        for line in descriptionText {
            let lineLabel = SKLabelNode(text: line)
            lineLabel.fontColor = .black
            lineLabel.fontName = "Helvetica-Bold"
            lineLabel.fontSize = 30.0
            lineLabel.position = CGPoint(x: frame.midX, y: currentYPosition)
            lineLabel.numberOfLines = 8 // Allow multiple lines
            lineLabel.preferredMaxLayoutWidth = frame.width - 50 // Set max line width
            addChild(lineLabel)
            currentYPosition -= spacing
        }
        
        let backButton = SKLabelNode(text: "Back")
        backButton.fontColor = .black
        backButton.fontName = "Helvetica-Bold"
        backButton.fontSize = 30.0
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 50) // Adjust position as needed
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
