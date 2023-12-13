//
//  LeaderboardScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 12/12/23.
//

import Foundation
import SpriteKit
import SwiftUI

@Observable
class Leaderboard {
    @ObservationIgnored
    @AppStorage("Leaderboard")
    var leaderboard = "carlo: 1337, arturo: 99999, giovanni: 69, vincenzo: NaN"
}


class LeaderboardScene: SKScene {

    @State var leaderboard: Leaderboard
    

    override init(){
        self.leaderboard = leaderboard
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
  

    override func didMove(to view: SKView) {
        leaderboardEntries = getSavedScores()
        setupUI()
    }

    func getSavedScores() -> [(name: String, score: Int)] {
        let savedScores = UserDefaults.standard.array(forKey: "leaderboard") as? [[String: Int]] ?? []
        return savedScores.compactMap { dict in
            if let name = dict.keys.first, let score = dict[name] {
                return (name, score)
            }
            return nil
        }.sorted { $0.score > $1.score }
    }


    func setupUI() {
        // IMMAGINE BACKGROUND LEADERBOARD
        let backgroundImage = SKSpriteNode(imageNamed: "leaderboardBackground")
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.zPosition = -1
        backgroundImage.size = self.frame.size
        addChild(backgroundImage)

        // FONT + ROBA TESTO
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "Leaderboard"
        titleLabel.fontSize = 50.0
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(titleLabel)

        // UGUALE A SOPRA MA INIZIALIZZA TUTTA LA ROBA
        for (index, entry) in leaderboardEntries.enumerated() {
            let entryLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            entryLabel.text = "\(entry.name): \(entry.score)"
            entryLabel.fontSize = 30.0
            entryLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100 - CGFloat(index * 40))
            addChild(entryLabel)
        }

        
        let backButton = SKLabelNode(fontNamed: "Helvetica-Bold")
        backButton.text = "Back"
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
                if let skView = self.view as? SKView {
                    let scene = GameMenuScene(size: skView.bounds.size)
                    scene.scaleMode = .aspectFill
                    skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
                }
            }
        }
    }
}

