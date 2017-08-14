**User** is the mongoose schema for users.

	mongoose = require 'mongoose'
	beautifulUnique = require 'mongoose-beautiful-unique-validation'
	crypto = require 'crypto'
	jwt = require 'jsonwebtoken'
	secret = require('../config').secret

The User schema is backed by `UserSchema`, providing for a `username` string, an `email` string, a `bio` string, and a `location` string. Each are strings, though in use there are a few restrictions and preferences:

- `username` is expected to be a latin alphanumeric (plus underscore) string of 1-24 characters
- `email` is expected to be a valid email address (excl. bare TLDs)
- `bio` is expected to be a unicode string of 0-140 characters. Preferentially, usernames are expressed as `@`-prefixed names, and scopes as `/`-bounded names.
- `location` is a unicode string of 0-24 characters. Preferentially, locations are expressed as short names like "Austin", or abbreviations like "ATL".

*TODO: move restrictions to an external schema document & reference it here.*

	UserSchema = new mongoose.Schema {
		username:
			type: String
			lowercase: true
			required: [true, "can't be empty"]
			match: [/^[_a-zA-Z0-9]+$/, "isn't quite right"]
			index: true
			unique: "This username is already taken :("
		email: String
			type: String
			lowercase: true
			required: [true, "can't be empty"]
			match: [/\S+@\S+\.\S+/, "isn't quite right"]
			index: true
		bio: String
		location: String
		hash: String,
		salt: String },
		{ timestamps: true }

**Passwords & Sessions**. User passwords are secured with 10k iterations on PBKDF2 with SHA512.

	UserSchema.methods.setPassword = (password) ->
		@salt = crypto.randomBytes(16).toString "hex"
		@hash = crypto.pbkdf2Sync(password, @salt, 10000, 512, "sha512").toString "hex"
		return null

	UserSchema.methods.validPassword = (password) ->
		hash = crypto.pbkdf2Sync(password, @salt, 10000, 512, "sha512").toString "hex"
		return @hash is hash

	UserSchema.methods.generateJWT = ->
		today = new Date
		exp = new Date
		exp.setDate today.getDate() + 60

		return jwt.sign {
			id: @_id
			username: @username
			exp: parseInt exp.getTime() / 1000 }, secret

	UserSchema.methods.toAuthJSON = ->
		username: @username
		email: @email
		token: @generateJWT()
		bio: @bio
		location: @location

Done, set plugins & prepare the schema for use.

	UserSchema.plugin beautifulUnique

	mongoose.model 'User', UserSchema
