//
//  EnterNameScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 13/12/23.
//

import Foundation
import SpriteKit

class EnterNameScene: SKScene, UITextFieldDelegate {
    var score: Int = 0
    var watermelonCollected: Int = 0
    private var textField: UITextField!

    override func didMove(to view: SKView) {
        setupUI()
    }
    
    private func setupUI() {
        // Set up a label
        let nameLabel = SKLabelNode(text: "Enter Your Name")
        nameLabel.fontSize = 40
        nameLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(nameLabel)
        
        // Set up the text field
        textField = UITextField(frame: CGRect(x: frame.midX - 100, y: frame.midY - 50, width: 200, height: 40))
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.placeholder = "Name"
        textField.delegate = self
        self.view?.addSubview(textField)
        
        // Set up a submit button
        let submitButton = SKLabelNode(text: "Submit")
        submitButton.fontSize = 30
        submitButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        submitButton.name = "submitButton"
        addChild(submitButton)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    override func willMove(from view: SKView) {
        textField.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "submitButton" {
                submitName()
            }
        }
    }
    
    private func submitName() {
            guard let playerName = textField.text, !playerName.isEmpty else { return }
            saveScore(name: playerName)
            showLeaderboard()
        }
    
    private func saveScore(name: String) {
        var scores = UserDefaults.standard.array(forKey: "leaderboard") as? [[String: Int]] ?? []
        let newEntry = [name: score]
        scores.append(newEntry)
        UserDefaults.standard.set(scores, forKey: "leaderboard")
    }
    
    private func showLeaderboard() {
            if let skView = self.view as? SKView {
                let scene = LeaderboardScene(size: skView.bounds.size)
                scene.scaleMode = SKSceneScaleMode.aspectFill
                skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
    }
    
}
