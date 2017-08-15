var app, bodyParser, cors, errorhandler, express, fs, http, isProduction, methods, mongoose, passport, path, server, session;

fs = require('fs');

http = require('http');

path = require('path');

methods = require('methods');

express = require('express');

bodyParser = require('body-parser');

session = require('express-session');

cors = require('cors');

passport = require('passport');

errorhandler = require('errorhandler');

mongoose = require('mongoose');

isProduction = process.env.NODE_ENV === "production";

app = express();

app.use(cors());

app.use(require('morgan')('dev'));

app.use(bodyParser.urlencoded({
  extended: false
}));

app.use(bodyParser.json());

app.use(require('method-override')());

app.use(express["static"](__dirname + '/public'));

app.use(session({
  secret: 'telescope',
  cookie: {
    maxAge: 60000
  },
  resave: false,
  saveUninitialized: false
}));

if (!isProduction) {
  app.use(errorhandler());
}

if (isProduction) {
  mongoose.connect(process.env.MONGODB_URI, {
    useMongoClient: true
  });
} else {
  mongoose.connect('mongodb://localhost/telescope', {
    useMongoClient: true
  });
  mongoose.set('debug', true);
}

require('./models/User');

require('./config/passport');

app.use(require('./routes'));

app.use(function(req, res, next) {
  var err;
  err = new Error('Not Found :(');
  err.status = 404;
  return next(err);
});

if (!isProduction) {
  app.use(function(err, req, res, next) {
    console.log(err.stack);
    res.status(err.status || 500);
    return res.json({
      errors: {
        message: err.message,
        error: err
      }
    });
  });
}

app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  return res.json({
    errors: {
      message: err.message,
      error: {}
    }
  });
});

server = app.listen(process.env.PORT || 3000, function() {
  return console.log("Hello Telescope. Listening on port " + (server.address().port) + ".");
});
