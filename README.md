FFCache
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/onefboy/FFCache/blob/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/FFCache.svg?style=flat)](http://cocoapods.org/pods/FFCache)

Swift 缓存框架

使用说明
==============

### 基本数据类型

```swift
FFCache.shared.setObject(1024, forKey: "int")
let num = FFCache.shared.object(forKey: "int", ofType: Int.self)
```

### 字符串

```swift
FFCache.shared.setObject("哈哈", forKey: "string")
let string = FFCache.shared.object(forKey: "string", ofType: String.self)
```

### 自定义对象

```swift
let person = Person()

FFCache.shared.setObject(person, forKey: "person")

let data = FFCache.shared.object(forKey: "person", ofType: Person.self)
```

### 数组

```swift
FFCache.shared.setObject([person, person], forKey: "array")
let array = FFCache.shared.object(forKey: "array", ofType: [Person].self)
```

### 字典

```swift
FFCache.shared.setObject(["name": "onefboy"], forKey: "dict")
let dict = FFCache.shared.object(forKey: "dict", ofType: [String: String].self)
```

安装
==============

### CocoaPods

1. 在 Podfile 中添加 `pod 'FFCache', '~> 1.0.4'`。
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

