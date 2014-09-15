ecdsa = require 'ecdsa'
{ serializeSig, parseSig } = ecdsa
{ sha256 } = require 'crypto-hashing'

sign_response = (key, opt={}) ->
  req_filter = opt.req_filter or (req) ->
    req.method is 'GET' and (req.query.sign_resp or req.get 'X-Sign-Response')
  curve = ecdsa opt.curve or 'secp256k1'

  (req, res, next) ->
    if req_filter req
      send = res.send

      res.send = (code, body) ->
        unless body?
          body = code
          code = null

        if typeof body is 'string'
          msg = make_message req.method, req.url, body
          sig = new Buffer serializeSig curve.sign msg, key
          res.set 'X-Response-Sig', sig.toString('base64')

        if code? then send.call this, code, body
        else send.call this, body
    next null

make_message = (method, path, body) ->
  method = method.toUpperCase()
  sha256 'ecdsa-signed-response/' + JSON.stringify { method, path, body }

verifier = (pubkey, curve_name='secp256k1') ->
  curve = ecdsa curve_name
  (method, path, body, sig) ->
    sig = new Buffer sig, 'base64' if typeof sig is 'string'
    curve.verify (make_message method, path, body), (parseSig sig), pubkey

exports = module.exports = sign_response
exports.sign_response = sign_response
exports.make_message = make_message
exports.verifier = verifier
