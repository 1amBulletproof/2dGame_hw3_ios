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
    static let Asteroid : UInt32 = 0b1 //1
    static let Shield : UInt32 = 0b10 //2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime:TimeInterval!
    
    var ship:SKSpriteNode!
    var shield:SKSpriteNode!
    
    var updateDeltaX:Float!
    var updateDeltaY:Float!
    var lastPosition:CGPoint?
    
    override func sceneDidLoad() {
        
        self.updateDeltaX = 0;
        self.updateDeltaY = 0;

        
        self.addShip()
        self.addShield()
        

        
        run(SKAction.repeatForever(SKAction.sequence(
            [
                SKAction.run(addAsteroid),
                SKAction.wait(forDuration: 1.0)
            ])))
        
        addPhysics()
    }
    
    func addShip() {
        ship = SKSpriteNode(imageNamed: "enterprise")
        ship.xScale = 0.5
        ship.yScale = 0.5
        ship.position = CGPoint(x: size.width*0.22, y: size.height*0.5)
        
        self.addChild(ship)
    }
    
    func addShield() {
        shield = SKSpriteNode(imageNamed: "shield")
        shield.xScale = 0.5
        shield.yScale = 0.5
        shield.position = CGPoint(x: size.width*0.30, y: size.height*0.5)
        
        configureShieldPhysics()
        
        self.addChild(shield)
    }
    
    func addAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.xScale = 0.5
        asteroid.yScale = 0.5
        
        let actualY = random(min:asteroid.size.height/2, max:size.height - asteroid.size.height/2)
        
        asteroid.position = CGPoint(x: size.width + asteroid.size.width/2, y: actualY)
        
        addChild(asteroid)
        
        configureAsteroidPhysics(asteroid: asteroid)
        
        let actualDuration = random(min:CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x:-asteroid.size.width/2, y:actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func configureShieldPhysics() {
        shield.physicsBody = SKPhysicsBody(circleOfRadius: shield.size.width/2)
        shield.physicsBody?.isDynamic = false
        shield.physicsBody?.categoryBitMask = PhysicsCategory.Shield
        shield.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid
        shield.physicsBody?.collisionBitMask = PhysicsCategory.None
        shield.physicsBody?.usesPreciseCollisionDetection = false
    }
    
    func configureAsteroidPhysics(asteroid:SKSpriteNode) {
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Shield
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        asteroid.physicsBody?.usesPreciseCollisionDetection = false
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
