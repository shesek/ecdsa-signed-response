# ecdsa-signed-response

Sign Express HTTP responses with ECDSA

## Install

    npm install ecdsa-signed-response

## Use

    var app = require('express')()
      , signedResp = require('ecdsa-signed-response')
      , privkey = new Buffer('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex')
  
     app.use(signedResp(privkey))

##### Options
The `signedResp` function takes an optional second argument with the following options:

- **curve**: The ECDSA curve to use. secp256k1 by default.
- **req_filter**:
  a function takes the request object and
  returns a boolean indicating whether the response should be signed.

  By default, only signs responses for requests with the `sign_resp` query string argument
  or the `X-Sign-Response` header specified.
  
  Pass `function(){ return true }` to sign all responses.
