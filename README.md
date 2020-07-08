# Crush the Curve

![site preview](/preview.png)

Each cell shows the number of positive test results that day. Green is winning.
Visualization inspired by Yaneer Bar-Yam from [endcoronavirus.org](https://www.endcoronavirus.org). Data source [RIVM](https://www.databronnencovid19.nl).
The data is retrieved from [ESRI NL COVID-19 Hub](http://esri.nl/corona") using
a cron job.

## Develop

To fetch and process data:

```sh
rake data:fetch
rake data:process
```

Run the server:

```sh
rails s
```

## Contribute

The site is designed around Dutch data, but pull requests are welcome to make the
code more abstract, import data from other countries and display text in different
languages. However you will have to host it yourself.

## Deploy

The site is currently deployed on an Ubuntu server roughly based on [this guide](https://gorails.com/deploy/ubuntu/20.04). It's hosted on [TransIP](https://www.transip.eu).

A cron job and bash script take care of syncing and processing data:

```
MAILTO=sjors@sprovoost.nl
# m h  dom mon dow   command
39 * * * * /usr/bin/cronic ~/rake_sync.sh
```

`rake_sync.sh`:

```sh
PATH=$PATH:/usr/local/bin:/home/crush/.rbenv/bin:/home/crush/.rbenv/shims
eval "$(rbenv init -)"
cd ~/crush_curve/current
RAILS_ENV=production bundle exec rake data:fetch data:process
```
