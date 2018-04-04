//
//  FacebookLoginManager.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/4/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class FacebookSignInManager: NSObject {
    typealias LoginCompletionBlock = (Dictionary<String, AnyObject>?, NSError?) -> Void
    
    //MARK:- Public functions
    class func basicInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        
        //Check internet connection if no internet connection then return
        
        
        self.getBaicInfoWithCompletionHandler(fromViewController) { (dataDictionary:Dictionary<String, AnyObject>?, error: NSError?) -> Void in
            onCompletion(dataDictionary, error)
        }
    }
    
    class func logoutFromFacebook() {
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }
    
    //MARK:- Private functions
    class fileprivate func getBaicInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        let permissionDictionary = [
            "fields" : "name",
            //"locale" : "en_US"
        ]
        if FBSDKAccessToken.current() != nil {
            //firebase convert token shit here
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    // ...
                    return
                }
                print("please god please")
            }
        
            
            FBSDKGraphRequest(graphPath: "/me", parameters: permissionDictionary)
                .start(completionHandler:  { (connection, result, error) in
                    if error == nil {
                        onCompletion(result as? Dictionary<String, AnyObject>, nil)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                })
            
        } else {
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_photos"], from: fromViewController as! UIViewController, handler: { (result, error) -> Void in
                if error != nil {
                    FBSDKLoginManager().logOut()
                    if let error = error as NSError? {
                        let errorDetails = [NSLocalizedDescriptionKey : "Processing Error. Please try again!"]
                        let customError = NSError(domain: "Error!", code: error.code, userInfo: errorDetails)
                        onCompletion(nil, customError)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                    
                } else if (result?.isCancelled)! {
                    FBSDKLoginManager().logOut()
                    let errorDetails = [NSLocalizedDescriptionKey : "Request cancelled!"]
                    let customError = NSError(domain: "Request cancelled!", code: 1001, userInfo: errorDetails)
                    onCompletion(nil, customError)
                } else {
                    let pictureRequest = FBSDKGraphRequest(graphPath: "me", parameters: permissionDictionary)
                    let _ = pictureRequest?.start(completionHandler: {
                        (connection, result, error) -> Void in
                        
                        if error == nil {
                            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

                            onCompletion(result as? Dictionary<String, AnyObject>, nil)
                            
                            Auth.auth().signIn(with: credential) { (user, error) in
                                if let error = error {
                                    // ...
                                    return
                                }
                                print("please god please")
                            }
                            
                        } else {
                            onCompletion(nil, error as NSError?)
                        }
                    })
                }
            })
        }
    }
}

//// facebook Setup>> Make sure to add in didfinish launching. So that the current access token can be used
//FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
