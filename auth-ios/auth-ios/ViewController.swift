//
//  ViewController.swift
//  auth-ios
//
//  Created by Victor Chirino on 04/06/2019.
//  Copyright © 2019 Victor Chirino. All rights reserved.
//

import UIKit
import AppAuth
import SafariServices

class ViewController: UIViewController {
    
    var safariVC: SFSafariViewController!
    let authURL = URL(string: "http://localhost:4000/oauth/authorize")!
    let tokenEndpoint = URL(string: "http://localhost:4000/oauth/token")!
    let clientId = "8417130ee486e5f9a873e3ebb52ee180165bc02587413c461e60dfd0e6eb01d7"
    let redirectURL = URL(string: "localhost://redirect_url")!
    let kAppAuthExampleAuthStateKey: String = "authState";
    let issuerURL = URL(string: "http://localhost:4000")!
    
    private var authState: OIDAuthState?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .purple
        
        let appAuthButton = UIButton(type: .custom)
        appAuthButton.frame = CGRect(x: (view.frame.width / 2) - 70, y: (view.frame.height / 2) - 30, width: 140, height: 60)
        appAuthButton.setTitle("AppAuth Login", for: .normal)
        appAuthButton.backgroundColor = .orange
        appAuthButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        view.addSubview(appAuthButton)
        
    
    }

    
    @objc func loginAction() {
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authURL, tokenEndpoint: tokenEndpoint, issuer: issuerURL)
        doAuthWithAutoCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil)
    }
    
}

extension ViewController {
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
            
            if let authState = authState {
                self.setAuthState(authState)
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.saveState()
    }
    
    func saveState() {
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
        UserDefaults.standard.synchronize()
    }
    
    
}


//MARK: OIDAuthState Delegate
extension ViewController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        print("• State: ", state)
//        self.stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("• Received authorization error:: ", error)
//        self.logMessage("Received authorization error: \(error)")
    }
}




