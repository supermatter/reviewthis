reviewthis
===
reviewthis is a simple Sinatra app that parses github commit messages and sends email notifications based on their contents. We use it to request code reviews.

Usage
---
If a commit message includes the hash `#reviewthis`, any github user (signified by `@username`) will get an email (if they have a public email address in their github profile). Also, any email address included gets an email as well. An example commit:

	git commit -am 'I fixed that one nasty bug. #reviewthis @supermatter adifferentperson@supermatter.com'

Roll Your Own
---
reviewthis is currently configured to be easily deployed to [heroku](http://heroku.com/). Here's how (assuming you have the [heroku gem installed and configured](http://docs.heroku.com/heroku-command)):

	git clone git@github.com:supermatter/reviewthis.git
	cd reviewthis/
	heroku create
	heroku addons:add sendgrid:free
	git push heroku master

Now, just take the app name that heroku created for you, and set it as a [Post-Receive URL](http://help.github.com/post-receive-hooks/) for your repo. **Your all set!** 

Requirements
---
Besides Sinatra, reviewthis requires [mustache](http://github.com/defunkt/mustache), [pony](http://github.com/benprew/pony), and [octopussy](http://github.com/pengwynn/octopussy).

*Note that the sendgrid add-on limits you to 200 messages per day.*