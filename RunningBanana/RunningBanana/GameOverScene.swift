//
//  GameOverScene.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 11/12/23.
//


// Inside GameOverScene.swift

import SpriteKit

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
    }

    //  NON MODIFICATE PLS. TROPPE LACRIME SONO STATE VERSATE IN QUESTO PUNTO DEL CODICE PORCACCIO DI [INSERIRE NOME ENTITA SUPERIORE]

    func restartGame() {
        if let skView = self.view as? SKView {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill

                skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "playAgain" {
                restartGame()
            }
        }
    }
}

