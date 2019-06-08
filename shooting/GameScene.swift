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

class GameScene: SKScene {
    
    var myShip = SKSpriteNode()
    var enemyRate: CGFloat = 0.0
    var enemySize = CGSize(width: 0.0, height: 0.0)
    var timer: Timer?
    let motionMgr = CMMotionManager()
    var accelarationX: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        var sizeRate: CGFloat = 0.0
        var myShipSize = CGSize(width: 0.0, height: 0.0)
        let offsetY = frame.height / 20
        
        self.myShip = SKSpriteNode(imageNamed: "myShip")
        sizeRate = (frame.width / 5) / self.myShip.size.width
        myShipSize = CGSize(width: self.myShip.size.width * sizeRate,
                            height: self.myShip.size.height * sizeRate)
        self.myShip.scale(to: myShipSize)
        self.myShip.position = CGPoint(x: 0,
                                       y: (-frame.height / 2) + offsetY + myShipSize.height / 2)
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
        let pos = self.myShip.position.x + self.accelarationX * 50
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
        addChild(missile)
        let move = SKAction.moveTo(y: frame.height + missile.size.height, duration: 0.5)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([move, remove]))
    }
    
}
