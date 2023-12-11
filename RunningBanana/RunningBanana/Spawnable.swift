//
//  Spawnable.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 11/12/23.
//

import Foundation
import SpriteKit

class Spawnable{
    //If an object is spawnable, it follows the last layer of the parallax
    
    var scene: SKScene
    var speed: CGFloat
    var sprite: SKSpriteNode
    
    var parallaxLastLayerSpeed: CGFloat
    
    init(scene: SKScene, speed: CGFloat, sprite: SKSpriteNode, spawnPosition: CGPoint, parallax: Parallax) {
        self.scene = scene
        self.speed = speed
        self.sprite = sprite
        self.parallaxLastLayerSpeed = parallax.speed + (CGFloat(parallax.parallaxLayerSprites.count-1) * parallax.speedFactor)
        
        sprite.position = spawnPosition
    }
    
    func update(){
        sprite.position.x -= speed
        //if completely outside the screen
        if sprite.position.x < (scene.frame.width + sprite.size.width){
            sprite.removeFromParent()
        }
    }
    
    func spawn(spawnPosition: CGPoint){
        sprite.position = spawnPosition
        scene.addChild(sprite)
    }

    
    
}
