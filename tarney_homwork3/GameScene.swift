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
    
    var lastUpdateTime:TimeInterval!
    
    var thor:SKSpriteNode!
    var thorPosition:CGPoint!
    var numberOfTimesThorHit:Int!
    
    var hela:SKSpriteNode!
    var numberOfTimesHelaHit:Int!
    
    var touchType:TouchType!
    
    override func sceneDidLoad() {
        
        //Reset scores to 0
        self.numberOfTimesThorHit = 0
        self.numberOfTimesHelaHit = 0
        
        self.touchType = TouchType.TAP //default value
    
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
        hela = SKSpriteNode(imageNamed: "hela")
        hela.xScale = 0.2
        hela.yScale = 0.2
        hela.position = CGPoint(x: size.width*0.9, y: size.height*0.5)
        
        self.configureHelaPhysics()
        
        self.addChild(hela)
    }
    
    
    func addSpike() {
        let spike = SKSpriteNode(imageNamed: "spike")
        spike.xScale = 0.07
        spike.yScale = 0.07
        
        let actualY = random(min:spike.size.height/2, max:size.height - spike.size.height/2)
        
        spike.position = CGPoint(x: size.width + spike.size.width/2, y: actualY)
        
        addChild(spike)
        
        configureSpikePhysics(spike: spike)
        
        let actualDuration = random(min:CGFloat(3.0), max: CGFloat(5.0))
        
        let actionMove = SKAction.move(to: CGPoint(x:-spike.size.width/2, y:actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        spike.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func throwHammer() {
        let hammer = SKSpriteNode(imageNamed: "hammer")
        hammer.xScale = 0.25
        hammer.yScale = 0.25
        
        //TODO: offset hammer X position
        hammer.position = CGPoint(x: self.thorPosition.x + 75, y: self.thorPosition.y + 25)
        
        addChild(hammer)
        
        configureHammerPhysics(hammer: hammer)
        
        let actualDuration = CGFloat(3.0)
        
        let actionMove = SKAction.move(to: CGPoint(x: size.width, y: self.thorPosition.y), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        hammer.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
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
    

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        print("MADE CONTACT")

        
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
        
        guard firstBody.node != nil else { return }
        (firstBody.node as! SKSpriteNode).removeFromParent()
        //TODO: Logic for hammer & spikes scores:
        //-Thor hit, -1 life (or game over?!)
        //-Hela hit, +1 (win @ XXX)
        if secondBody.categoryBitMask == PhysicsCategory.Thor
        {
            print("OUCH! Thor was hit")
        } else if (secondBody.categoryBitMask == PhysicsCategory.Hela)
        {
            print("DONG! You hit Hela")
        }

    }

    
    func moveThor(toNewYPosition: CGFloat) {
        let newThorPosition = CGPoint(x: self.thorPosition.x, y: toNewYPosition)
        self.thorPosition = newThorPosition
        self.thor.position = self.thorPosition //this is faster/more-instant than an actual move!
//        let moveThorUpOrDown = SKAction.move(to: newThorPosition, duration: 0.0001)
//        self.thor.run(moveThorUpOrDown)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        self.touchType = TouchType.TAP
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.touchType = TouchType.SWIPE
        self.moveThor(toNewYPosition: pos.y)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if self.touchType == TouchType.TAP {
            self.throwHammer()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
    func processSwipRight() {
        //TODO: fire ze missile!
        //probably basically the opposite of the asteroid/projectiles
    }
    
    func processSwipeUp() {
        //TODO: move character up or jump
        //probably an action (what brings him back to ground? Gravity?
    }
    
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
