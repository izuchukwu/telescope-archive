**Passport** holds Telescope's Passport configuration.

	passport = require 'passport'
	LocalStrategy = require('passport-local').Strategy
	mongoose = require 'mongoose'
	User = mongoose.model 'User'

	passport.use new LocalStrategy {
		usernameField: 'user[username]'
		passwordField: 'user[password]'
	}, (username, password, done) ->
		email = username
		User.findOne({$or: [{username}, {email}]}).then (user) ->
			error = null
			if !user
				error = {item:"username or email", error:"wasn't found"}
			else if !user.validPassword password
				error = {item:"password", error:"isn't quite right"}
			if error
				return done null, false,
					errors:
						"#{error.item}": "#{error.error}"
			return done null, user
		.catch done
