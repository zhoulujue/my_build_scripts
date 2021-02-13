#!/bin/bash
export TMPDIR=/Users/lujuezhou/ffmpegbuilddir/temp
NDK=/Users/lujuezhou/Library/Android/sdk/ndk-bundle
# 交叉编译的根目录
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
# 编译产物前缀
PREFIX=/Users/lujuezhou/ffmpegbuilddir/ffmpeg-install-dir/android-arm

# --cross-prefix 前缀的文件夹，用来拼 nm、ar、as、strip等等cli工具的路径
TOOLCHAINS_DIR=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin
#TOOLCHAINS_DIR=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin


# NDK naming: armeabi-v7a arm64-v8a x86
# FFmpeg CPU naming:  armv7-a    armv8-a 
# FFmpeg arch naming: armv7-a    aarch64
# ARCH_OPTIONS="	--disable-neon --enable-asm --enable-inline-asm" # for armv7-a
ANDROID_API=21
COMMON_FLAGS=" -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID ${LTS_BUILD__FLAG}-D__ANDROID__ -D__ANDROID_API__=${ANDROID_API}"
FFMPEG_FLAGS=" -Wno-unused-function -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD -g"

# 用于链接时给ld用的lib
COMMON_LIBRARY_PATHS="-L${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/aarch64-linux-android/lib -L${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/aarch64-linux-android/${ANDROID_API} -L${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/lib"
COMMON_LINKED_LIBS="-lc -lm -ldl -llog ${COMMON_LIBRARY_PATHS}"
############################### 32位 ###############################
#TARGET_CPU="armv7-a"
#TARGET_ARCH="armv7-a"
#ARCH_OPTIONS="	--disable-neon --enable-asm --enable-inline-asm"
# 选择C compiler，默认是gcc，Android16及以上不能使用gcc了，要用ndk提供的clang
# clang、clang++都在ndk-bundle/toolchains/llvm/prebuilt/darwin-x86_64/bin目录下
#CC=$TOOLCHAINS_DIR/armv7a-linux-androideabi18-clang
#CXX=$TOOLCHAINS_DIR/armv7a-linux-androideabi18-clang++
#TOOL_CHAIN_PREFIX="arm-linux-androideabi"

# 填到gcc编译和链接相关的 cflags、ldflags的标志位
#ARCH_FLAGS=" -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -DMOBILE_FFMPEG_ARM_V7A"
####################################################################

############################### 64位 ###############################
TARGET_CPU="armv8-a"
TARGET_ARCH="aarch64"
ARCH_OPTIONS=" --enable-neon --enable-asm --enable-inline-asm"
export ac_cv_c_bigendian=no

# 64位arm的clang编译工具链最多支持到android21
CC=$TOOLCHAINS_DIR/aarch64-linux-android${ANDROID_API}-clang
CXX=$TOOLCHAINS_DIR/aarch64-linux-android${ANDROID_API}-clang++
TOOL_CHAIN_PREFIX="aarch64-linux-android-"

# 填到gcc编译和链接相关的 cflags、ldflags的标志位
ARCH_FLAGS=" -march=armv8-a -DMOBILE_FFMPEG_ARM64_V8A"
OPTIMIZATION_FLAGS="-flto -fuse-ld=gold -O2 -ffunction-sections -fdata-sections"
####################################################################

##################### 第三方库的pkg-config配置 ####################
export PKG_CONFIG_PATH=/Users/lujuezhou/Developer/CodeOnGithub/openh264
####################################################################

echo "Target CPU      : ${TARGET_CPU}"
echo "Target ARCH     : ${TARGET_ARCH}"
echo "Using cc        : ${CC}"
echo "Using cxx       : ${CXX}"
echo "Using strip     : ${TOOLCHAINS_DIR}/${TOOL_CHAIN_PREFIX}-strip"
echo "cross-prefix    : ${TOOLCHAINS_DIR}/${TOOL_CHAIN_PREFIX}"
echo "PKG_CONFIG_PATH : ${PKG_CONFIG_PATH}"

#清理一下log文件：
rm ./build.log

# gcc编译和链接相关的 cflags、ldflags
CXXFLAGS="-std=c++11 -fno-exceptions -fno-rtti -flto -O2 -ffunction-sections -fdata-sections"
LDFLAGS="${ARCH_FLAGS} ${OPTIMIZATION_FLAGS} ${COMMON_LINKED_LIBS} -Wl,--hash-style=both -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libunwind.a"

export CFLAGS="${ARCH_FLAGS} ${FFMPEG_FLAGS} ${OPTIMIZATION_FLAGS}"
export CXXFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS}"

function buildLibs
{
../configure \
--enable-cross-compile \
--cross-prefix="${TOOLCHAINS_DIR}/${TOOL_CHAIN_PREFIX}" \
--pkg-config="/usr/local/bin/pkg-config" \
--sysroot="${SYSROOT}" \
--prefix="${PREFIX}" \
--target-os=android \
--arch="${TARGET_ARCH}" \
--cpu="${TARGET_CPU}" \
${ARCH_OPTIONS} \
--cc="${CC}" \
--cxx="${CXX}" \
--nm="${TOOLCHAINS_DIR}/${TOOL_CHAIN_PREFIX}nm" \
--strip="${TOOLCHAINS_DIR}/${TOOL_CHAIN_PREFIX}strip" \
--enable-pic \
--enable-jni \
--enable-shared \
--disable-static \
--disable-doc \
--disable-htmlpages \
--disable-manpages \
--disable-podpages \
--disable-txtpages \
--disable-programs \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-postproc \
--disable-schannel \
--disable-securetransport \
--disable-xlib \
--disable-cuda \
--disable-cuvid \
--disable-nvenc \
--disable-vaapi \
--disable-vdpau \
--disable-videotoolbox \
--disable-audiotoolbox \
--disable-appkit \
--disable-alsa \
--disable-symver \
--enable-small \
--enable-gpl \
--extra-cflags="-marm ${CFLAGS}" \
--extra-cxxflags="${CXXFLAGS}" \
--extra-ldflags="${LDFLAGS}" \
1>>./build.log 2>&1
#--extra-libs="$(pkg-config --libs --static openh264)" \
#--enable-libopenh264 \


make clean
make -j8 1>>./build.log 2>&1
make install 1>>./build.log 2>&1
}

FFMPEG_SRC_ROOT=/Users/lujuezhou/Developer/CodeOnGithub/ffmpeg
BUILD_OUTPUT_DIR=/Users/lujuezhou/ffmpegbuilddir/ffmpeg-install-dir/android-arm
BUILD_OUTPUT_DIR_INCLUDE_DIR=${BUILD_OUTPUT_DIR}/include

rm -rf /Users/lujuezhou/ffmpegbuilddir/ffmpeg-install-dir/android-arm/*

buildLibs

# MANUALLY ADD REQUIRED HEADERS
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/x86
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/arm
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/aarch64
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavcodec/x86
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavcodec/arm
mkdir -p ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/compat

cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/compat/va_copy.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/compat
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/config.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavcodec/mathops.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavcodec
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavcodec/x86/mathops.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavcodec/x86
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavcodec/arm/mathops.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavcodec/arm
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavformat/network.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavformat
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavformat/os_support.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavformat
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavformat/url.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavformat
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/internal.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/libm.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/reverse.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/thread.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/timer.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/x86/asm.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/x86
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/x86/timer.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/x86
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/arm/timer.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/arm
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/aarch64/timer.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/aarch64
cp -f ${FFMPEG_SRC_ROOT}/my_build_scripts/src/libavutil/x86/emms.h ${BUILD_OUTPUT_DIR_INCLUDE_DIR}/libavutil/x86


export NDK_PROJECT_PATH=/Users/lujuezhou/Developer/CodeOnGithub/MyFFmpegAndroid/ffmpeg
APPLICATION_MK=/Users/lujuezhou/Developer/CodeOnGithub/MyFFmpegAndroid/ffmpeg/Application.mk
ANDROID_MK=/Users/lujuezhou/Developer/CodeOnGithub/MyFFmpegAndroid/ffmpeg/Android.mk

rm -rf /Users/lujuezhou/Developer/CodeOnGithub/MyFFmpegAndroid/app/libs/arm64-v8a
${NDK}/ndk-build -B NDK_APPLICATION_MK=${APPLICATION_MK} APP_BUILD_SCRIPT=${ANDROID_MK} 1>>./build.log 2>&1
cp -R $NDK_PROJECT_PATH/libs/arm64-v8a /Users/lujuezhou/Developer/CodeOnGithub/MyFFmpegAndroid/app/libs