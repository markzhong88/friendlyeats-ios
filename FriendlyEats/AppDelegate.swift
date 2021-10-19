//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = "413905148352-2fpcljri55hfj92tt61adfqelt0ms4pb.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}

