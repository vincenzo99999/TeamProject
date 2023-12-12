//
//  LeaderboardScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 12/12/23.
//

import Foundation
import SpriteKit

class LeaderboardScene: SKScene {
    
    let leaderboardEntries: [(name: String, score: Int)] = [
        ("Giovanni", 833),
        ("Arturo", 676),
        ("Vincenzo", 532),
        ("Carlo", 453),

    ]

    override func didMove(to view: SKView) {
        setupUI()
    }

    func setupUI() {
        let titleLabel = SKLabelNode(text: "Leaderboard")
        titleLabel.fontSize = 50.0
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(titleLabel)

        for (index, entry) in leaderboardEntries.enumerated() {
            let entryLabel = SKLabelNode(text: "\(entry.name): \(entry.score)")
            entryLabel.fontSize = 30.0
            entryLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100 - CGFloat(index * 40))
            addChild(entryLabel)
        }

        let backButton = SKLabelNode(text: "Back")
        backButton.fontSize = 30.0
        backButton.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        backButton.name = "back"
        addChild(backButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "back" {
                
            }
        }
    }
}
