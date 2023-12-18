import SpriteKit
import GameplayKit

class Sign:Spawnable{
    override func Respawn() {
        let horizontalPosition = (scene.frame.width) + sprite.size.width
        let elevation = -floorHeight + 110
        
        self.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
}
