express = require 'express'
iferr = require 'iferr'
request = require 'supertest'
ecdsa = require 'ecdsa'
ok = require 'assert'
signed_response = require '../index.coffee'

pubkey = new Buffer '03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd', 'hex'
privkey = new Buffer 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex'

describe 'signed response', ->
  app = express()
    .use signed_response privkey
    .get '/hey', (req, res) -> res.send 'hello world'

  it 'signs responses when X-Sign-Response is specified', (done) ->
    request app
      .get '/hey'
      .set 'X-Sign-Response', 1
      .end iferr done, (res) ->
        sig = new Buffer res.get('X-Response-Sig'), 'base64'
        ok signed_response.verifier(pubkey)('GET', '/hey', res.text, sig)
        do done

  it 'does not sign otherwise', (done) ->
    request app
      .get '/get'
      .end iferr done, (res) ->
        ok not res.get('X-Response-Sig')?
        do done

  it 'allows to specify a custom request filter', (done) ->
    app2 = express()
      .use signed_response privkey, req_filter: (-> true)
      .get '/ping', (req, res) -> res.send 'pong'
    request app2
      .get '/ping'
      .end iferr done, (res) ->
        ok res.get('X-Response-Sig')?
        do done
    
