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
    
    
    var player:SKSpriteNode!
    
    var obstacle:SKSpriteNode!
    var obstacleCounter:Int=0
    
    
    var screenTouched:Bool=false
    var isJumping:Bool=false
    
    //Floor
    var floorHeight: CGFloat = 150
    weak var floorContactDelegate: FloorContactDelegate?
    var floor:SKSpriteNode!
    var roadSprite: SKSpriteNode? = nil
    
    //Score
    var scoreLabel:SKLabelNode!
    var score:CGFloat=0
    
    //Parallax Array
    var parallaxLayerSprites: [SKSpriteNode?]? = []
    var parallax: Parallax? = nil
    
    
    var watermelon:SKSpriteNode!
    
    
    //Spawn
    var watermelonSpawn: Spawnable?
    var obstacleSpawn: Obstacle?
    //TODO pass floor level to those
    
    //Running Time
    var startTime: TimeInterval? = nil
    var hasStartTimeBeenAssigned = false
    
    //position and velocity
    var posizionex: CGFloat = 1.4
    var velocityuser: CGFloat = 0.5
    
    //TODO holes on the road
    //TODO SpawnSystem
    
    
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
        
        
        createFloor()
        createPlayer()
        createScore()
        
        //Road
        parallaxLayerSprites?.append(floor)
        
        parallax = Parallax(scene: self,
                            parallaxLayerSprites: parallaxLayerSprites!,
                            getSpritesFromFile: false,
                            speed: velocityuser,
                            speedFactor: 0.8)
        createWatermelon()
        createObstacle()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if !hasStartTimeBeenAssigned {
            startTime = currentTime
            hasStartTimeBeenAssigned.toggle()
        }
        
        parallax!.update(layers: parallaxLayerSprites!);

        updateObstaclePosition()
        CheckPlayerSpeed()
        updatePlayerSpeed()
        updateWatermelonPosition()
        jump() //TODO fix jump
        updateScore()
        if isGameOver(){
            //add gameOverView()
        }
    }

    func isGameOver()->Bool{

        if player.position.x <= frame.width || player.position.y < floor.position.y{
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
        score = score+(velocityuser + CGFloat(obstacleCounter)) * 0.025
        scoreLabel.text = "\(Int(score))"
    }
    func createPlayer() {
        self.player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.name = "player"
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: -50, y: 35)
        
        let xRange: SKRange = SKRange(lowerLimit: -frame.width, upperLimit: -50)
        let xCostraint = SKConstraint.positionX(xRange)
        player.constraints = [xCostraint]
        
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
        floor = SKSpriteNode(color: .red, size: CGSize(width: scene!.size.width*3, height: floorHeight/2))
        floor.name = "floor"
        floor.position = CGPoint(x: 0, y: -floorHeight)  // Imposta la posizione del pavimento
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.affectedByGravity=false
        floor.physicsBody?.categoryBitMask = 2|PhysicsCategory.floor
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.player
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player
        floor.physicsBody?.isDynamic = false  // Il pavimento non si muove
        floor.zPosition=0
        
        
        let roadInstancesNumber: Int = 4
        let instanceWidth = (scene!.size.width*3)/CGFloat(roadInstancesNumber)
        
        for instance in 0...roadInstancesNumber{
            
            roadSprite = SKSpriteNode(imageNamed: "road")
            roadSprite?.zPosition = 5
            roadSprite?.size = CGSize(width: instanceWidth, height: (roadSprite?.size.height)! * 1.5)
            
            roadSprite?.position.x = (instanceWidth * CGFloat(instance)) - scene!.size.width/2
            floor.addChild(roadSprite!)
        }
        
        addChild(floor)
        
        
    }
    
    //TODO spawn watermelons outside the screen
    func createWatermelon(){
        watermelon=SKSpriteNode(color: .green, size: CGSize(width: 25, height: 25))
        watermelon.position.x = 70
        watermelon.name="Watermelon"
        
        watermelon.physicsBody=SKPhysicsBody(circleOfRadius:25)
        watermelon.physicsBody?.affectedByGravity=false
        watermelon.physicsBody?.isDynamic=true
        watermelon.physicsBody?.categoryBitMask=4
        watermelon.physicsBody?.contactTestBitMask = 4
        watermelon.zPosition=11
        watermelon.physicsBody?.categoryBitMask = PhysicsCategory.watermelon
        watermelon.physicsBody?.contactTestBitMask = PhysicsCategory.player
        watermelon.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        let horizontalPosition = (scene?.frame.width)! + watermelon.size.width
        let elevation = CGFloat.random(in: -floorHeight..<((scene?.size.height)!/5))
        
        watermelonSpawn = Watermelon(scene: self, sprite: watermelon, parallax: parallax!)
        watermelonSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
    
    func createObstacle(){
        
        let randomNumber: Int = Int.random(in:1..<3)
        obstacle = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50*randomNumber))
        //obstacle.position = CGPoint(x: 200, y: -floorHeight + 1)  // Imposta la posizione del pavimento
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.affectedByGravity=false
        obstacle.physicsBody?.categoryBitMask = 3
        obstacle.physicsBody?.isDynamic = true  // Il pavimento non si muove
        obstacle.zPosition=8
        obstacle.physicsBody?.allowsRotation = false
        
        //addChild(obstacle)
        
        let horizontalPosition = (scene?.frame.width)! + obstacle.size.width
        let elevation = -floorHeight + 1
        
        obstacleSpawn = Obstacle(scene: self, sprite: obstacle, parallax: parallax!)
        obstacleSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
        
        obstacleCounter+=1
    }
    
    func updateObstaclePosition(){
        obstacleSpawn?.update()
    }
    
    
    
    func updateWatermelonPosition(){
        watermelonSpawn?.update()
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
                self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
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
        if (player.physicsBody?.velocity.dx)! < 0 {
            player.physicsBody?.velocity.dx = -(player.physicsBody?.velocity.dx)!
        }
        player.physicsBody?.velocity.dx += 0.3
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

        if let node = firstBody.node, node.name == "Watermelon" && secondBody.node?.name=="player"{
            node.removeFromParent()
            //createWatermelon()
            print("contatto rilevato")
        }
        if let node = secondBody.node, node.name == "Watermelon" && firstBody.node?.name=="player" {
            node.removeFromParent()
            //createWatermelon()
            print("contatto rilevato")
        }
    }


    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }
    
    
}

