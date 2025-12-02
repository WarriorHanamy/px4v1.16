build-px4:
	docker build -f docker/px4v1.16.dockerfile \
		--network=host \
		-t px4v116:latest .
 
px4:
	docker run -it --rm \
		--privileged --net=host \
		-e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 \
		-e ACCEPT_EULA=Y -e PRIVACY_CONSENT=Y \
		-v $HOME/.Xauthority:/root/.Xauthority \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--name px4v116 \
		px4v116 bash
