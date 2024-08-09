#!/bin/bash
pushd vaapi
	./clean.sh
popd
rm -rf 	"Blackmagic DeckLink SDK 10.6.5"
rm -rf 	decklink-sdk
rm -rf 	fdk-aac
rm -rf 	libav-obe ffmpeg
rm -rf 	libmpegts-obe
rm -rf 	libyuv
rm -rf 	obe-rt
rm -rf 	target-root
rm -rf 	twolame-0.3.13
rm -rf 	x264-obe
rm -rf 	obe-bitstream
rm -rf 	libklvanc
rm -rf 	libklscte35
rm -rf 	bmsdk
rm -rf  obecli-*
rm -rf  libzvbi
rm -rf  x265
rm -rf  libwebsockets
rm -rf  json-c
rm -rf  libltntstools
rm -rf  libltnsdi
rm -f   tarball.tgz
