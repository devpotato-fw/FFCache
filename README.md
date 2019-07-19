FFCache
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/onefboy/FFCache/blob/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/FFCache.svg?style=flat)](http://cocoapods.org/pods/FFCache)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/FFCache.svg?style=flat)](http://cocoadocs.org/docsets/FFCache)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%206%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/ios-9/)

Swift 缓存框架

特性
==============
- **LRU**: 缓存支持 LRU (least-recently-used) 淘汰算法。
- **缓存控制**: 支持多种缓存控制方法：总数量、总大小、存活时间、空闲空间。
- **兼容性**: API 基本和 `NSCache` 保持一致, 所有方法都是线程安全的。
- **内存缓存**
  - **对象释放控制**: 对象的释放(release) 可以配置为同步或异步进行，可以配置在主线程或后台线程进行。
  - **自动清空**: 当收到内存警告或 App 进入后台时，缓存可以配置为自动清空。
- **磁盘缓存**
  - **可定制性**: 磁盘缓存支持自定义的归档解档方法，以支持那些没有实现 NSCoding 协议的对象。
  - **存储类型控制**: 磁盘缓存支持对每个对象的存储类型 (SQLite/文件) 进行自动或手动控制，以获得更高的存取性能。


安装
==============

### CocoaPods

1. 在 Podfile 中添加 `pod 'FFCache', '~> 1.0.0'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 FFCache。


### 手动安装

1. 下载 FFCache 文件夹内的所有内容。
2. 将 FFCache 内的源文件添加(拖放)到你的工程。
3. 导入 `FFCache`。


系统要求
==============
该项目最低支持 `iOS 9.0` 和 `Xcode 10.2.1`。


许可证
==============
YYCache 使用 MIT 许可证，详情见 LICENSE 文件。

