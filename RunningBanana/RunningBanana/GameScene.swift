//
//  GameScene.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//

import SpriteKit

class GameScene: SKScene {

    private var groundNode: SKSpriteNode!

<<<<<<< Updated upstream
=======

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player:SKSpriteNode!
    var backgroundMusicPlayer: AVAudioPlayer?
    
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
    var sign: SKSpriteNode!
    
    //Score
    var scoreLabel:SKLabelNode!
    var score:CGFloat=0
    var scoreBackground = SKShapeNode()
    var scoreMultiplierLabel: SKLabelNode?
    var scoreMultiplier: CGFloat = 0
    
    //Parallax Array
    var parallaxLayerSprites: [SKSpriteNode?]? = []
    var parallax: Parallax? = nil
    
    //Spawnables
    var watermelon:SKSpriteNode!
    var obstacle:SKSpriteNode!
    var hole:SKSpriteNode!
    var tank:SKSpriteNode!
    var cascione: SKSpriteNode!
    
    //Spawn
    var watermelonSpawn: Spawnable?
    var obstacleSpawn: Obstacle?
    var holeSpawn: Hole?
    var signSpawn: Sign?
    var tankSpawn: Tank?
    var cascioneSpawn: Cascione?
    
    //Running Time
    var startTime: TimeInterval? = nil
    var hasStartTimeBeenAssigned = false
    var elapsedTime: TimeInterval? = nil
    
    //position and velocity
    var posizionex: CGFloat = 1.4
    var velocityuser: CGFloat = 2.0
    
    //Animation
    var rotateLeft = SKAction.rotate(toAngle: .pi/3, duration: 0.6)
    var rotateRight = SKAction.rotate(toAngle: -.pi/3, duration: 0.6)
    var trickRotation = SKAction.rotate(toAngle: .pi*2 , duration: 0.8)
    
    var jumpRotation = SKAction.rotate(toAngle: .pi/4, duration: 0.6)
    var resetRotation = SKAction.rotate(toAngle: 0, duration: 0.6)
    
    var fadeIn = SKAction.fadeIn(withDuration: 0.2)
    var scale = SKAction.scale(by: 1.3, duration: 0.2)
    var fadeOut = SKAction.fadeOut(withDuration: 0.2)
    
    var fadeNScale: SKAction!
    
    //touch amount
    var touchingForSeconds: TimeInterval = 0.0
    var countTouchTime: Bool = false
    var isGamePaused: Bool = false
    
    //Dash
    var dashSpeed: CGFloat = 30.0
    var isDashing = false
    var isDashStarted = false
    var dashStartTime: TimeInterval = 0.0
    var dashTimer: TimeInterval = 0.0
    
    //Milestone
    let milestoneArray: [CGFloat] = [100.0, 200.0, 500.0]
    var progressBar: SKSpriteNode!
    var progressPercentage: CGFloat = 0.0
    var progressBarSize: CGFloat = 300.0
    
    
    
    override func sceneDidLoad() {
        
        playBackgroundMusic(filename: "TrerroteRiff.mp3") //Music (Approved by Tony!)
        
        //Animation
        fadeNScale = SKAction.sequence([SKAction.group([fadeIn,scale]),fadeOut])
        fadeNScale.timingMode = .easeOut
        
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
        createCascione()
        createTank()
        setupPauseButton()
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
        cascioneSpawn?.update()
        
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
        
        if isDashing {
            
            if !isDashStarted {
                isDashStarted = true
                dashStartTime = elapsedTime!
                startDash()
            }
            
            dashTimer = elapsedTime! - dashStartTime
            
            if dashTimer >= 0.2 {
                isDashStarted = false
                stopDash()
            }
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
    

    func createCascione(){
        
        let scale = 20.0
        
        cascione = SKSpriteNode(imageNamed: "box")
        cascione.size = CGSize(width: cascione.size.width/scale, height: cascione.size.height/scale)
        
        // let randomNumber: Int = Int.random(in:1..<3)
        //obstacle = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
        //obstacle.position = CGPoint(x: 200, y: -floorHeight + 1)  // Imposta la posizione del pavimento
        
        cascione.physicsBody = SKPhysicsBody(rectangleOf: cascione.size)
        cascione.physicsBody?.affectedByGravity=true
        cascione.physicsBody?.mass = 100
        cascione.physicsBody?.usesPreciseCollisionDetection = true
        
        cascione.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        cascione.physicsBody?.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.player
        
        cascione.physicsBody?.isDynamic = true
        cascione.zPosition=8
        cascione.physicsBody?.allowsRotation = false
        
        
        
        //addChild(obstacle)
        
        let horizontalPosition = (scene?.frame.width)! + obstacle.size.width
        let elevation = -floorHeight + 1
        
        cascioneSpawn = Cascione(scene: self, sprite: cascione, parallax: parallax!, floorHeight: floorHeight)
        cascioneSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
        
    }
    
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
        let elevation = CGFloat.random(in: (-floorHeight + 150.0)..<((scene?.size.height)!/5))
        
        watermelonSpawn = Watermelon(scene: self, sprite: watermelon, parallax: parallax!, floorHeight: floorHeight)
        watermelonSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation+20))
        
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
        tank.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let horizontalPosition = (scene?.frame.width)! + tank.size.width
        let elevation = CGFloat.random(in: (-floorHeight + 150.0)..<((scene?.size.height)!/5))
        
        tankSpawn = Tank(scene: self, sprite: tank, parallax: parallax!, floorHeight: floorHeight)
        tankSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition, y: elevation+20))
        
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
        
        holeSpawn = Hole(scene: self, sprite: hole, parallax: parallax!, floorHeight: floorHeight+20)
        holeSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
    
    func createSign(){
        sign=SKSpriteNode(imageNamed: "hole")
        sign.position.x = 70
        sign.name="hole"
        sign.size=CGSize(width: sign.size.width/6, height: sign.size.height/6)
        sign.zPosition=12

        
        
        let horizontalPosition = (scene?.frame.width)! + sign.size.width
        let elevation = floor.position.y-200
        
        signSpawn = Sign(scene: self, sprite: sign, parallax: parallax!, floorHeight: floorHeight+20)
        signSpawn!.spawn(spawnPosition: CGPoint(x: horizontalPosition,y: elevation))
    }
    func createScore(){
        scoreBackground = SKShapeNode(path:
                                        CGPath(roundedRect: CGRect(x: 0, y: 0,width: 180, height: 90), cornerWidth: 30, cornerHeight: 30, transform: nil))
        scoreBackground.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        scoreBackground.strokeColor = .white
        scoreBackground.zPosition = 12
        
        //MODIFY THIS ONE TO CHANGE POSITION OF THE SCORE
        scoreBackground.position = CGPoint(x: -400, y: 100)
        
        scoreLabel = SKLabelNode(text:"\(Int(score))")
        scoreLabel.fontSize=80.0
        scoreLabel.fontColor = .white
        scoreLabel.position=CGPoint(x: 90, y: 18)
        scoreLabel.zPosition=13
        
        scoreMultiplier = (velocityuser + CGFloat(obstacleCounter) + CGFloat(watermelonCollectedHandler)) * 0.025
        scoreMultiplierLabel = SKLabelNode(text: "x\(scoreMultiplier)")
        scoreMultiplierLabel?.position = CGPoint(x: 225, y: 30)
        scoreMultiplierLabel?.fontColor = .black
        
        
        
        scoreBackground.addChild(scoreLabel)
        scoreBackground.addChild(scoreMultiplierLabel!)
        
        addChild(scoreBackground)
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
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            
            for node in nodesAtLocation {
                if node.name == "pauseButton" {
                    togglePause()
                } else {
                    jump()
                    countTouchTime = true
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isJumping){
            player.run(resetRotation)
        }
        countTouchTime = false
        touchingForSeconds = 0.0
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -15.0))
    }
    
    func jump(){
        if(!isJumping){
            player.run(jumpRotation)
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
            isJumping=true
        }
        
    }
    
    
    func CheckIfGrounded(){
        if player.physicsBody?.velocity.dy==0{
            isJumping=false
        }
    }
    
    
    func updateVelocityUser(){
        velocityuser = velocityuser + 0.3
        print(velocityuser)
    }
    
    func updateHolePosition(){
        holeSpawn?.update()
    }
    
    func updateScore(){
        
        scoreMultiplier = (velocityuser + CGFloat(obstacleCounter) + CGFloat(watermelonCollectedHandler)) * 0.025
        scoreMultiplierLabel!.text = "x\(Double(round(scoreMultiplier * 100)/100))"
        
        score = score + scoreMultiplier
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
        stopBackgroundMusic() // Stop the music
    }
    
    

    
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        //Make 1 function for each collision
        
        if (firstBody.categoryBitMask == PhysicsCategory.obstacle && secondBody.categoryBitMask == PhysicsCategory.player) ||
            (firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.obstacle) {
            playCollisionSound()
        }
        
        func watermelonTouch(_ node: SKNode) {
            node.removeFromParent()
            watermelonCollectedHandler+=1
            print("melons: " + String(watermelonCollectedHandler))
            
            let watermelonAddedSprite: SKSpriteNode = watermelon.copy() as! SKSpriteNode
            watermelonAddedSprite.physicsBody?.contactTestBitMask = PhysicsCategory.none
            watermelonAddedSprite.position = scoreMultiplierLabel!.position
            scoreBackground.addChild(watermelonAddedSprite)
            fadeNScale = SKAction.sequence([SKAction.group([fadeIn,scale]),fadeOut, SKAction.removeFromParent()])
            fadeNScale.timingMode = .easeInEaseOut
            
            fadeNScale = SKAction.sequence([SKAction.group([fadeIn,scale]),fadeOut])
            
            watermelonAddedSprite.run(fadeNScale)
            
        }

        if let node = firstBody.node, node.name == "Watermelon" && secondBody.node?.name=="player"{
            watermelonTouch(node)
            updateVelocityUser()

        }
        if let node = secondBody.node, node.name == "Watermelon" && firstBody.node?.name=="player" {
            watermelonTouch(node)
            updateVelocityUser()

        }
        if let node = firstBody.node, node.name == "tank" && secondBody.node?.name=="player" {
            node.removeFromParent()
            tankCounter+=1
            createTank()
            isDashing = true
            print("Tanks: " + String(tankCounter))
        }
        if let node = secondBody.node, node.name == "tank" && firstBody.node?.name=="player" {
            node.removeFromParent()
            tankCounter+=1
            createTank()
            isDashing = true
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
>>>>>>> Stashed changes
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setupScene()
        startProceduralGeneration()
    }

    func setupScene() {
        // Add ground
        groundNode = SKSpriteNode(color: SKColor.green, size: CGSize(width: size.width, height: 100))
        groundNode.position = CGPoint(x: size.width / 2, y: groundNode.size.height / 2)
        addChild(groundNode)
    }

    func startProceduralGeneration() {
        // Run an action to create obstacles continuously
        let generateObstacles = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(createObstacle),
                SKAction.wait(forDuration: 2.0) // Adjust the duration as needed
            ])
        )
        run(generateObstacles)
    }

    func createObstacle() {
        // Example: Creating a simple obstacle
        let obstacle = SKSpriteNode(color: SKColor.red, size: CGSize(width: 50, height: 50))
        obstacle.position = CGPoint(x: size.width + obstacle.size.width / 2, y: groundNode.size.height + obstacle.size.height / 2)
        addChild(obstacle)

        // Move the obstacle from right to left
        let moveLeft = SKAction.moveBy(x: -(size.width + obstacle.size.width), y: 0, duration: 5.0) // Adjust the duration as needed
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
<<<<<<< Updated upstream
=======
    
    func playCollisionSound() {
        run(SKAction.playSoundFileNamed("bump.mp3", waitForCompletion: false))
    }

    
>>>>>>> Stashed changes
}

