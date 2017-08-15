var LocalStrategy, User, mongoose, passport;

passport = require('passport');

LocalStrategy = require('passport-local').Strategy;

mongoose = require('mongoose');

User = mongoose.model('User');

passport.use(new LocalStrategy({
  usernameField: 'user[username]',
  passwordField: 'user[password]'
}, function(username, password, done) {
  var email;
  email = username;
  return User.findOne({
    $or: [
      {
        username: username
      }, {
        email: email
      }
    ]
  }).then(function(user) {
    var error, obj;
    error = null;
    if (!user) {
      error = {
        item: "username or email",
        error: "wasn't found"
      };
    } else if (!user.validPassword(password)) {
      error = {
        item: "password",
        error: "isn't quite right"
      };
    }
    if (error) {
      return done(null, false, {
        errors: (
          obj = {},
          obj["" + error.item] = "" + error.error,
          obj
        )
      });
    }
    return done(null, user);
  })["catch"](done);
}));
