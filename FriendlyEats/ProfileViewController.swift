//
//  ProfileViewController.swift
//  FriendlyEats
//
//  Created by Mark Zhong on 10/18/21.
//  Copyright © 2021 Firebase. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Profile"
        /*
        //METHOD 1: To get basic infor like user display name, email etc you can use
        let currentUser = Auth.auth().currentUser
        print(currentUser?.displayName)
        print(currentUser?.email)
        
        //METHOD 2: NOTE!! The method below this is not working for some of people
        let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
        let fullName = user.profile.name
        let email = user.profile.email
        if user.profile.hasImage {
            let userDP = user.profile.imageURL(withDimension: 200)
            self.sampleImageView.sd_setImage(with: userDP, placeholderImage: UIImage(named: "default-profile”))
        } else {
            self.sampleImageView.image = UIImage(named: "default-profile”)
        }
        */
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func logoutUser() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func checkUserAuth() {
        let user = Auth.auth().currentUser
        if user?.uid == nil {
            //Show Login Screen
        } else {
            //Show content
        }
    }
}
