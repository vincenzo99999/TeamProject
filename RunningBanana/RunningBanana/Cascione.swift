//
//  Cascione.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 15/12/23.
//

import Foundation
import SpriteKit

class Cascione: Spawnable{
    
    override func Respawn() {
        
        self.spawn(spawnPosition: CGPoint(x: scene.size.width + sprite.size.width,y: -floorHeight + sprite.size.height/2))
            
        print("Cascione respawned")
    }
    
}
