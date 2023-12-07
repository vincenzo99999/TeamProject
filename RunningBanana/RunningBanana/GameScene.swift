//
//  GameScene.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//

import SpriteKit

class GameScene: SKScene {

    private var groundNode: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setupScene()
        startProceduralGeneration()
    }

    func setupScene() {
        // Add ground
        groundNode = SKSpriteNode(color: SKColor.green, size: CGSize(width: size.width, height: 100))
        groundNode.position = CGPoint(x: size.width / 2, y: groundNode.size.height / 2)
        addChild(groundNode)
    }

    func startProceduralGeneration() {
        // Run an action to create obstacles continuously
        let generateObstacles = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(createObstacle),
                SKAction.wait(forDuration: 2.0) // Adjust the duration as needed
            ])
        )
        run(generateObstacles)
    }

    func createObstacle() {
        // Example: Creating a simple obstacle
        let obstacle = SKSpriteNode(color: SKColor.red, size: CGSize(width: 50, height: 50))
        obstacle.position = CGPoint(x: size.width + obstacle.size.width / 2, y: groundNode.size.height + obstacle.size.height / 2)
        addChild(obstacle)

        // Move the obstacle from right to left
        let moveLeft = SKAction.moveBy(x: -(size.width + obstacle.size.width), y: 0, duration: 5.0) // Adjust the duration as needed
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

