express = require 'express'
iferr = require 'iferr'
request = require 'supertest'
ecdsa = require 'ecdsa'
ok = require 'assert'
signed_response = require '../index.coffee'

pubkey = new Buffer '03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd', 'hex'
privkey = new Buffer 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex'

app = express()

app.use signed_response privkey
app.get '/hey', (req, res) -> res.type('text/plain').send 'hello world'

describe 'signed response', ->
  it 'signs responses', (done) ->
    request app
      .get '/hey'
      .set 'X-Sign-Response', 1
      .end iferr done, (res) ->
        sig = new Buffer res.get('X-Response-Sig'), 'base64'
        msg = signed_response.make_message
          hostname: '127.0.0.1'
          method: 'GET'
          url: '/hey'
        , res.text
        ok ecdsa.verify msg, (ecdsa.parseSig sig), pubkey
        do done
