import Foundation
import AuthenticationServices
import Security

@objc(SigninWithApple) class SigninWithApple : CDVPlugin, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    struct ErrorCode {
        static let OsVersionError = -1
        static let ParameterError = -2
        static let AuthorizationError = -3
    }

    var command: CDVInvokedUrlCommand!
    
    @objc func auth(_ command: CDVInvokedUrlCommand) {
        if #available(iOS 13.0, *) {
            self.command = command
            let params = command.arguments[0] as AnyObject
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            
            var scopes: [ASAuthorization.Scope] = []
            if let arg0 = params["scopes"] as? String {
                if arg0.contains("email") { scopes.append(.email) }
                if arg0.contains("fullName") { scopes.append(.fullName) }
            }
            request.requestedScopes = scopes

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            let error = ["code": ErrorCode.OsVersionError] as [AnyHashable : Any]
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            self.commandDelegate.send(result, callbackId:command.callbackId)
            return
        }
    }
    
    @objc func validCredential(_ command: CDVInvokedUrlCommand) {
        if #available(iOS 13.0, *) {
            let params = command.arguments[0] as AnyObject
            
            guard let userID = params["userID"] as? String else {
                let error = ["code": ErrorCode.ParameterError] as [AnyHashable : Any]
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
                self.commandDelegate.send(result, callbackId:command.callbackId)
                return
            }
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                if credentialState == .authorized {
                    let result = CDVPluginResult(status: CDVCommandStatus_OK)
                    self.commandDelegate.send(result, callbackId:command.callbackId)
                } else {
                    let err = ["code": ErrorCode.AuthorizationError, "description": error!.localizedDescription] as [AnyHashable : Any]
                    let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err)
                    self.commandDelegate.send(result, callbackId:command.callbackId)
                }
            }
        } else {
            let error = ["code": ErrorCode.OsVersionError] as [AnyHashable : Any]
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error)
            self.commandDelegate.send(result, callbackId:command.callbackId)
            return
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var data = ["userIdentifier":nil, "fullName":nil, "email":nil] as [String : Any?]
            
            data.updateValue(appleIDCredential.user, forKey: "userIdentifier")
            data.updateValue(appleIDCredential.fullName?.givenName, forKey: "givenName")
            data.updateValue(appleIDCredential.fullName?.familyName, forKey: "familyName")
            data.updateValue(appleIDCredential.email, forKey: "email")
            
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:data as [AnyHashable : Any])
            self.commandDelegate.send(result, callbackId:command.callbackId)
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let err = ["code": ErrorCode.AuthorizationError, "description": error.localizedDescription] as [AnyHashable : Any]
        let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err)
        self.commandDelegate.send(result, callbackId:command.callbackId)
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.viewController.view.window!
    }
}
