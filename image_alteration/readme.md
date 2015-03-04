##Image alteration demo

Pulls a photo from s3, converts it, and re-uploads edited images to Amazon s3 folder.

1.Download the following s3 gem
```sh
$ gem install 'aws-s3'
```

2.Create a new project on the [Iron.io dashboard](https://hud.iron.io/dashboard)

3.Fill in the iron.json file and the keys.config.yml

4.Upload the master and slave workers along with the config file for s3 credentials
```sh
$ iron_worker upload image_alteration_master --worker-config keys.config.yml

$ iron_worker upload image_alteration_slave --worker-config keys.config.yml
```

5.Queue up the job (can also be done by UI - don't forget the payload)
```sh
$ iron_worker queue image_alteration_master -p '{"bucket": "NAME OF BUCKET"}'
```

EXAMPLE:
```sh
iron_worker queue image_alteration_slave --cluster 'mem1' -p '{"bucket":"NAME OF BUCKET","image_url": "https://s3.amazonaws.com/BUCKET/IMAGE.png", "photo_name":"IMAGE NAME" }'
```
