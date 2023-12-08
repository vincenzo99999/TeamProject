//
//  GameScene.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //Parallax Array
    var parallaxLayerSprites: [SKSpriteNode?]? = []
    var parallax: Parallax? = nil
    
    
    var startTime: TimeInterval? = nil
    var hasStartTimeBeenAssigned = false
    
    
    
    override func sceneDidLoad() {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //get layers, somewhere
        let backTreeSprite = childNode(withName: "backTreeSprite") as! SKSpriteNode?
        let middleTreeSprite = childNode(withName: "middleTreeSprite") as! SKSpriteNode?
        let frontTreeSprite = childNode(withName: "frontTreeSprite") as! SKSpriteNode?
        let lightSprite = childNode(withName: "lightSprite") as! SKSpriteNode?
        
        
        //Append layers in order from the furthest one to the closest
        parallaxLayerSprites?.append(backTreeSprite)
        parallaxLayerSprites?.append(middleTreeSprite)
        parallaxLayerSprites?.append(lightSprite)
        parallaxLayerSprites?.append(frontTreeSprite)
        
        parallax = Parallax(scene: self, parallaxLayerSprites: parallaxLayerSprites!, getSpritesFromFile: false)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //Get start time
        if !hasStartTimeBeenAssigned {
            startTime = currentTime
            hasStartTimeBeenAssigned.toggle()
        }
        
        parallax!.update(layers: parallaxLayerSprites!, speed: 0.5, speedFactor: 1.0);
    }
    
    func elapsedTime(currentTime: TimeInterval) -> TimeInterval{
        return currentTime - startTime!
    }
    

}
