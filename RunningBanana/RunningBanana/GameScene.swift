//  GameScene.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//  Code partially cleaned by Arturo - "I did what i could"

import SpriteKit
import GameplayKit
import Foundation
import SwiftUI

struct PhysicsCategory{
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let player: UInt32 = 0x1 << 1
    static let watermelon: UInt32 = 0x1 << 2
    static let floor:UInt32 = 0x1 << 3
    static let tank:UInt32 = 0x1 << 4
    static let hole:UInt32 = 0x1 << 5
    static let obstacle: UInt32 = 0x1 << 6
}
protocol FloorContactDelegate: AnyObject {
    func playerDidContactFloor()
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player:SKSpriteNode!
    
    //Counters
    var obstacleCounter:Int=0
    var tankCounter:Int=0
    var watermelonCollectedHandler:Int=0
    
    //Physics
    var isJumping:Bool=false
    var worldGravity = -3.8
    
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
    
    //Spawnables
    var watermelon:SKSpriteNode!
    var obstacle:SKSpriteNode!
    var hole:SKSpriteNode!
    var tank:SKSpriteNode!
    
    //Spawn
    var watermelonSpawn: Spawnable?
    var obstacleSpawn: Obstacle?
    var holeSpawn: Hole?
    var tankSpawn: Tank?
    
    //Running Time
    var startTime: TimeInterval? = nil
    var hasStartTimeBeenAssigned = false
    var elapsedTime: TimeInterval? = nil
    
    //position and velocity
    var posizionex: CGFloat = 1.4
    var velocityuser: CGFloat = 1.0
    
    //Animation
    var rotateLeft = SKAction.rotate(toAngle: .pi/3, duration: 0.6)
    var rotateRight = SKAction.rotate(toAngle: -.pi/3, duration: 0.6)
    var trickRotation = SKAction.rotate(toAngle: .pi*2 , duration: 0.8)
    
    var jumpRotation = SKAction.rotate(toAngle: .pi/4, duration: 0.6)
    var resetRotation = SKAction.rotate(toAngle: 0, duration: 0.6)
    
    
    //touch amount
    var touchingForSeconds: TimeInterval = 0.0
    var countTouchTime: Bool = false
    
    override func sceneDidLoad() {
        
        //set anchor point
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //physics setup
        self.physicsWorld.gravity=CGVector(dx: 0, dy: worldGravity) //changed
        
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
        
        //Spawnables must be created AFTER parallax
        createHole()
        createWatermelon()
        createObstacle()
        createTank()
    }
    
    //Called every frame
    override func update(_ currentTime: TimeInterval) {
        //Get start time
        if !hasStartTimeBeenAssigned {
            startTime = currentTime
            hasStartTimeBeenAssigned.toggle()
        }
        elapsedTime = getElapsedTime(currentTime: currentTime)
        
        //Updates every frame
        parallax!.update(layers: parallaxLayerSprites!);
        
        //Spawnables update
        obstacleSpawn?.update()
        watermelonSpawn?.update()
        tankSpawn?.update()
        holeSpawn?.update()
        
        CheckIfGrounded()
        
        //This is useless because we already speed up the world overtime
        //updatePlayerSpeed()
        
        updateScore()
        
        //updateTankPosition() //TODO delete this function
        
        //Shold think about nitro implementation
        activateNitro()
        
        //Touch amount
        if(countTouchTime){
            touchingForSeconds = currentTime - elapsedTime!
            //print("Touch time \(touchingForSeconds)")
        }
        
        
        // Check for game over
        if isGameOver() {
            showGameOverScene()
        }
    }
    
    
    func createPlayer() {
        self.player = SKSpriteNode(imageNamed: "treruote")
        player.name = "player"
        player.size = CGSize(width: player.size.width/2, height: player.size.height/2)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.mass = 0.1
        player.physicsBody?.restitution = 0 //necessary to always be pushed
        
        
        player.position = CGPoint(x: -50, y: -floorHeight + player.size.height/2)
        let xRange: SKRange = SKRange(lowerLimit: -frame.width, upperLimit: -50)
        let xCostraint = SKConstraint.positionX(xRange)
        player.constraints = [xCostraint]
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic=true
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.watermelon | PhysicsCategory.tank
        player.physicsBody?.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.obstacle
        
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.velocity.dy = 0
        player.zPosition = 8
        addChild(player)
    }
    
    func createFloor() {
        floor = SKSpriteNode(color: .red, size: CGSize(width: scene!.size.width*3, height: floorHeight/2))
        floor.name = "floor"
        floor.position = CGPoint(x: 0, y: -floorHeight)  // Imposta la posizione del pavimento
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.affectedByGravity=false
        
        //Collision and test
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.player
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.obstacle
        
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
        
        let scale = 40.0
        //watermelon=SKSpriteNode(color: .green, size: CGSize(width: 25, height: 25))
        watermelon = SKSpriteNode(imageNamed: "melon")
        watermelon.size = CGSize(width: watermelon.size.width/scale, height: watermelon.size.width/scale)
        
        watermelon.position.x = 70
        watermelon.name="Watermelon"
        
        watermelon.physicsBody=SKPhysicsBody(circleOfRadius:25)
        watermelon.physicsBody?.affectedByGravity=false
        watermelon.physicsBody?.isDynamic=true
        watermelon.physicsBody?.categoryBitMask=4
        watermelon.zPosition=11
        watermelon.physicsBody?.categoryBitMask = PhysicsCategory.watermelon
        watermelon.physicsBody?.contactTestBitMask = PhysicsCategory.player
        watermelon.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let horizontalPosition = (scene?.frame.width)! + watermelon.size.width
        let elevation = CGFloat.random(in: -(floorHeight + 50.0)..<((scene?.size.height)!/5))
        
        watermelonSpawn = Watermelon(scene: self, sprite: watermelon, parallax: parallax!, floorHeight: floorHeight)
        watermelonSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
        
        //Animation
        let sequence = SKAction.sequence([rotateLeft, rotateRight])
        let animation = SKAction.repeatForever(sequence)
        
        watermelon.run(animation)
        
    }
    
    func createObstacle(){
        let scale = 35.0
        
        obstacle = SKSpriteNode(imageNamed: "box")
        obstacle.size = CGSize(width: obstacle.size.width/scale, height: obstacle.size.height/scale)
        
        // let randomNumber: Int = Int.random(in:1..<3)
        //obstacle = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
        //obstacle.position = CGPoint(x: 200, y: -floorHeight + 1)  // Imposta la posizione del pavimento
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.affectedByGravity=true
        obstacle.physicsBody?.mass = 100
        obstacle.physicsBody?.usesPreciseCollisionDetection = true
        
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.player
        
        obstacle.physicsBody?.isDynamic = true
        obstacle.zPosition=8
        obstacle.physicsBody?.allowsRotation = false
        
        
        
        //addChild(obstacle)
        
        let horizontalPosition = (scene?.frame.width)! + obstacle.size.width
        let elevation = -floorHeight + 1
        
        obstacleSpawn = Obstacle(scene: self, sprite: obstacle, parallax: parallax!, floorHeight: floorHeight)
        obstacleSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
        
        obstacleCounter+=1
    }
    
    
    func createTank(){
        
        let scale = 10.0
        tank = SKSpriteNode(imageNamed: "nitro")
        tank.size = CGSize(width: tank.size.width/scale, height: tank.size.height/scale)
        //tank=SKSpriteNode(color: .black, size: CGSize(width: 25, height: 25))
        tank.position.x = 70
        tank.position.y = CGFloat.random(in: -(floorHeight + 100.0)..<((scene?.size.height)!/5))
        tank.name="tank"
        tank.physicsBody=SKPhysicsBody(circleOfRadius:25)
        tank.physicsBody?.affectedByGravity=false
        tank.physicsBody?.categoryBitMask=5
        tank.physicsBody?.contactTestBitMask = 5
        tank.physicsBody?.isDynamic=false
        tank.zPosition=12
        
        tank.physicsBody?.categoryBitMask = PhysicsCategory.tank
        tank.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        let horizontalPosition = (scene?.frame.width)! + tank.size.width
        let elevation = CGFloat.random(in: -(floorHeight + 50.0)..<((scene?.size.height)!/5))
        
        tankSpawn = Tank(scene: self, sprite: tank, parallax: parallax!, floorHeight: floorHeight)
        tankSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition, y: elevation))
        
        //Animation
        let sequence = SKAction.sequence([rotateLeft, rotateRight])
        let animation = SKAction.repeatForever(sequence)
        
        tank.run(animation)
        
    }
    
    func createHole(){
        hole=SKSpriteNode(imageNamed: "hole")
        hole.position.x = 70
        hole.name="hole"
        hole.size=CGSize(width: hole.size.width/6, height: hole.size.height/6)
        hole.physicsBody=SKPhysicsBody(rectangleOf: CGSize(width: hole.size.width/4, height:hole.size.height*1.5))
        hole.physicsBody?.affectedByGravity=false
        hole.physicsBody?.isDynamic=false
        hole.physicsBody?.categoryBitMask=6
        hole.physicsBody?.contactTestBitMask = 6
        hole.zPosition=11
        
        hole.physicsBody?.categoryBitMask = PhysicsCategory.hole
        hole.physicsBody?.contactTestBitMask = PhysicsCategory.player
        hole.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        
        let horizontalPosition = (scene?.frame.width)! + hole.size.width
        let elevation = floor.position.y-200
        
        holeSpawn = Hole(scene: self, sprite: hole, parallax: parallax!, floorHeight: floorHeight)
        holeSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
    
    func createScore(){
        scoreLabel = SKLabelNode(text:"\(Int(score))")
        scoreLabel.fontSize=80.0
        scoreLabel.fontColor = .yellow
        
        scoreLabel.position=CGPoint(x:0, y: 100)
        scoreLabel.zPosition=12
        addChild(scoreLabel)
    }
    
    
    func activateNitro(){
        if tankCounter%10 == 0 && tankCounter != 0{
            player.physicsBody?.applyImpulse(CGVector(dx: 100   , dy: 0))
            print(tankCounter)
            print("Nitro attivato")
            tankCounter=0
        }
    }
    
    
    
    func isGameOver()->Bool{
        
        if player.position.x <= -(scene?.size.width)!/2 || player.position.y < floor.position.y{
            return true
        }
        return false
        
    }
    func getElapsedTime(currentTime: TimeInterval) -> TimeInterval{
        return currentTime - startTime!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jump()
        countTouchTime = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isJumping){
            player.run(resetRotation)
        }
        countTouchTime = false
        touchingForSeconds = 0.0
    }
    
    func jump(){
        if(!isJumping){
            player.run(jumpRotation)
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            isJumping=true
        }
        
    }
    
    
    func CheckIfGrounded(){
        if player.physicsBody?.velocity.dy==0{
            isJumping=false
        }
    }
    
    
    func updateVelocityUser(){
        velocityuser = velocityuser * elapsedTime! * 0.025
    }
    
    func updateHolePosition(){
        holeSpawn?.update()
    }
    
    func updateScore(){
        score = score+(velocityuser + CGFloat(obstacleCounter) + CGFloat(watermelonCollectedHandler)) * 0.025
        scoreLabel.text = "\(Int(score))"
    }
    
    //This creates problems
    func updatePlayerSpeed(){
        if (player.physicsBody?.velocity.dx)! < 0 {
            player.physicsBody?.velocity.dx = -(player.physicsBody?.velocity.dx)!
        }
        player.physicsBody?.velocity.dx += 0.3
    }
    
    func showGameOverScene() {
        let gameOverScene = GameOverScene(size: size, score: Int(score), watermelonCollected: obstacleCounter)
        gameOverScene.scaleMode = scaleMode
        view?.presentScene(gameOverScene)
    }
    
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if let node = firstBody.node, node.name == "Watermelon" && secondBody.node?.name=="player"{
            node.removeFromParent()
            watermelonCollectedHandler+=1
            print("melons: " + String(watermelonCollectedHandler))
        }
        if let node = secondBody.node, node.name == "Watermelon" && firstBody.node?.name=="player" {
            node.removeFromParent()
            watermelonCollectedHandler+=1
            print("melons: " + String(watermelonCollectedHandler))
        }
        if let node = firstBody.node, node.name == "tank" && secondBody.node?.name=="player" {
            node.removeFromParent()
            tankCounter+=1
            createTank()
            print("Tanks: " + String(tankCounter))
        }
        if let node = secondBody.node, node.name == "tank" && firstBody.node?.name=="player" {
            node.removeFromParent()
            tankCounter+=1
            createTank()
            print("Tanks: " + String(tankCounter))
        }
        if let node = secondBody.node, node.name == "obstacle" && firstBody.node?.name == "player"{
            player.position.x -= velocityuser
            print("Player touched obstacle")
        }
        if let node = firstBody.node, node.name == "obstacle" && secondBody.node?.name == "player"{
            player.position.x -= velocityuser
            print("Player touched obstacle")

        }
        
        
        if let node = secondBody.node, node.name == "hole" && firstBody.node?.name == "player"{
            showGameOverScene()
        }
        if let node = firstBody.node, node.name == "hole" && secondBody.node?.name == "player"{
            showGameOverScene()
        }
    }
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }
    
    
}

