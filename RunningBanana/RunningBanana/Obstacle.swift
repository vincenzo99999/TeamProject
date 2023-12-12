//
//  Obstacle.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 12/12/23.
//

import Foundation
import SpriteKit

class Obstacle: Spawnable{
    var floorHeight: CGFloat = 150.0
    
    
    
    override func Respawn() {
        let randomNumber: Int = Int.random(in:1..<3)
        
        sprite = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50*randomNumber))
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity=true
        sprite.physicsBody?.categoryBitMask = 3
        sprite.physicsBody?.isDynamic = true  // Il pavimento non si muove
        sprite.zPosition=8
        sprite.physicsBody?.allowsRotation = false
        
        
        self.spawn(spawnPosition: CGPoint(x: scene.size.width + sprite.size.width,y: -floorHeight + 1))
        
        print("Obstacle respawned")
    }
    
}
