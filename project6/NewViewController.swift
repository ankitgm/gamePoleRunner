    //
//  NewViewController.swift
//  PoleRunner
//
//  Created by Apple on 12/6/17.
//

import UIKit

class NewViewController: GameViewController {

    @IBAction func shareTapped(_ sender: UIButton) {
      //  let imageData =
//        let imageData = UserDefaults.standard.object(forKey: "StoreImageName") as! NSData
//        let imageFromData = UIImage(data: imageData as Data)


        
        let activitycontroller = UIActivityViewController(activityItems: ["Beat Me in this awesome Game. My High Score is \(scorescore)"], applicationActivities: nil)
        present(activitycontroller,animated: true, completion: nil)
    }
    @IBOutlet weak var soundToggle: UISwitch!
    @IBAction func toggle(_ sender: UISwitch) {
        musicPlayer = setupAudioPlayerWithFile("bg_country", type: "mp3")
        musicPlayer.numberOfLoops = -1
        UserDefaults.standard.setValue(soundToggle.isOn, forKey: "myName")
        if soundToggle.isOn == false{musicPlayer.pause()}
        else {musicPlayer.play()}
    }
    override func viewDidLoad() {
        
        let x =  UserDefaults.standard.bool(forKey: "myName")
        soundToggle.setOn(x, animated: true)
        //UserDefaults.standard.setValue(true, forKey: "myName")
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "iphone-nature-wallpapers-6.jpg")!)
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
