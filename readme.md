#BANDS IN TOWN WATCHER!!

Tool to watch the bands in town api and notify users when date or venue changed

##USAGE

1. fork the project, change the config/index.coffee to your app_id and bands you want to watch

2. deploy to [heroku](heroku.com)

        heroku apps:create [appname]
        git push heroku master

3. install [redistogo](http://redistogo.com/) addon

        heroku addons:add redistogo

4. set the mail address and target

        heroku config:add USERNAME=[mail address]
        heroku config:add PASSWORD=[mail password]
        heroku config:add TO=[notify address]

5. run the service!

        heroku ps:scale app=1

