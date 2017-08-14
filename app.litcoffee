**App** is telescope's app delegate.

	fs = require 'fs'
	http = require 'http'
	path = require 'path'
	methods = require 'methods'
	express = require 'express'
	bodyParser = require 'body-parser'
	session = require 'express-session'
	cors = require 'cors'
	passport = require 'passport'
	errorhandler = require 'errorhandler'
	mongoose = require 'mongoose'

	isProduction = process.env.NODE_ENV is "production"

	# Create global app object

	app = express()
	app.use cors()

	# Express config defaults

	app.use require('morgan')('dev')
	app.use bodyParser.urlencoded
		extended: false
	app.use bodyParser.json()

	app.use require('method-override')()
	app.use express.static __dirname + '/public'

	app.use session
		secret: 'telescope'
		cookie:
			maxAge: 60000
		resave: false
		saveUninitialized: false

	if !isProduction
		app.use errorhandler()

	if isProduction
		mongoose.connect process.env.MONGODB_URI,
			useMongoClient: true
	else
		mongoose.connect 'mongodb://localhost/telescope',
			useMongoClient: true
		mongoose.set 'debug', true

	app.use require './routes'

	# Catch 404's

	app.use (req, res, next) ->
		err = new Error 'Not Found :('
		err.status = 404
		next err

	# Dev error handler (with stack trace)

	if !isProduction
		app.use (err, req, res, next) ->
			console.log err.stack
			res.status err.status or 500
			res.json
				errors:
					message: err.message
					error: err

	# Standard error handler

	app.use (err, req, res, next) ->
		res.status err.status or 500
		res.json
			errors:
				message: err.message
				error: {}

	# Start server

	server = app.listen process.env.PORT or 3000, ->
		console.log "Hello Telescope. Listening on port #{server.address().port}."
