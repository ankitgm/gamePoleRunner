import SpriteKit
import GameplayKit
 var scorescore:Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate  {
  
   
    let StackHeight:CGFloat = 400.0
    let StackMaxWidth:CGFloat = 300.0
    let StackMinWidth:CGFloat = 100.0
    let gravity:CGFloat = -100.0
    let StackGapMinWidth:Int = 80
    let runnerSpeed:CGFloat = 760
    let StoreScoreName = "com.ankit.PoleRunner"
   
    var isBegin = false
    var isEnd = false
    var leftStack:SKSpriteNode?
    var rightStack:SKSpriteNode?
    var playerlife : SKSpriteNode = SKSpriteNode()
    var lifeLabel : SKLabelNode = SKLabelNode()
    var nextLeftStartX:CGFloat = 0
    var poleHeight:CGFloat = 0
    struct GAP {
        static let XGAP:CGFloat = 20
        static let YGAP:CGFloat = 4
    }
    var gameOver1 = false {
        willSet {
            if (newValue) {
                checkHighScoreAndStore()
                let gameOverLayer = childNode(withName: PoleRunnerChild.GameOverLayer.rawValue) as SKNode?
                gameOverLayer?.run(SKAction.moveDistance(CGVector(dx: 0, dy: 100), fadeInWithDuration: 0.2))
            }
        }
    }
    override func didMove(to view: SKView) {
        start()
    }
    func touchDown(atPoint pos : CGPoint) {
    }
    func touchMoved(toPoint pos : CGPoint) {
    }
    func touchUp(atPoint pos : CGPoint) {
    }
    var score:Int = 0 {
        willSet {
            let scoreBand = childNode(withName: PoleRunnerChild.Score.rawValue) as? SKLabelNode
            scoreBand?.text = "\(newValue)"
            scoreBand?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            if (newValue == 1) {
                let tip = childNode(withName: PoleRunnerChild.Tip.rawValue) as? SKLabelNode
                tip?.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
            }
        }
    }
    lazy var playAbleRect:CGRect = {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let maxAspectRatioWidth = self.size.height / maxAspectRatio
        let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
        return CGRect(x: playableMargin, y: 0, width: maxAspectRatioWidth, height: self.size.height)
    }()
    lazy var walkAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 0...3 {
            let texture = SKTexture(imageNamed: "player\(i + 1).png")
            textures.append(texture)
        }
        let action = SKAction.animate(with: textures, timePerFrame: 0.15, resize: true, restore: true)
        return SKAction.repeatForever(action)
    }()
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver1 else {
            let gameOverLayer = childNode(withName: PoleRunnerChild.GameOverLayer.rawValue) as SKNode?
            let location = touches.first?.location(in: gameOverLayer!)
            let retry = gameOverLayer!.atPoint(location!)
            if (retry.name == PoleRunnerChild.RetryButton.rawValue) {
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_retry_down"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    self.restart()
                    //self.dismiss()
                })
            }
            
            
            if (retry.name == PoleRunnerChild.ExitButton.rawValue) {
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "exitbutton"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    

                    //self.restart()
                    self.dismiss()
                })
            }
            
            
            
            
            
            
            
            
            return
        }
        if !isBegin && !isEnd {
            isBegin = true
            let pole = loadpole()
            let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
            let action = SKAction.resize(toHeight: CGFloat(DefinedScreenHeight - StackHeight), duration: 1.5)
            pole.run(action, withKey:PoleRunnerKey.poleGrow.rawValue)
            let scaleAction = SKAction.sequence([SKAction.scaleY(to: 0.9, duration: 0.05), SKAction.scaleY(to: 1, duration: 0.05)])
            let loopAction = SKAction.group([SKAction.playSoundFileNamed(PoleRunnerAudio.poleGrowAudio.rawValue, waitForCompletion: true)])
            pole.run(SKAction.repeatForever(loopAction), withKey: PoleRunnerKey.poleGrowAudio.rawValue)
            runner.run(SKAction.repeatForever(scaleAction), withKey: PoleRunnerKey.runnerScale.rawValue)
            return
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isBegin && !isEnd {
            isEnd  = true
            let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
            runner.removeAction(forKey: PoleRunnerKey.runnerScale.rawValue)
            runner.run(SKAction.scaleY(to: 1, duration: 0.04))
            let pole = childNode(withName: PoleRunnerChild.pole.rawValue) as! SKSpriteNode
            pole.removeAction(forKey: PoleRunnerKey.poleGrow.rawValue)
            pole.removeAction(forKey: PoleRunnerKey.poleGrowAudio.rawValue)
            pole.run(SKAction.playSoundFileNamed(PoleRunnerAudio.poleGrowOverAudio.rawValue, waitForCompletion: false))
            poleHeight = pole.size.height;
            let action = SKAction.rotate(toAngle: CGFloat(-CGFloat.pi / 2), duration: 0.4, shortestUnitArc: true)
            let playFall = SKAction.playSoundFileNamed(PoleRunnerAudio.poleFallAudio.rawValue, waitForCompletion: false)
            pole.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), action, playFall]), completion: {[unowned self] () -> Void in
                self.runnerGo(self.checkPass())
            })
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    func start() {
        loadBackground()
        loadScoreBackground()
        loadScore()
        loadTip()
        gameOver()
        leftStack = loadStacks(false, startLeftPoint: playAbleRect.origin.x)
        self.removeMidTouch(false, left:true)
        loadRunner()
        let maxGap = Int(playAbleRect.width - StackMaxWidth - (leftStack?.frame.size.width)!)
        let gap = CGFloat(randomInRange(StackGapMinWidth...maxGap))
        rightStack = loadStacks(false, startLeftPoint: nextLeftStartX + gap)
        gameOver1 = false
    }
    func restart() {
        isBegin = false
        isEnd = false
        score = 0
        nextLeftStartX = 0
        removeAllChildren()
        start()
    }
    func dismiss() {
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
        //self.view?.scene
       
        //self.view?.removeFromSuperview()
    
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doaSegue"), object: nil)

        
        
       // self.view?.window?.rootViewController?.performSegue(withIdentifier: "backSeg", sender: nil)
        //self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    fileprivate func checkPass() -> Bool {
        let pole = childNode(withName: PoleRunnerChild.pole.rawValue) as! SKSpriteNode
        let rightPoint = DefinedScreenWidth / 2 + pole.position.x + self.poleHeight
        guard rightPoint < self.nextLeftStartX else {
            if reducelife(){
                return true
            }
            return false
        }
        guard ((leftStack?.frame)!.intersects(pole.frame) && (rightStack?.frame)!.intersects(pole.frame)) else {
            if reducelife(){
                return true
            }
            return false
        }
        self.checkTouchMidStack()
        return true
    }
    fileprivate func checkTouchMidStack() {
        let pole = childNode(withName: PoleRunnerChild.pole.rawValue) as! SKSpriteNode
        let stackMid = rightStack!.childNode(withName: PoleRunnerChild.StackMid.rawValue) as! SKShapeNode
        let newPoint = stackMid.convert(CGPoint(x: -10, y: 10), to: self)
        if ((pole.position.x + self.poleHeight) >= newPoint.x  && (pole.position.x + self.poleHeight) <= newPoint.x + 20) {
            loadPerfect()
            self.run(SKAction.playSoundFileNamed(PoleRunnerAudio.poleTouchMidAudio.rawValue, waitForCompletion: false))
            score += 1
        }
    }
    fileprivate func runnerGo(_ pass:Bool) {
        let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
        guard pass else {
            let pole = childNode(withName: PoleRunnerChild.pole.rawValue) as! SKSpriteNode
            let dis:CGFloat = pole.position.x + self.poleHeight
            let overGap = DefinedScreenWidth / 2 - abs(runner.position.x)
            let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2
            let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / runnerSpeed)))
            runner.run(walkAction, withKey: PoleRunnerKey.Walk.rawValue)
            runner.run(move, completion: {[unowned self] () -> Void in
                pole.run(SKAction.rotate(toAngle: CGFloat(-CGFloat.pi), duration: 0.4))
                runner.physicsBody!.affectedByGravity = true
                runner.run(SKAction.playSoundFileNamed(PoleRunnerAudio.DeadAudio.rawValue, waitForCompletion: false))
                runner.removeAction(forKey: PoleRunnerKey.Walk.rawValue)
                self.run(SKAction.wait(forDuration: 0.5), completion: {[unowned self] () -> Void in
                    self.gameOver1 = true
                })
            })
            return
        }
        let dis:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - runner.size.width / 2 - GAP.XGAP
        let overGap = DefinedScreenWidth / 2 - abs(runner.position.x)
        let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2
        let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / runnerSpeed)))
        runner.run(walkAction, withKey: PoleRunnerKey.Walk.rawValue)
        runner.run(move, completion: { [unowned self]() -> Void in
            self.score += 1
            runner.run(SKAction.playSoundFileNamed(PoleRunnerAudio.VictoryAudio.rawValue, waitForCompletion: false))
            runner.removeAction(forKey: PoleRunnerKey.Walk.rawValue)
            self.moveStackAndCreateNew()
        })
    }
    fileprivate func removeMidTouch(_ animate:Bool, left:Bool) {
        let stack = left ? leftStack : rightStack
        let mid = stack!.childNode(withName: PoleRunnerChild.StackMid.rawValue) as! SKShapeNode
        if (animate) {
            mid.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        }
        else {
            mid.removeFromParent()
        }
    }
    fileprivate func checkHighScoreAndStore() {
        let highScore = UserDefaults.standard.integer(forKey: StoreScoreName)
        if (score > Int(highScore)) {
            showHighScore()
            
            UIGraphicsBeginImageContext((view?.frame.size)!)
            view?.layer.render(in: UIGraphicsGetCurrentContext()!)
            let sourceImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            //UIImageWriteToSavedPhotosAlbum(sourceImage!, nil, nil, nil)
            UserDefaults.standard.set(sourceImage, forKey: "StoreImageName")
   
            UserDefaults.standard.set(score, forKey: StoreScoreName)
            UserDefaults.standard.set(score, forKey: "yoyoget")
        UserDefaults.standard.synchronize()
            let x = UserDefaults.standard.integer(forKey: "yoyoget")
            print("Your score is")
            print(x)
            //scorescore = score
           // print(scorescore)
        }
    }
    fileprivate func showHighScore() {
        self.run(SKAction.playSoundFileNamed(PoleRunnerAudio.HighScoreAudio.rawValue, waitForCompletion: false))
        let wait = SKAction.wait(forDuration: 0.4)
        let grow = SKAction.scale(to: 1.5, duration: 0.4)
        grow.timingMode = .easeInEaseOut
        let explosion = starEmitterActionAtPosition(CGPoint(x: 0, y: 300))
        let shrink = SKAction.scale(to: 1, duration: 0.2)
        let idleGrow = SKAction.scale(to: 1.2, duration: 0.4)
        idleGrow.timingMode = .easeInEaseOut
        let idleShrink = SKAction.scale(to: 1, duration: 0.4)
        let pulsate = SKAction.repeatForever(SKAction.sequence([idleGrow, idleShrink]))
        let gameOverLayer = childNode(withName: PoleRunnerChild.GameOverLayer.rawValue) as SKNode?
        let highScoreLabel = gameOverLayer?.childNode(withName: PoleRunnerChild.HighScore.rawValue) as SKNode?
        highScoreLabel?.run(SKAction.sequence([wait, explosion, grow, shrink]), completion: { () -> Void in
            highScoreLabel?.run(pulsate)
        })
    }
    fileprivate func moveStackAndCreateNew() {
        let action = SKAction.move(by: CGVector(dx: -nextLeftStartX + (rightStack?.frame.size.width)! + playAbleRect.origin.x - 2, dy: 0), duration: 0.3)
        rightStack?.run(action)
        self.removeMidTouch(true, left:false)
        let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
        let pole = childNode(withName: PoleRunnerChild.pole.rawValue) as! SKSpriteNode
        runner.run(action)
        pole.run(SKAction.group([SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 0.3)]), completion: { () -> Void in
            pole.removeFromParent()
        })
        leftStack?.run(SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), completion: {[unowned self] () -> Void in
            self.leftStack?.removeFromParent()
            let maxGap = Int(self.playAbleRect.width - (self.rightStack?.frame.size.width)! - self.StackMaxWidth)
            let gap = CGFloat(randomInRange(self.StackGapMinWidth...maxGap))
            self.leftStack = self.rightStack
            self.rightStack = self.loadStacks(true, startLeftPoint:self.playAbleRect.origin.x + (self.rightStack?.frame.size.width)! + gap)
        })
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - load node
private extension GameScene {
    func loadBackground() {
       
      guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
           let texture = SKTexture(image: UIImage(named: "backImage1.jpg")!)
           let node = SKSpriteNode(texture: texture)
           node.size = self.size//texture.size()
            node.zPosition = PoleRunnerZposition.backgroundZ.rawValue
            self.physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
            addChild(node)
            return
        }
    }
    func reducelife() -> Bool{
        let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
        let x =  UserDefaults.standard.bool(forKey: "myName")
        
        if x == true
        {runner.run(SKAction.playSoundFileNamed(PoleRunnerAudio.DeadAudio.rawValue, waitForCompletion: false))
        }
        var lifeLeft = runner.userData?["life"]! as! Int
        if lifeLeft > 0
        {
            lifeLeft -= 1
            runner.userData?.setValue(lifeLeft, forKey: "life")
            lifeLabel.text = "x "+String(lifeLeft)
            let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            label.name = PoleRunnerChild.Tip.rawValue
            label.text = "life -1"
            label.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 550)
            label.fontColor = SKColor.black
            label.fontSize = 65
            label.zPosition = PoleRunnerZposition.tipZposition.rawValue
            label.horizontalAlignmentMode = .center
            addChild(label)
            let waitAction = SKAction.wait(forDuration: 1.2)
            let removeAction = SKAction.removeFromParent()
            label.run(SKAction.sequence([waitAction,removeAction]))
            return true
        }
        return false
    }
    func loadScore() {
        let scoreBand = SKLabelNode(fontNamed: "Arial")
        scoreBand.name = PoleRunnerChild.Score.rawValue
        scoreBand.text = "0"
        scoreBand.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 200)
        scoreBand.fontColor = SKColor.white
        scoreBand.fontSize = 100
        scoreBand.zPosition = PoleRunnerZposition.scoreZposition.rawValue
        scoreBand.horizontalAlignmentMode = .center
        addChild(scoreBand)
    }
    func loadScoreBackground() {
        let back = SKShapeNode(rect: CGRect(x: 0-120, y: 1024-200-30, width: 240, height: 140), cornerRadius: 20)
        back.zPosition = PoleRunnerZposition.scoreBackgroundZ.rawValue
        back.fillColor = SKColor.black.withAlphaComponent(0.3)
        back.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(back)
    }
    func loadRunner() {
        let runner = SKSpriteNode(imageNamed: "player1")
        runner.name = PoleRunnerChild.runner.rawValue
        let x:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - runner.size.width / 2 - GAP.XGAP
        let y:CGFloat = StackHeight + runner.size.height / 2 - DefinedScreenHeight / 2 - GAP.YGAP
        runner.position = CGPoint(x: x, y: y)
        runner.zPosition = PoleRunnerZposition.runnerZposition.rawValue
        runner.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 18))
        runner.physicsBody?.affectedByGravity = false
        runner.physicsBody?.allowsRotation = false
        runner.userData = NSMutableDictionary()
        runner.userData?.setValue(3, forKey: "life")
        addChild(runner)
        loadLife()
    }
    func loadTip() {
        let tip = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        tip.name = PoleRunnerChild.Tip.rawValue
        tip.text = "The Game"
        tip.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 350)
        tip.fontColor = SKColor.black
        tip.fontSize = 52
        tip.zPosition = PoleRunnerZposition.tipZposition.rawValue
        tip.horizontalAlignmentMode = .center
        addChild(tip)
    }
    func loadPerfect() {
        defer {
            let perfect = childNode(withName: PoleRunnerChild.Perfect.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.fadeAlpha(to: 0, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }
        guard let _ = childNode(withName: PoleRunnerChild.Perfect.rawValue) as! SKLabelNode? else {
            let perfect = SKLabelNode(fontNamed: "Arial")
            perfect.text = "Perfect +1 Life +1"
            perfect.name = PoleRunnerChild.Perfect.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.black
            perfect.fontSize = 50
            perfect.zPosition = PoleRunnerZposition.perfectZposition.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
            var lifeLeft:Int = runner.userData?["life"]! as! Int
            lifeLeft += 1
            runner.userData?.setValue(lifeLeft, forKey: "life")
            lifeLabel.text = "x "+String(lifeLeft)
            addChild(perfect)
            return
        }
    }
    func loadpole() -> SKSpriteNode {
        let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
        let pole = SKSpriteNode(color: .brown, size: CGSize(width: 12, height: 1))
        pole.zPosition = PoleRunnerZposition.poleZ.rawValue
        pole.name = PoleRunnerChild.pole.rawValue
        pole.anchorPoint = CGPoint(x: 0.5, y: 0);
        pole.position = CGPoint(x: runner.position.x + runner.size.width / 2 + 18, y: runner.position.y - runner.size.height / 2)
        addChild(pole)
        return pole
    }
    //platform
    func loadStacks(_ animate: Bool, startLeftPoint: CGFloat) -> SKSpriteNode {
        let max:Int = Int(StackMaxWidth / 10)
        let min:Int = Int(StackMinWidth / 10)
        let width:CGFloat = CGFloat(randomInRange(min...max) * 10)
        let height:CGFloat = StackHeight
        //let stack = SKShapeNode(rectOf: CGSize(width: width, height: height))
        let stack = SKSpriteNode(imageNamed: "stack1.png")
        stack.size = CGSize(width: width, height: height)
        // stack.fillColor = .black
        // stack.strokeColor = .black
        stack.zPosition = PoleRunnerZposition.stackZ.rawValue
        stack.name = PoleRunnerChild.Stack.rawValue
        if (animate) {
            stack.position = CGPoint(x: DefinedScreenWidth / 2, y: -DefinedScreenHeight / 2 + height / 2)
            stack.run(SKAction.moveTo(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
                self.isBegin = false
                self.isEnd = false
            })
        }
        else {
            stack.position = CGPoint(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, y: -DefinedScreenHeight / 2 + height / 2)
        }
        addChild(stack)
        let mid = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        mid.fillColor = SKColor.green
        mid.strokeColor = SKColor.green
        mid.zPosition = PoleRunnerZposition.stackMidZ.rawValue
        mid.name = PoleRunnerChild.StackMid.rawValue
        //mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        stack.addChild(mid)
        nextLeftStartX = width + startLeftPoint
        return stack
    }
    func loadLife(){
        let playerlife = SKSpriteNode(imageNamed: "player1")
        playerlife.name = PoleRunnerChild.LifeLeft.rawValue
        //tip.text = "The Game"
        let runner = childNode(withName: PoleRunnerChild.runner.rawValue) as! SKSpriteNode
        let lifeLeft:String = String(runner.userData?["life"]! as! Int)
        playerlife.position = CGPoint(x: -50, y: DefinedScreenHeight / 2 - 400)
        playerlife.zPosition = PoleRunnerZposition.lifeLeft.rawValue
        //tip.horizontalAlignmentMode = .center
        lifeLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        lifeLabel.text = "x "+lifeLeft
        lifeLabel.fontColor = .black
        lifeLabel.fontSize = 60
        lifeLabel.position =  CGPoint(x: 100, y: -20)
        lifeLabel.horizontalAlignmentMode = .center
        playerlife.addChild(lifeLabel)
        addChild(playerlife)
    }
    func gameOver() {
        let node = SKNode()
        node.alpha = 0
        node.name = PoleRunnerChild.GameOverLayer.rawValue
        node.zPosition = PoleRunnerZposition.gameOverZ.rawValue
        addChild(node)
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "Game Over"
        label.fontColor = SKColor.red
        label.fontSize = 150
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        let retry = SKSpriteNode(imageNamed: "button_retry_up")
        retry.name = PoleRunnerChild.RetryButton.rawValue
        retry.position = CGPoint(x: 0, y: -200)
        node.addChild(retry)
        let exit = SKSpriteNode(imageNamed: "exitbutton")
        exit.name = PoleRunnerChild.ExitButton.rawValue
        exit.position = CGPoint(x: 0, y: -400)
        node.addChild(exit)
        let highScore = SKLabelNode(fontNamed: "AmericanTypewriter")
        highScore.text = "Highscore!"
        highScore.fontColor = UIColor.white
        highScore.fontSize = 50
        highScore.name = PoleRunnerChild.HighScore.rawValue
        highScore.position = CGPoint(x: 0, y: 300)
        highScore.horizontalAlignmentMode = .center
        highScore.setScale(0)
        node.addChild(highScore)
    }
    func starEmitterActionAtPosition(_ position: CGPoint) -> SKAction {
        let emitter = SKEmitterNode(fileNamed: "StarExplosion")
        emitter?.position = position
        emitter?.zPosition = PoleRunnerZposition.emitterZ.rawValue
        emitter?.alpha = 0.6
        addChild((emitter)!)
        let wait = SKAction.wait(forDuration: 0.15)
        return SKAction.run({ () -> Void in
            emitter?.run(wait)
        })
    }
}
