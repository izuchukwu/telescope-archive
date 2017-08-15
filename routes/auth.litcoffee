**Auth** is Telescope's token extractor.

	jwt = require 'express-jwt'
	secret = require('../config').secret

	getTokenFromHeader = (req) ->
		if req.headers.authorization and req.headers.authorization.split(' ')[0] is 'Token'
			return req.headers.authorization.split(' ')[1]
		return null

	auth =
		required: jwt
			secret: secret
			userProperty: 'payload'
			getToken: getTokenFromHeader
		option: jwt
			secret: secret
			userProperty: 'payload'
			credentialsRequired: false
			getToken: getTokenFromHeader

Done. Wrap up for export.

	module.exports = auth
