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
import AuthenticationServices
import CryptoKit

class UserSignInViewController: UIViewController, GIDSignInDelegate {
    
    var window: UIWindow?
    
    @IBOutlet weak var GoogleSignBtn: GIDSignInButton!
    @IBOutlet weak var startBtn: UIButton!
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Sign In"
        self.view.backgroundColor = UIColor.white
        GoogleSignBtn.style = .wide
        GoogleSignBtn.colorScheme = .light
        
        GIDSignIn.sharedInstance().clientID = "413905148352-1r93tjhi7g36n55jqohb0n7rtdg0q5ba.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        setupAppleButton()
        
    }
    
    func setupAppleButton() {
        if #available(iOS 13.0, *) {
            let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            view.addSubview(appleButton)
            appleButton.cornerRadius = 12
            appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
            appleButton.translatesAutoresizingMaskIntoConstraints = false
            appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            appleButton.widthAnchor.constraint(equalToConstant: 235).isActive = true
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            appleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
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


// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}



@available(iOS 13.0, *)
extension UserSignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let user = authResult?.user else { return }
                let email = user.email ?? ""
                let displayName = user.displayName ?? ""
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()
                db.collection("User").document(uid).setData([
                    "email": email,
                    "displayName": displayName,
                    "uid": uid
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("the user has sign up or is logged in")
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension UserSignInViewController : ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
