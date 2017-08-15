var User, auth, mongoose, passport, router;

mongoose = require('mongoose');

router = require('express').Router();

passport = require('passport');

User = mongoose.model('User');

auth = require('../auth');

router.post('/users', function(req, res, next) {
  var user;
  user = new User();
  user.username = req.body.user.username;
  user.email = req.body.user.email;
  user.setPassword(req.body.user.password);
  return user.save().then(function() {
    return res.json({
      user: user.toAuthJSON()
    });
  })["catch"](next);
});

router.post('/user/login', function(req, res, next) {
  if (!req.body.user.username) {
    return res.status(422).json({
      errors: {
        username: "can't be blank"
      }
    });
  }
  return passport.authenticate('local', {
    session: false
  }, function(err, user, info) {
    if (err) {
      return next(err);
    }
    if (user) {
      user.token = user.generateJWT();
      return res.json({
        user: user.toAuthJSON()
      });
    } else {
      return res.status(422).json(info);
    }
  })(req, res, next);
});

router.get('/user', auth.required, function(req, res, next) {
  return User.findById(req.payload.id).then(function(user) {
    if (!user) {
      return res.sendStatus(401);
    }
    return res.json({
      user: user.toAuthJSON()
    });
  })["catch"](next);
});

router.put('/user', auth.required, function(req, res, next) {
  return User.findById(req.payload.id).then(function(user) {
    var attribute, i, len, ref, reqUser;
    if (!user) {
      return res.sendStatus(401);
    }
    reqUser = req.body.user;
    ref = ['username', 'email', 'bio', 'location'];
    for (i = 0, len = ref.length; i < len; i++) {
      attribute = ref[i];
      if (reqUser[attribute] != null) {
        user[attribute] = reqUser[attribute];
      }
    }
    if (reqUser.password != null) {
      user.setPassword(reqUser.password);
    }
    return user.save().then(function() {
      return res.json({
        user: user.toAuthJSON()
      });
    });
  })["catch"](next);
});

module.exports = router;
