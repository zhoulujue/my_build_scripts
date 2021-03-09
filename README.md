# FFmpeg 交叉编译到 Android/iOS 的一些脚本
Cross compile build scripts for FFmpeg on Android Platform.

配合 https://github.com/zhoulujue/MyFFmpegAndroid 这个仓库使用

注意：除了 `ffmpeg_build_for_x86.sh` 与 `ffmpeg_build_for_android.sh` 两个脚本以外，其他文件均为编译时生成的。

## 如何使用这些脚本

- 同步FFmpeg代码后，将本仓库放至FFmpeg的源代码根目录下
- 根据脚本里的注释，修改脚本里 hard code 的一些目录名称
- 确认 Android ndk 和 iOS 开发环境是否ready
- 运行 ffmpeg_build_for_android.sh 脚本

## 注意

- config.h 在 https://github.com/zhoulujue/MyFFmpegAndroid 的 ffmpeg 目录下会用到，记得编译后拷贝过去
- src 是个软连接，由 ffmpeg 的 configure 生成
- 编译的log输出在 build.log 文件里
