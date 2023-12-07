//
//  SpawnSystem.swift
//  RunningBanana
//
//  Created by Giovanni Bifulco on 07/12/23.
//

import SpriteKit

class SpawnSystem {

    let scene: SKNode
    let watermelonCategory: UInt32 = 0x1 << 0
    let fuelCanisterCategory: UInt32 = 0x1 << 1

    init(scene: SKNode) {
        self.scene = scene
        startSpawning() //USARE QUESTO METHOD PER INIZIALIZZARE LO SPAWN
    }

    func startSpawning() {
        let spawnAction = SKAction.run {
            self.spawnItem()
        }

        let waitAction = SKAction.wait(forDuration: 4.5)
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)

        scene.run(repeatAction)
    }

    func spawnItem() {
        let randomX = CGFloat.random(in: 0..<scene.frame.width)
        let randomY = CGFloat.random(in: 0..<scene.frame.height)

        if Bool.random() {
            let watermelon = SKSpriteNode(imageNamed: "watermelonImageName")
            watermelon.position = CGPoint(x: randomX, y: randomY)
            watermelon.physicsBody = SKPhysicsBody(rectangleOf: watermelon.size)
            watermelon.physicsBody?.categoryBitMask = watermelonCategory
            scene.addChild(watermelon)
        } else {
            let fuelCanister = SKSpriteNode(imageNamed: "fuelCanisterImageName")
            fuelCanister.position = CGPoint(x: randomX, y: randomY)
            fuelCanister.physicsBody = SKPhysicsBody(rectangleOf: fuelCanister.size)
            fuelCanister.physicsBody?.categoryBitMask = fuelCanisterCategory
            scene.addChild(fuelCanister)
        }
    }


}


