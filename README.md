# Crush the Curve

![site preview](/preview.png)

Each cell shows the number of positive test results that day. Green is winning.
Visualization inspired by Yaneer Bar-Yam from [endcoronavirus.org](https://www.endcoronavirus.org).
The data is retrieved from [RIVM](https://data.rivm.nl/covid-19/) using
a cron job.

## Develop

To prepare the database:

```sh
rake db:seed
```

To fetch and process data:

```sh
rake data:fetch
rake data:process
rake data:fetch_provinces
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
RAILS_ENV=production bundle exec rake data:fetch data:process data:notify
```

To enable Safari push notifications, you need [register](https://developer.apple.com) a Website Push Identifier as well as a Website Push Certificate. Import the certificate into your keychain, export it as p12 and then convert to pem:

```sh
openssl pkcs12 -in crush.p12 -out crush.pem -nodes
```

Put the certificate password in `.rbenv-vars` on your server:

```
RAILS_MASTER_KEY=...
DATABASE_URL=postgresql://crush:...@127.0.0.1/crush_curve
EXCEPTION_FROM_EMAIL=bugs@...
BUGS_TO=you@example.com
CERT_PWD=...
```

Create a directory `shared/certs` and upload crush.pem and crush.p12 to it. Also download Apple's intermediate cert:

```
wget https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
```

Finally run a rake task to prepare your application:

```
RAILS_ENV=production bundle exec rake safari:register_app
```

Afaik it's not possible to test push notifications on your local development machine.
But you can check for problems with your certificate in the Rails Console, by trying
`SafariSubscription.generate_package(SecureRandom.hex)`.

On production you can monitor your log for requests to `/push/v` for errors reported by Apple's server.
