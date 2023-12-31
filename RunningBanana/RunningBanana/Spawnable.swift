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
    var sprite: SKSpriteNode
    
    var parallaxLastLayerSpeed: CGFloat
    
    init(scene: SKScene, sprite: SKSpriteNode, parallax: Parallax) {
        self.scene = scene
        self.sprite = sprite
        self.parallaxLastLayerSpeed = parallax.speed + (CGFloat(parallax.parallaxLayerSprites.count-1) * parallax.speedFactor)
    }
    
    func update(){
        sprite.position.x -= parallaxLastLayerSpeed
        //print("\(String(describing: sprite.name)) position: \(sprite.position.x)")
        
        //if completely outside the screen
        if sprite.position.x < -(scene.size.width/2 + sprite.size.width){
            sprite.removeFromParent()
            print("\(String(describing: sprite.name)) removed")
            //Respawn probability
            if Int.random(in: 0...100) <= 10 {
                //spawn(spawnPosition: nextSpawnPosition)
                Respawn()
            }
            
        }
    }
    
    func spawn(spawnPosition: CGPoint){
        sprite.position = spawnPosition
        scene.addChild(sprite)
    }
    
    
    func Respawn(){
        print("override the Respawn method")
    }
    
    
}
