var UserSchema, beautifulUnique, crypto, jwt, mongoose, secret;

mongoose = require('mongoose');

beautifulUnique = require('mongoose-beautiful-unique-validation');

crypto = require('crypto');

jwt = require('jsonwebtoken');

secret = require('../config').secret;

UserSchema = new mongoose.Schema({
  username: {
    type: String,
    lowercase: true,
    required: [true, "can't be empty"],
    match: [/^[_a-zA-Z0-9]+$/, "isn't quite right"],
    index: true,
    unique: "This username is already taken :("
  },
  email: String({
    type: String,
    lowercase: true,
    required: [true, "can't be empty"],
    match: [/\S+@\S+\.\S+/, "isn't quite right"],
    index: true
  }),
  bio: String,
  location: String,
  hash: String,
  salt: String
}, {
  timestamps: true
});

UserSchema.methods.setPassword = function(password) {
  this.salt = crypto.randomBytes(16).toString("hex");
  this.hash = crypto.pbkdf2Sync(password, this.salt, 10000, 512, "sha512").toString("hex");
  return null;
};

UserSchema.methods.validPassword = function(password) {
  var hash;
  hash = crypto.pbkdf2Sync(password, this.salt, 10000, 512, "sha512").toString("hex");
  return this.hash === hash;
};

UserSchema.methods.generateJWT = function() {
  var exp, today;
  today = new Date;
  exp = new Date;
  exp.setDate(today.getDate() + 60);
  return jwt.sign({
    id: this._id,
    username: this.username,
    exp: parseInt(exp.getTime() / 1000)
  }, secret);
};

UserSchema.methods.toAuthJSON = function() {
  return {
    username: this.username,
    email: this.email,
    token: this.generateJWT(),
    bio: this.bio,
    location: this.location
  };
};

UserSchema.plugin(beautifulUnique);

mongoose.model('User', UserSchema);
