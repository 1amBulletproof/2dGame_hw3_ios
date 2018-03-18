//
//  GameScene.swift
//  sideScroller
//
//  Created by Brandon Tarney on 3/11/18.
//  Copyright © 2018 Johns Hopkins University. All rights reserved.
//

import SpriteKit
import GameplayKit

func random() -> CGFloat
{
    return CGFloat(Float(arc4random())/0xFFFFFFFF)
}

func random(min:CGFloat, max:CGFloat) -> CGFloat
{
    return random()*(max-min) + min
}

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Spike : UInt32 = 0b1 //1
    static let Thor : UInt32 = 0b10 //2
    static let Hammer : UInt32 = 0b100 //4
    static let Hela : UInt32 = 0b1000 //8
}

enum TouchType {
    case TAP
    case SWIPE
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: CLASS PROPERTIES
    var gameViewController:GameViewController!
    let gameEndString = "GAME OVER: YOU "
    var gameEndResult:String?
    
    let winSpikeThreshold = 10
    var numberOfSpikesPassed:Int!
    var numberOfHits:Int!
    var score:Int! {
        get {
            return self.numberOfHits! * 10
        }
        set(newScore) {
            self.numberOfHits = newScore/10
            self.scoreLabel.text = String(newScore)
        }
    }
    
    var background1:SKSpriteNode!
    var background2:SKSpriteNode!
    var thor:SKSpriteNode!
    var thorPosition:CGPoint!
    var numberOfTimesThorHit:Int!
    
    var hela:SKSpriteNode!
    
    var touchType:TouchType!
    
    var scoreLabel:SKLabelNode!
    var scoreStaticLabel:SKLabelNode!
    
    var touchDownPoint:CGPoint!
    
    override func sceneDidLoad() {
        
        //Reset scores to 0
        self.addStaticScoreLabel()
        self.addScoreLabel()
        self.score = 0;
        self.numberOfSpikesPassed = 0;
        
        self.touchType = TouchType.TAP //default value
        
        self.addBackgroundImages()
    
        self.addThor()
        
        //TODO: make hela move up and down?
        self.addHela()
        
        run(SKAction.repeatForever(SKAction.sequence(
            [
                SKAction.run(addSpike),
                SKAction.wait(forDuration: 2.0)
            ])))
        
        self.addPhysics()
    }
    
    func addPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) //No gravity! Makes game too hard
        physicsWorld.contactDelegate = self
    }
    
    // MARK: ADD SPRITES
    func addBackgroundImages() {
        self.background1 = SKSpriteNode(imageNamed: "blue_sky_2")
        self.background1.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 )
        self.background1.size = CGSize(width: self.frame.width + 20, height: self.frame.height)
        self.background1.zPosition = -1
        self.addChild(self.background1)
        
        self.background2 = SKSpriteNode(imageNamed: "blue_sky_2")
        self.background2.size = CGSize(width: self.frame.width + 20, height: self.frame.height)
        self.background2.position = CGPoint(x: (self.frame.width/2) + background1.size.width, y: self.frame.height/2)
        self.background2.zPosition = -1
        self.addChild(self.background2)
    }
    
    func addStaticScoreLabel() {
        self.scoreStaticLabel = SKLabelNode()
        self.scoreStaticLabel.position = CGPoint(x: size.width - 150, y: size.height - 50)
        self.scoreStaticLabel.text = "SCORE:"
        self.scoreStaticLabel.fontColor = UIColor.green
    
        self.addChild(self.scoreStaticLabel)
    }
    
    func addScoreLabel() {
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.position = CGPoint(x: size.width - 50, y: size.height - 50)
        self.scoreLabel.text = "0"
        self.scoreLabel.fontColor = UIColor.green
        
        self.addChild(self.scoreLabel)
    }
    
    func addThor() {
        self.thor = SKSpriteNode(imageNamed: "thor")
        self.thor.xScale = 0.25
        self.thor.yScale = 0.25
        self.thorPosition = CGPoint(x: size.width * 0.2, y: size.height * 0.5)
        self.thor.position = self.thorPosition
        
        self.configureThorPhysics()
        
        self.addChild(thor)
    }
    
    func addHela() {
        self.hela = SKSpriteNode(imageNamed: "hela")
        self.hela.xScale = 0.2
        self.hela.yScale = 0.2
        self.hela.position = CGPoint(x: size.width*0.9, y: size.height*0.25)
        
        self.configureHelaPhysics()
        
        self.addChild(hela)
        
        let moveUp = SKAction.moveBy(x: 0, y: 200, duration: 2)
        let upAndDownSequence = SKAction.sequence([moveUp, moveUp.reversed()])
        self.hela.run(SKAction.repeatForever(upAndDownSequence))

    }
    
    func addSpike() {
        let spike = SKSpriteNode(imageNamed: "spike")
        spike.name = "spike"
        spike.xScale = 0.07
        spike.yScale = 0.07
        
        let actualY = random(min:spike.size.height/2, max:size.height - spike.size.height/2)
        
        spike.position = CGPoint(x: size.width + spike.size.width/2, y: actualY)
        
        addChild(spike)
        self.numberOfSpikesPassed = self.numberOfSpikesPassed + 1
        
        configureSpikePhysics(spike: spike)
        
        let actualDuration = random(min:CGFloat(3.0), max: CGFloat(5.0))
        
        let actionMove = SKAction.move(to: CGPoint(x:-spike.size.width/2, y:actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        spike.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func throwHammer() {
        let hammer = SKSpriteNode(imageNamed: "hammer")
        hammer.name = "hammer"
        hammer.xScale = 0.25
        hammer.yScale = 0.25
        
        //TODO: offset hammer X position
        hammer.position = CGPoint(x: self.thorPosition.x + 75, y: self.thorPosition.y + 25)
        
        addChild(hammer)
        
        configureHammerPhysics(hammer: hammer)
        
        let actualDuration = CGFloat(3.0)
        
        let actionMove = SKAction.move(to: CGPoint(x: size.width, y: self.thorPosition.y + 25), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        hammer.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    //MARK: CONFIGURE PHYSICS
    func configureThorPhysics() {
        self.thor.physicsBody = SKPhysicsBody(rectangleOf: self.thor.size)
        self.thor.physicsBody?.isDynamic = false
        self.thor.physicsBody?.categoryBitMask = PhysicsCategory.Thor
        self.thor.physicsBody?.contactTestBitMask = PhysicsCategory.Spike
        self.thor.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.thor.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    func configureHelaPhysics() {
        self.hela.physicsBody = SKPhysicsBody(rectangleOf: self.hela.size)
        self.hela.physicsBody?.isDynamic = false
        self.hela.physicsBody?.categoryBitMask = PhysicsCategory.Hela
        self.hela.physicsBody?.contactTestBitMask = PhysicsCategory.Hammer
        self.hela.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.hela.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    func configureHammerPhysics(hammer: SKSpriteNode) {
        hammer.physicsBody = SKPhysicsBody(rectangleOf: hammer.size)
        hammer.physicsBody?.isDynamic = true
        hammer.physicsBody?.categoryBitMask = PhysicsCategory.Hammer
        hammer.physicsBody?.contactTestBitMask = PhysicsCategory.Hela + PhysicsCategory.Spike
        //TODO: add contact bit mask item for collisions with spike?!
        hammer.physicsBody?.collisionBitMask = PhysicsCategory.None
        hammer.physicsBody?.usesPreciseCollisionDetection = false
        
    }
    
    func configureSpikePhysics(spike: SKSpriteNode) {
        spike.physicsBody = SKPhysicsBody(rectangleOf: spike.size)
        spike.physicsBody?.isDynamic = true
        spike.physicsBody?.categoryBitMask = PhysicsCategory.Spike
        spike.physicsBody?.contactTestBitMask = PhysicsCategory.Thor
        //TODO: add contact bit mask item for collisions with hammer?!
        spike.physicsBody?.collisionBitMask = PhysicsCategory.None
        spike.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    //MARK: HANDLE CONTACT EVENTS
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (self.numberOfSpikesPassed <= self.winSpikeThreshold) {
            if secondBody.categoryBitMask == PhysicsCategory.Thor {
                        //TODO: transition to lose screen
                self.gameEndResult = "LOSE"
                self.gameOver()
            } else if (secondBody.categoryBitMask == PhysicsCategory.Hela) {
                self.score = self.score + 10
            } else if (firstBody.categoryBitMask == PhysicsCategory.Spike &&
                    secondBody.categoryBitMask == PhysicsCategory.Hammer) {
                self.score = self.score + 10
                if  secondBody.node != nil {
                    (secondBody.node as! SKSpriteNode).removeFromParent()
                }
            }
        }

        guard firstBody.node != nil else { return }
        (firstBody.node as! SKSpriteNode).removeFromParent()

    }

    func moveThor(toNewYPosition: CGFloat) {
        let newThorPosition = CGPoint(x: self.thorPosition.x, y: toNewYPosition)
        self.thorPosition = newThorPosition
        self.thor.position = self.thorPosition //this is faster/more-instant than an actual move!
        //let moveThorUpOrDown = SKAction.move(to: newThorPosition, duration: 0.0001)
        //self.thor.run(moveThorUpOrDown)
    }
    
    //MARK: HANDLE TOUCH EVENTS
    func touchDown(atPoint pos : CGPoint) {
        self.touchType = TouchType.TAP
        self.touchDownPoint = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.touchType = TouchType.SWIPE
        self.moveThor(toNewYPosition: pos.y)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if self.touchType == TouchType.TAP {
            self.throwHammer()
        } else if ( abs(self.touchDownPoint.y - pos.y) < 10 ) {
            self.throwHammer() //Tapping often actually triggers some movement
        }
    }

    //MARK: PERIODIC UPDATES
    override func update(_ currentTime: TimeInterval) {
        if (self.numberOfSpikesPassed > self.winSpikeThreshold) {
            self.numberOfSpikesPassed = 0 //prevents this from firing multiple times
            self.gameEndResult = "WON"
            self.gameOver()
        }
        self.scrollBackground()
    }
    
    func scrollBackground() {
        //Move the set of images to the left
        self.background1.position = CGPoint(x: self.background1.position.x - 5, y: self.background1.position.y)
        self.background2.position = CGPoint(x: self.background2.position.x - 5, y: self.background2.position.y)
        
        //If/when an image gets too far to the left,  reseting the moving images:
        if (self.background1.position.x <= -self.frame.size.width/2) {
            self.background1.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            self.background2.position = CGPoint(x: (self.frame.width/2) + background1.size.width, y: self.frame.size.height/2)
        }
    }
    
    //MARK: GAME OVER
    func gameOver() {
        for node in self.children {
            if (node.name == "hammer" || node.name == "spike") {
                node.removeFromParent()
            }
        }
        self.gameViewController.finalScore = self.score
        self.gameViewController.finalGameStatus = self.gameEndString + self.gameEndResult!
        self.gameViewController.performSegue(withIdentifier: "segToEnd", sender: self.gameViewController)
    }
    


    //MARK: UNUSED

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}
