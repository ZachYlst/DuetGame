//
//  GameScene.swift
//  RandomGame
//
//  Created by Ylst, Zachary on 3/27/18.
//  Copyright © 2018 CTEC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    var rotatePoint = SKSpriteNode()
    var blueBall = SKSpriteNode()
    var redBall = SKSpriteNode()
    
    var square = SKSpriteNode()
    var rectangle = SKSpriteNode()
    var spinningRectangle = SKSpriteNode()
    
    var isTouching: Bool = false
    var rotationDirection: String = ""
    
    let leftLane = UIBezierPath()
    let middleLane = UIBezierPath()
    let rightLane = UIBezierPath()
    var obstacleLeftPosition: CGPoint = CGPoint(x: -142.5, y: 642)
    var obstacleMiddlePosition: CGPoint = CGPoint(x: 0, y: 642)
    var obstacleRightPosition: CGPoint = CGPoint(x: 142.5, y: 642)
    
    override func didMove(to view: SKView)
    {
        rotatePoint = self.childNode(withName: "rotatePoint") as! SKSpriteNode
        blueBall = rotatePoint.childNode(withName: "blueBall") as! SKSpriteNode
        redBall = rotatePoint.childNode(withName: "redBall") as! SKSpriteNode
        
        let redEmitter = SKEmitterNode(fileNamed: "RedEmitter.sks")!
        redEmitter.particleSize = CGSize(width: 90.0, height: 90.0)
        redEmitter.targetNode = scene
        redBall.addChild(redEmitter)
        let blueEmitter = SKEmitterNode(fileNamed: "BlueEmitter.sks")!
        blueEmitter.particleSize = CGSize(width: 90.0, height: 90.0)
        blueEmitter.targetNode = scene
        blueBall.addChild(blueEmitter)
        
        
        square = self.childNode(withName: "square") as! SKSpriteNode
        square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: square.size.width, height: square.size.height))
        square.physicsBody?.affectedByGravity = false
        square.physicsBody?.linearDamping = 0.0
        square.physicsBody?.allowsRotation = false
        square.physicsBody?.friction = 0.0
        square.isHidden = true
        rectangle = self.childNode(withName: "rectangle") as! SKSpriteNode
        rectangle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rectangle.size.width, height: rectangle.size.height))
        rectangle.physicsBody?.affectedByGravity = false
        rectangle.physicsBody?.linearDamping = 0.0
        rectangle.physicsBody?.allowsRotation = false
        rectangle.physicsBody?.friction = 0.0
        rectangle.isHidden = true
        spinningRectangle = self.childNode(withName: "spinningRectangle") as! SKSpriteNode
        spinningRectangle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spinningRectangle.size.width, height: spinningRectangle.size.height))
        spinningRectangle.physicsBody?.affectedByGravity = false
        spinningRectangle.physicsBody?.linearDamping = 0.0
        spinningRectangle.physicsBody?.allowsRotation = false
        spinningRectangle.physicsBody?.friction = 0.0
        spinningRectangle.isHidden = true
        
        rotatePoint.position = CGPoint(x: 0.0, y: -280.0)
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        
        drawLanes()
        drawRotatePath().stroke()
    }
    
    func drawLanes()
    {
        leftLane.move(to: obstacleLeftPosition)
        leftLane.addLine(to: CGPoint(x: obstacleLeftPosition.x, y: -640))
        
        middleLane.move(to: obstacleMiddlePosition)
        middleLane.move(to: CGPoint(x: obstacleMiddlePosition.x, y: -640))
        
        rightLane.move(to: obstacleRightPosition)
        rightLane.addLine(to: CGPoint(x: obstacleRightPosition.x, y: -640))
    }
    
    // CG_CONTEXT_SHOW_BACKTRACE Error
    func drawRotatePath() -> UIBezierPath
    {
        let rotatePath = UIBezierPath()
        
        UIColor.white.setStroke()
        
        rotatePath.move(to: CGPoint(x: 140.0, y: 0.917))
        rotatePath.addArc(withCenter: CGPoint(x: 0, y: 0.917),
                          radius: 140.0,
                          startAngle: 0.0,
                          endAngle: CGFloat(Double.pi * 2),
                          clockwise: true)
        
        return rotatePath
    }
    
    func rotateNode(node: SKNode, clockwise: Bool, speed: CGFloat)
    {
        switch clockwise
        {
        case true:
            node.zRotation = node.zRotation - speed
        default:
            node.zRotation = node.zRotation + speed
        }
    }
    
    // RESULTS IN A CRASH
    func spawnObstacle()
    {
        let obstacles: [SKSpriteNode] = [square, rectangle, spinningRectangle]
        let obstaclePosition: [CGPoint] = [obstacleLeftPosition, obstacleRightPosition]
        let randomObstacle = Int(arc4random_uniform(UInt32(obstacles.count)))
        let randomObstaclePosition = Int(arc4random_uniform(UInt32(obstaclePosition.count)))

        let followLeftLane = SKAction.follow((leftLane.cgPath), duration: 5.0)
        let followMiddleLane = SKAction.follow((middleLane.cgPath), duration: 5.0)
        let followRightLane = SKAction.follow((rightLane.cgPath), duration: 5.0)

        if (square.isHidden == true && rectangle.isHidden == true && spinningRectangle.isHidden == true)
        {
            let chosenObstacle = obstacles[randomObstacle]
            chosenObstacle.isHidden = false

            switch chosenObstacle
            {
            case spinningRectangle:
                chosenObstacle.position = obstacleMiddlePosition
            default:
                chosenObstacle.position = obstaclePosition[randomObstaclePosition]
            }

            switch chosenObstacle.position
            {
            case obstacleLeftPosition:
                chosenObstacle.run(followLeftLane)
                chosenObstacle.isHidden = true
            case obstacleMiddlePosition:
                chosenObstacle.run(followMiddleLane)
                chosenObstacle.isHidden = true
            case obstacleRightPosition:
                chosenObstacle.run(followRightLane)
                chosenObstacle.isHidden = true
            default:
                break
            }
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        isTouching = true
        
        for touch in touches
        {
            let location = touch.location(in: self)
            
            if (location.x < frame.midX)
            {
                rotationDirection = "COUNTERCLOCKWISE"
            }
            else if (location.x > frame.midX)
            {
                rotationDirection = "CLOCKWISE"
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        isTouching = false
    }
    
    override public func update(_ currentTime: TimeInterval)
    {
        spawnObstacle()
        
        if (isTouching)
        {
            if (rotationDirection == "CLOCKWISE")
            {
                rotateNode(node: rotatePoint, clockwise: true, speed: 0.1)
            }
            else if (rotationDirection == "COUNTERCLOCKWISE")
            {
                rotateNode(node: rotatePoint, clockwise: false, speed: 0.1)
            }
        }
        
        let spinDirection: [Bool] = [true, false]
        let randomSpinDirection = Int(arc4random_uniform(UInt32(spinDirection.count)))
        
        if (spinningRectangle.isHidden == false)
        {
            rotateNode(node: spinningRectangle,
                       clockwise: spinDirection[randomSpinDirection],
                       speed: 0.1)
        }
    }
}
