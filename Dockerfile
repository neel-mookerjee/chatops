FROM gliderlabs/alpine:3.3

RUN apk --no-cache add git bash openssh

RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

ADD bin/main /
ADD scripts/sample-script.sh /
ENTRYPOINT ["/main"]
