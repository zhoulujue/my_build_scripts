#!/bin/bash

function buildMyFFmpeg {
../configure  --prefix=/Users/lujuezhou/ffmpegbuilddir --enable-gpl --enable-nonfree --enable-libass \
--enable-libfdk-aac --enable-libfreetype --enable-libmp3lame \
--enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-libopus --enable-libxvid \
--samples=fate-suite/

make -j12
make install
}

buildMyFFmpeg