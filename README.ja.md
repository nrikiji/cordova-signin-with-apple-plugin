# cordova-signin-with-apple-plugin

Signin With Appleを実装するためのcordovaプラグイン。　　

機能はログイン、検証を行う。  

cordova >= 7.1.0  
cordova-ios >= 4.5.0  
xcode >= 11

```
例)swift5を使用する場合
config.xml  
<platform name="ios">
  <preference name="UseSwiftLanguageVersion" value="5" />
</platform>
```

## Requirement
https://github.com/akofman/cordova-plugin-add-swift-support  

## Installation
```
cordova plugin add cordova-signin-with-apple-plugin  
```

## Supported Platforms
- iOS (>=13.0)

## Example

ionicでの使用例
```js
angular.module('starter', ['ionic'])
  .run(function($ionicPlatform) {
    $ionicPlatform.ready(function() {
      window.signinWithApple.validCredential({
        userID: result.userIdentifier
      },function() {
        // success
      }, function(err) {
        // failure
        /*
        {
          code: -3,
          description: "The operation couldn’t be completed. (com.apple.AuthenticationServices.AuthorizationError error 1000.)"
        }
        */
      });
    });
  })
  .controller("SigninCtrl", function($scope) {
    $scope.onSignin = function() {
      // signin...
      window.signinWithApple.auth({
        scopes: "fullName, email"
      }, function(result) {
        /*
          success
          {
            email: "xxx@example.com",
            userIdentifier: "xxxxx.yyyyy.zzzzz...",
            givenName: "xxxxx",
            familyName: "xxxxx"
          }
        */
      }, function(err) {
        /*
         failure
         {
           code: -3,
           description: "description: "The operation couldn’t be completed. (com.apple.AuthenticationServices.AuthorizationError error 1001.)"
         }
        */
      });
    }
  });
```
