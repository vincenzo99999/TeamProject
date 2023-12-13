//
//  Obstacle.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 12/12/23.
//

import Foundation
import SpriteKit

class Obstacle: Spawnable{
        
    override func Respawn() {
        //let randomNumber: Int = Int.random(in:1..<3)
        
        sprite = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity=true
        sprite.physicsBody?.mass = 100
        sprite.physicsBody?.usesPreciseCollisionDetection = true

        
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.floor
        
        sprite.physicsBody?.isDynamic = true
        sprite.zPosition=8
        sprite.physicsBody?.allowsRotation = false
        
        
        self.spawn(spawnPosition: CGPoint(x: scene.size.width + sprite.size.width,y: -floorHeight + sprite.size.height/2))
            
        print("Obstacle respawned")
    }
    

    
}
