'use strict';

var exec = require('cordova/exec');

var SigninWithApple = {

  auth: function(param, onSuccess, onFail) {
    return exec(onSuccess, onFail, 'SigninWithApple', 'auth', [param]);
  },

  validCredential: function(param, onSuccess, onFail) {
    return exec(onSuccess, onFail, 'SigninWithApple', 'validCredential', [param]);
  }

};
module.exports = SigninWithApple;
