##ffmpeg demo

Converts video and uploads it to Amazon S3

1.Download the following s3 gem
```sh
$ gem install 'aws-s3'
```

2.Create a new project on the [Iron.io dashboard](https://hud.iron.io/dashboard)

3.Fill in the iron.json file and the keys.config.yml

4.Upload the worker along with the config file for s3 credentials
```sh
$ iron_worker upload ffmpeg_demo --worker-config keys.config.yml
```

5.Queue up the job (can also be done by UI - don't forget the payload)
```sh
$ iron_worker queue ffmpeg_demo -p '{"store_name":"NAME FOR NEW FILE IN S3", "video_url":"EXISITNG FILE IN S3"}'
```

EXAMPLE:
```sh
$ iron_worker queue ffmpeg_demo -p '{"store_name":"FOLDER(optional)/NEW_FILE_NAME.mp4", "video_url":"https://s3.amazonaws.com/FOLDER_NAME/FILE_NAME.mov"}'
