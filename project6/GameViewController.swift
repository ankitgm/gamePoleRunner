
import UIKit
import SpriteKit
import FBSDKLoginKit
import FBSDKCoreKit
import GameplayKit
import AVFoundation
import Social

class GameViewController: UIViewController {
    var scorehighhigh:Int = 0
   // gameScene.viewController = self
    var musicPlayer:AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        //scorehighhigh = scorescore
        // Load the SKScene from 'GameScene.sks'
        let scene = GameScene(size:CGSize(width: DefinedScreenWidth, height: DefinedScreenHeight))
        
//        self.view = SKView()
//        let skView = view as! SKView
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.doaSegue), name: NSNotification.Name(rawValue: "doaSegue"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showTweetSheet), name: NSNotification.Name(rawValue: "showTweetSheet"), object: nil)

        
        //view.showsFPS = true
        //view.showsNodeCount = true
        //let name :Int? = UserDefaults.standard.object(forKey: "StoreScoreName") as? Int
    }
    

    
    @objc func doaSegue(){
        performSegue(withIdentifier: "toNext", sender: self)
        self.view.removeFromSuperview()
        self.view = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         let x =  UserDefaults.standard.bool(forKey: "myName")
        
            if x == true{
        musicPlayer = setupAudioPlayerWithFile("bg_country", type: "mp3")
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
            }
        
        }
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        let url = Bundle.main.url(forResource: file as String, withExtension: type as String)
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!)
        } catch {
            print("NO AUDIO PLAYER")
        }
        return audioPlayer!
    }
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
