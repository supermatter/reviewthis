reviewthis
===
*reviewthis* is a simple Sinatra app that parses github commit messages and sends email notifications based on their contents. [We use it to request code reviews](http://blog.supermatter.com/post/875844569/how-we-use-github-for-code-reviews) from other team members.

Usage
---
If a commit message includes the hash `#reviewthis`, any github user (signified by `@username`) will get an email (if they have a public email address in their github profile). Also, any email address included gets an email as well. An example commit:

	git commit -am 'I fixed that one nasty bug. #reviewthis @supermatter adifferentperson@supermatter.com'

To use it, just set a [Post-Receive URL](http://help.github.com/post-receive-hooks/) for your repo to `http://reviewth.is/` and **You're all set!**.

Roll Your Own
---
If you want to roll your own, *reviewthis* is set up to be easily deployed to [heroku](http://heroku.com/). Here's how.

### Heroku Deployment
*Note this assumes you have the [heroku gem installed and configured](http://docs.heroku.com/heroku-command)).*

	git clone git@github.com:supermatter/reviewthis.git
	cd reviewthis/
	heroku create
	heroku addons:add sendgrid:starter
	git push heroku master

Now, just take the app name that heroku created for you, and set it as a [Post-Receive URL](http://help.github.com/post-receive-hooks/) for your repo. **You're all set!**

### Non-Heroku Deployment
If you don't want to use Heroku, you'll have to adjust the smtp config values in the production environment. Otherwise, it should work out of the box.

Requirements
---
Besides Sinatra, *reviewthis* requires

+ [json](http://flori.github.com/json/),

+ [mustache](http://github.com/defunkt/mustache),

+ [pony](http://github.com/benprew/pony), and

+ [octopussy](http://github.com/pengwynn/octopussy).

*Note that the sendgrid add-on limits you to 200 messages per day.*
