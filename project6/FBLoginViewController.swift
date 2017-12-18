//
//  FBLoginViewController.swift
//  PoleRunner
//
//  Created by Apple on 12/5/17.
//

import UIKit
import FBSDKLoginKit

class FBLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var loginButton: FBSDKLoginButton!

    @IBOutlet weak var gotoNext: UIButton!
    
    override func viewDidLoad() {
      //  super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "first_page.jpg")!)

gotoNext.isEnabled = false
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile","email","user_friends"]
        if FBSDKAccessToken.current() != nil{
             self.performSegue(withIdentifier: "yoyo", sender: self)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        gotoNext.isEnabled = true
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("completed login")
        gotoNext.isEnabled = true
        
//        if let userToken = result.token
//        {
//            let protectedPage = self.storyboard?.instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
//            let protectedPageNav = UINavigationController(rootViewController: protectedPage)
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = protectedPageNav
            self.performSegue(withIdentifier: "yoyo", sender: self)

        
//        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print ("logout")
        gotoNext.isEnabled = false
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.web
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
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
