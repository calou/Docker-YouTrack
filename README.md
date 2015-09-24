# Docker container for Youtrack

## Build image
	docker build -t calou/youtrack . 

## Run container
	docker run -d -p 80:80 -v /tmp/data:/opt/youtrack/data/ -v /tmp/backup:/opt/youtrack/backup/ -t calou/youtrack