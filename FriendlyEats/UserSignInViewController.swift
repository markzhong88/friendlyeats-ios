//
//  UserSignInViewController.swift
//  FriendlyEats
//
//  Created by Mark Zhong on 10/14/21.
//  Copyright © 2021 Firebase. All rights reserved.
//


import UIKit
import FirebaseUI
import FirebaseFirestore
import SDWebImage
import MapKit


class UserSignInViewController: UIViewController {
    
    var window: UIWindow?

    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Flying Spot"
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      let auth = FUIAuth.defaultAuthUI()!
      if auth.auth?.currentUser == nil {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        let emailAuth = FUIEmailAuth(authAuthUI: auth,
                                     signInMethod: EmailPasswordAuthSignInMethod,
                                     forceSameDevice: false,
                                     allowNewEmailAccounts: true,
                                     actionCodeSetting: actionCodeSettings)
        auth.providers = [emailAuth]
        present(auth.authViewController(), animated: true, completion: nil)
      } 
    }

    
    @IBAction func clickStartMap(_ sender: Any) {
        let vc = MapViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
