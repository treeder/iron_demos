##Worker Pipeline demo

Populate a 3rd party hotel database. Have a worker retreive price updates from the 3rd party API and filter them accordingly. Then, spin up slaves to update an internal DB ('s3' replicated a DB in this case)

1.Download the following s3 gem
```sh
$ gem install 'aws-s3'
```

2.Create a new project on the [Iron.io dashboard](https://hud.iron.io/dashboard)

3.Fill in the iron.json file with your Iron keys and the keys.config.yml with your AWS keys

4.Upload the master and slave workers along with the config file for s3 credentials
```sh
$ iron_worker upload retreive_pricing_availability_options

$ iron_worker upload update_internal_inventory --worker-config keys.config.yml
```

5.Kick it off!
```sh
$ ruby queue_inventory 200
```
