//
//  Watermelon.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 12/12/23.
//

import Foundation
import SpriteKit

class Watermelon: Spawnable{
    var floorHeight = 150.0
    
    override func Respawn() {
        
        let horizontalPosition = (scene.frame.width) + sprite.size.width
        let elevation = CGFloat.random(in: -floorHeight..<((scene.size.height)/5))

        
        self.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
        print("Watermelon respawned")
    }
}
