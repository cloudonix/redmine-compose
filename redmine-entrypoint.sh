#!/bin/bash -ex

if [ -f /hack-plugin-loader.patch ]; then
	apt update
	apt install patch
	patch -p1 < /hack-plugin-loader.patch
	rm -f /hack-plugin-loader.patch
fi

exec rails server -b 0.0.0.0 "$@"
