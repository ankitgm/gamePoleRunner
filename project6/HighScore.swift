//
//  HighScore.swift
//  PoleRunner
//
//  Created by Apple on 12/10/17.
//

import UIKit

class HighScore: GameViewController {

    override func viewDidLoad() {
       
        let x = UserDefaults.standard.integer(forKey: "yoyoget")
        print("Your score is")
        print(x)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
       
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
