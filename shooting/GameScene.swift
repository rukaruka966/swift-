//
//  GameScene.swift
//  shooting
//
//  Created by Akihiro Hashimoto on 2019/06/02.
//  Copyright © 2019 Akihiro Hashimoto. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var myShip = SKSpriteNode()
    var enemyRate: CGFloat = 0.0
    var enemySize = CGSize(width: 0.0, height: 0.0)
    var timer: Timer?
    let motionMgr = CMMotionManager()
    var accelarationX: CGFloat = 0.0
    let myShipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let enemyCategory: UInt32 = 0b0100
    var lifeLabelNode = SKLabelNode()
    var scoreLabelNode = SKLabelNode()
    var vc: GameViewController!
    
    var life: Int = 0 {
        didSet {
            self.lifeLabelNode.text = "LIFE: \(life)"
        }
    }
    
    var score: Int = 0 {
        didSet {
            self.scoreLabelNode.text = "SCORE: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        var sizeRate: CGFloat = 0.0
        var myShipSize = CGSize(width: 0.0, height: 0.0)
        let offsetY = frame.height / 20
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.life = 3
        self.lifeLabelNode.fontName = "HelveticaNeue-Bold"
        self.lifeLabelNode.fontColor = UIColor.white
        self.lifeLabelNode.fontSize = 30
        self.lifeLabelNode.position = CGPoint(
            x: frame.width / 2 - (self.lifeLabelNode.frame.width + 20),
            y: frame.height / 2 - self.lifeLabelNode.frame.height * 3
        )
        addChild(self.lifeLabelNode)
        
        self.score = 0
        self.scoreLabelNode.fontName = "HelveticaNeue-Bold"
        self.scoreLabelNode.fontColor = UIColor.white
        self.scoreLabelNode.fontSize = 30
        self.scoreLabelNode.position = CGPoint(
            x: -frame.width / 2 + self.scoreLabelNode.frame.width,
            y: frame.height / 2 - self.scoreLabelNode.frame.height * 3
        )
        addChild(self.scoreLabelNode)
        
        self.myShip = SKSpriteNode(imageNamed: "myShip")
        sizeRate = (frame.width / 5) / self.myShip.size.width
        myShipSize = CGSize(width: self.myShip.size.width * sizeRate,
                            height: self.myShip.size.height * sizeRate)
        self.myShip.scale(to: myShipSize)
        self.myShip.position = CGPoint(x: 0,
                                       y: (-frame.height / 2) + offsetY + myShipSize.height / 2)
        self.myShip.physicsBody = SKPhysicsBody(rectangleOf: self.myShip.size)
        self.myShip.physicsBody?.categoryBitMask = self.myShipCategory
        self.myShip.physicsBody?.collisionBitMask = self.enemyCategory
        self.myShip.physicsBody?.contactTestBitMask = self.enemyCategory
        self.myShip.physicsBody?.isDynamic = true
        addChild(self.myShip)
        
        let tempEnemy = SKSpriteNode(imageNamed: "enemy1")
        enemyRate = (frame.width / 10) / tempEnemy.size.width
        enemySize = CGSize(width: tempEnemy.size.width * enemyRate,
                           height: tempEnemy.size.height * enemyRate)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                     repeats: true,
                                     block: { _ in self.moveEnemy()})
        
        motionMgr.accelerometerUpdateInterval = 0.05
        motionMgr.startAccelerometerUpdates(to: OperationQueue.current!) {
            (val, _) in guard let unwrapVal = val else {return}
            let acc = unwrapVal.acceleration
            self.accelarationX = CGFloat(acc.x)
//            print(acc.x)
        }
    }
    
    override func didSimulatePhysics() {
        let pos = self.myShip.position.x + self.accelarationX * 30
        if pos > frame.width / 2 - self.myShip.frame.width / 2 {return}
        if pos < -frame.width / 2 + self.myShip.frame.width / 2 {return}
        self.myShip.position.x = pos
    }
    
    func moveEnemy() {
        let enemyNames = ["enemy1", "enemy2", "enemy3"]
        let idx = Int.random(in: 0 ..< enemyNames.count)
        let selectedEnemy = enemyNames[idx]
        let enemy = SKSpriteNode(imageNamed: selectedEnemy)
        
        enemy.scale(to: enemySize)
        let xPod = (frame.width / CGFloat.random(in: 1...5)) - frame.width / 2
        enemy.position = CGPoint(x: xPod, y: frame.height / 2)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.isDynamic = true
        addChild(enemy)
        
        let move = SKAction.moveTo(y: -frame.height / 2, duration: 2.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let missile = SKSpriteNode(imageNamed: "missile")
        let missilePos = CGPoint(x: self.myShip.position.x,
                                 y: self.myShip.position.y + (self.myShip.size.height / 2) - (missile.size.height / 2))
        missile.position = missilePos
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.categoryBitMask = self.missileCategory
        missile.physicsBody?.collisionBitMask = self.enemyCategory
        missile.physicsBody?.contactTestBitMask = self.enemyCategory
        missile.physicsBody?.isDynamic = true
        addChild(missile)
        let move = SKAction.moveTo(y: frame.height + missile.size.height, duration: 0.5)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([move, remove]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contact.bodyA.node?.removeFromParent()
        contact.bodyB.node?.removeFromParent()
        let explosion = SKEmitterNode(fileNamed: "explosion")
        explosion?.position = contact.bodyA.node?.position ?? CGPoint(x: 0, y: 0)
        addChild(explosion!)
        self.run(SKAction.wait(forDuration: 0.5)) {
            explosion?.removeFromParent()
        }
        
        if contact.bodyA.categoryBitMask == missileCategory ||
            contact.bodyB.categoryBitMask == missileCategory {
            self.score += 10
        }
        
        if contact.bodyA.categoryBitMask == myShipCategory ||
            contact.bodyB.categoryBitMask == myShipCategory {
            self.life -= 1
            self.run(SKAction.wait(forDuration: 1)) {
                self.restart()
            }
        }
        
    }
    
    func restart() {
        if self.life <= 0 {
            vc.dismiss(animated: true, completion: nil)
            
        }
        addChild(self.myShip)
    }
    
}
