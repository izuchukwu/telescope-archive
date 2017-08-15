The **API index** registers routes for Telescope.

	router = require('express').Router()

Here, we specify our routes. `users` handles sign up & sign in.

	router.use '/', require './users'

Next is our error handler.

	router.use (err, req, res, next) ->
		if err.name is "ValidationError"
			return res.status(422).json
				errors: Object.keys(err.errors).reduce ((errors, key) ->
						errors[key] = err.errors[key].message
						return errors
					), {}
		return next err

Done, wrap up for export.

	module.exports = router
