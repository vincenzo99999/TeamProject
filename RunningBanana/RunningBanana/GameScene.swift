//
//  GameScene.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//

import SpriteKit
import GameplayKit
struct PhysicsCategory{
    static let none:UInt32 = 0
    static let all :UInt32 = UInt32.max
    static let player : UInt32 = 0b1
    static let watermelon : UInt32 = 0b10
    static let floor:UInt32=0b11
}
protocol FloorContactDelegate: AnyObject {
    func playerDidContactFloor()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel:SKLabelNode!
    var score:CGFloat=0
    var obstacleCounter:Int=0
    var player:SKSpriteNode!
    var screenTouched:Bool=false
    var isJumping:Bool=false
    var obstacle:SKSpriteNode!
    weak var floorContactDelegate: FloorContactDelegate?
    var floor:SKSpriteNode!
    //Parallax Array
    var parallaxLayerSprites: [SKSpriteNode?]? = []
    var parallax: Parallax? = nil
    var watermelon:SKSpriteNode!
    
    var startTime: TimeInterval? = nil
    var hasStartTimeBeenAssigned = false
    
    
    
    override func sceneDidLoad() {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsWorld.gravity=CGVector(dx: 0, dy: -2)
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
        createFloor()
        createPlayer()
        createObstacle()
        createScore()
        createWatermelon()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if !hasStartTimeBeenAssigned {
            startTime = currentTime
            hasStartTimeBeenAssigned.toggle()
        }
        
        parallax!.update(layers: parallaxLayerSprites!, speed: 0.5, speedFactor: 1.0);
        updateObstaclePosition()
        CheckPlayerSpeed()
        updatePlayerSpeed()
        updateWatermelonPosition()
        jump()
        updateScore()
        if GameOver(){
            //add gameOverView()
        }
    }
    func GameOver()->Bool{
        if player.position.x<=frame.width||player.position.y<floor.position.y{
            return true
        }
        else{
            return false
        }
    }
    func elapsedTime(currentTime: TimeInterval) -> TimeInterval{
        return currentTime - startTime!
    }
    func updateScore(){
        score=score+((player.physicsBody?.velocity.dx)! + CGFloat(obstacleCounter)) * 0.001
        scoreLabel.text = "\(Int(score))"
    }
    func createPlayer() {
        self.player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.name = "player"
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: -50, y: 35)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.watermelon
        player.physicsBody?.collisionBitMask = PhysicsCategory.watermelon | PhysicsCategory.floor
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.velocity.dy = 0
        player.zPosition = 10
        addChild(player)
    }
    func createFloor() {
        floor = SKSpriteNode(color: .red, size: CGSize(width: size.width, height: 10))
        floor.position = CGPoint(x: 0, y: -50)  // Imposta la posizione del pavimento
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.affectedByGravity=false
        floor.physicsBody?.categoryBitMask = 2|PhysicsCategory.floor
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.player
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player
        floor.physicsBody?.isDynamic = false  // Il pavimento non si muove
        floor.zPosition=9
        addChild(floor)
    }
    func createWatermelon(){
        watermelon=SKSpriteNode(color: .green, size: CGSize(width: 25, height: 25))
        watermelon.position.x=70
        watermelon.position.y=CGFloat.random(in:floor.position.y..<frame.height)
        watermelon.name="Watermelon"
        watermelon.physicsBody=SKPhysicsBody(circleOfRadius:25)
        watermelon.physicsBody?.affectedByGravity=false
        watermelon.physicsBody?.categoryBitMask=4
        watermelon.physicsBody?.contactTestBitMask = 4
        watermelon.physicsBody?.isDynamic=true
        watermelon.zPosition=11
        watermelon.physicsBody?.categoryBitMask = PhysicsCategory.watermelon
        watermelon.physicsBody?.contactTestBitMask = PhysicsCategory.player
        watermelon.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        addChild(watermelon)
        
    }
    func updateWatermelonPosition(){
        watermelon.position.x -= 1.4
        if watermelon.position.x < -80{
            if let node=watermelon{
                node.removeFromParent()
                createWatermelon()
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        screenTouched = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        screenTouched = false
    }
    func jump(){
        if ScreenHasBeenPressed(){
            if(!isJumping){
                self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
                isJumping=true
            }
        }
    }
    func ScreenHasBeenPressed() -> Bool {
        return screenTouched
    }
    func CheckPlayerSpeed(){
        if player.physicsBody?.velocity.dy==0{
            isJumping=false
        }
    }
    func updatePlayerSpeed(){
        if (player.physicsBody?.velocity.dx)!<0{
            player.physicsBody?.velocity.dx = -(player.physicsBody?.velocity.dx)!
        }
        player.physicsBody?.velocity.dx+=0.3
        player.position.x = -50
        
    }
    func updateObstaclePosition(){
        obstacle.position.x -= 1.4
        if obstacle.position.x <= -300 {
            if let node=obstacle{
                node.removeFromParent()
                createObstacle()
                print("obstacle was removed")
            }
        }
    }
    func createObstacle(){
        let randomNumber:CGFloat=CGFloat.random(in:1..<2).rounded()
        obstacle = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50*randomNumber))
        obstacle.position = CGPoint(x: 200, y: -35)  // Imposta la posizione del pavimento
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.affectedByGravity=false
        obstacle.physicsBody?.categoryBitMask = 3
        obstacle.physicsBody?.isDynamic = true  // Il pavimento non si muove
        obstacle.zPosition=8
        addChild(obstacle)
        obstacleCounter+=1
    }
    func createScore(){
        scoreLabel = SKLabelNode(text:"\(Int(score))")
        scoreLabel.fontSize=70.0
        scoreLabel.fontColor = .black
        scoreLabel.position=CGPoint(x: -70, y: 100)
        scoreLabel.zPosition=7
        addChild(scoreLabel)
    }
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB

        if let node = firstBody.node, node.name == "Watermelon" {
            node.removeFromParent()
            createWatermelon()
            print("contatto rilevato")
        }
        if let node = secondBody.node, node.name == "Watermelon" {
            node.removeFromParent()
            createWatermelon()
            print("contatto rilevato")
        }
    }


    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }
}


        

