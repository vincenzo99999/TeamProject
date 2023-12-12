import SpriteKit
import GameplayKit

class Hole:Spawnable{
    override func Respawn() {
        let horizontalPosition = (scene.frame.width) + sprite.size.width
        let elevation = -130.0
        self.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
}
