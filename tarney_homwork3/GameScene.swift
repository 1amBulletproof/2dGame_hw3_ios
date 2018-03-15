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
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime:TimeInterval!
    
    var thor:SKSpriteNode!
    
    var updateDeltaX:Float!
    var updateDeltaY:Float!
    var lastPosition:CGPoint?
    
    override func sceneDidLoad() {
        
        self.updateDeltaX = 0;
        self.updateDeltaY = 0;

        self.addThor()
        
        //TODO: add Hela (even if she's just static! tho more fun to shoot hammers at her)
        
        run(SKAction.repeatForever(SKAction.sequence(
            [
                SKAction.run(addSpike),
                SKAction.wait(forDuration: 1.0)
            ])))
        
        addPhysics()
    }
    
    func addThor() {
        thor = SKSpriteNode(imageNamed: "thor")
        thor.xScale = 0.35
        thor.yScale = 0.35
        thor.position = CGPoint(x: size.width*0.2, y: size.height*0.5)
        
        self.addChild(thor)
    }
    
    func addSpike() {
        let spike = SKSpriteNode(imageNamed: "spike")
        spike.xScale = 0.1
        spike.yScale = 0.1
        
        let actualY = random(min:spike.size.height/2, max:size.height - spike.size.height/2)
        
        spike.position = CGPoint(x: size.width + spike.size.width/2, y: actualY)
        
        addChild(spike)
        
        configureSpikePhysics(spike: spike)
        
        let actualDuration = random(min:CGFloat(3.0), max: CGFloat(5.0))
        
        let actionMove = SKAction.move(to: CGPoint(x:-spike.size.width/2, y:actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        spike.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func configureThorPhysics() {
        thor.physicsBody = SKPhysicsBody(circleOfRadius: thor.size.width/2)
        thor.physicsBody?.isDynamic = false
        thor.physicsBody?.categoryBitMask = PhysicsCategory.Thor
        thor.physicsBody?.contactTestBitMask = PhysicsCategory.Spike
        thor.physicsBody?.collisionBitMask = PhysicsCategory.None
        thor.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    func configureSpikePhysics(spike:SKSpriteNode) {
        spike.physicsBody = SKPhysicsBody(rectangleOf: spike.size)
        spike.physicsBody?.isDynamic = true
        spike.physicsBody?.categoryBitMask = PhysicsCategory.Spike
        spike.physicsBody?.contactTestBitMask = PhysicsCategory.Thor
        //TODO: add contact bit mask item for collisions with hammer?!
        spike.physicsBody?.collisionBitMask = PhysicsCategory.None
        spike.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    func addPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
        }
        else
        {
            firstBody = contact.bodyB
        }
        
        guard firstBody.node != nil else { return }
        (firstBody.node as! SKSpriteNode).removeFromParent()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("touch DOWN at \(pos)")
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        print("touch MOVED at \(pos)")
        //if lastPosition == nil { lastPosition = pos } else {
        //updateDeltaX += lastLocation - pos
        //updateDeltaX += lastLocation - pos
        //}
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        print("touch UP at \(pos)")
        self.lastPosition = nil
        //if updateDeltaX > XXX { processSwipeRight() }
        //else if updateDeltaY > XXX { processSwipeUp() }
        
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
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        self.lastUpdateTime = currentTime
    }
}
