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
import FirebaseAuth
import GoogleSignIn

class UserSignInViewController: UIViewController, GIDSignInDelegate {
    
    var window: UIWindow?

    @IBOutlet weak var GoogleSignBtn: GIDSignInButton!
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Sign In"
        self.view.backgroundColor = UIColor.white
        GoogleSignBtn.style = .wide
        GoogleSignBtn.colorScheme = .light
        
        
        GIDSignIn.sharedInstance().clientID = "413905148352-2fpcljri55hfj92tt61adfqelt0ms4pb.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().restorePreviousSignIn()
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      GIDSignIn.sharedInstance().presentingViewController = self
        
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("user signed up email: \(user.profile.email ?? "no email")")
        print("user given name: \(user.profile.givenName ?? "No given name")")
        print("user family name: \(user.profile.familyName ?? "No family name")")
        print("user id: \(user.userID ?? "No family name")")

        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful.")
                //This is where you should add the functionality of successful login
                //i.e. dismissing this view or push the home view controller etc
                self.saveUserToDB(uid: authResult?.user.uid, firstname: user.profile.givenName, lastname: user.profile.familyName, email: user.profile.email)
                
            }
        }
    }
    
    func saveUserToDB(uid: String?, firstname:String?, lastname:String?, email:String) {
        let db = Firestore.firestore()
        guard let uid = uid else { return }
        let _: Void = db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot, snapshot.documents.count > 0 {
                    print(snapshot.documents)
                } else {
                    print("not an existed user, so save to DB")
                    db.collection("users").addDocument(data: ["firstname":firstname ?? "", "lastname":lastname ?? "", "uid": uid, "email":email ]) { (error) in

                        if error != nil {
                            print("auth sign error: ", error ?? "error")
                        }
                    }
                }
            }
    }
    
    func presentAuthUI() {
        let auth = FUIAuth.defaultAuthUI()!
        if auth.auth?.currentUser == nil {
          let actionCodeSettings = ActionCodeSettings()
          actionCodeSettings.handleCodeInApp = true
          let emailAuth = FUIEmailAuth(authAuthUI: auth,
                                       signInMethod: EmailPasswordAuthSignInMethod,
                                       forceSameDevice: false,
                                       allowNewEmailAccounts: true,
                                       actionCodeSetting: actionCodeSettings)
          let googleAuth = FUIGoogleAuth()
          if #available(iOS 13.0, *) {
              let appleAuth = FUIOAuth.appleAuthProvider()
              auth.providers = [emailAuth, googleAuth, appleAuth]
          } else {
              // Fallback on earlier versions
              auth.providers = [emailAuth, googleAuth]
          }
          
          present(auth.authViewController(), animated: true, completion: nil)
        }
    }
    
    @IBAction func clickStartMap(_ sender: Any) {
//        let vc = MapViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//
//
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func clickGoogleSignIn(_ sender: Any) {
        print("start google sign in")
        
    }
    
    
}
