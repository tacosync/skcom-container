```
docker build -t skbot:sandbox .
docker run --name skbot-0 -p 5900:5900 -it skbot:sandbox
docker start -i skbot-0
docker rm skbot-0
```
