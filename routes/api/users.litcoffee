The **users** route is Telescope's route for signup & sign in.

	mongoose = require 'mongoose'
	router = require('express').Router()
	passport = require 'passport'
	User = mongoose.model 'User'
	auth = require '../auth'

`POST /users` handles sign up.

	router.post '/users', (req, res, next) ->
		user = new User()

		user.username = req.body.user.username
		user.email = req.body.user.email
		user.setPassword req.body.user.password

		user.save().then ->
			return res.json
				user: user.toAuthJSON()
		.catch next

`POST /user/login` handles sign in.

	router.post '/user/login', (req, res, next) ->
		if !req.body.user.username
			return res.status(422).json
				errors:
					username: "can't be blank"

		passport.authenticate('local', {session: false}, (err, user, info) ->
			if err then return next err

			if user
				user.token = user.generateJWT()
				return res.json
					user: user.toAuthJSON()
			else return res.status(422).json info
		)(req, res, next)

`GET /user` handles requests for the user of a given token.

	router.get '/user', auth.required, (req, res, next) ->
		User.findById req.payload.id
		.then (user) ->
			if !user then return res.sendStatus 401
			return res.json
				user: user.toAuthJSON()
		.catch next

`PUT /user` handles updating user info.

	router.put '/user', auth.required, (req, res, next) ->
		User.findById req.payload.id
		.then (user) ->
			if !user then return res.sendStatus 401

			reqUser = req.body.user
			for attribute in ['username', 'email', 'bio', 'location']
				if reqUser[attribute]?
					user[attribute] = reqUser[attribute]

			if reqUser.password?
				user.setPassword reqUser.password

			return user.save().then ->
				return res.json
					user: user.toAuthJSON()
		.catch next

Done. Wrap up for export.

	module.exports = router
