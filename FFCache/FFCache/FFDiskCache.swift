//
//  FFDiskCache.swift
//  FFCache
//
//  Created by json.wang on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

public class FFDiskCache: NSObject {
  
  private var diskQueue: DispatchQueue!
  private var cachePath: String!
  private let FFDiskCacheName = "FFDiskCache"
  
  static let shared: FFDiskCache = {
    let disk = FFDiskCache()
    disk.diskQueue = DispatchQueue(label: "com.onefboy.ffcache.disk")
    
    let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    disk.cachePath = "\(documentPath ?? "")/\(disk.FFDiskCacheName)"
    
    disk.createCacheDirectory()
    
    return disk
  }()
  
  private override init() {}
  
  // MARK: - Public Asynchronous Methods
  func removeAllObjects(_ block: @escaping ((FFDiskCache) -> Void)) {
    diskQueue.async {
      if FileManager.default.fileExists(atPath: self.cachePath) {
        let filePath = "file://" + self.cachePath
        
        guard let url = URL(string: filePath) else {
          #if DEBUG
            print("FFDiskCache PathError: \(filePath)")
          #else
          // TODO
          #endif
        
          block(self)
          return
        }
        
        do {
          try FileManager.default.removeItem(at: url)
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
        }
      }
      
      block(self)
    }
  }
  
  func removeObject(forKey key: String, block: @escaping ((FFDiskCache, String, Any?) -> Void)) {
    diskQueue.async {
      var object: Any?
      if self.hasCache(forKey: key) {
        let filePath = "file://" + self.cachePath + "/\(key).plist"
        
        guard let url = URL(string: filePath) else {
          #if DEBUG
            print("FFDiskCache PathError: \(filePath)")
          #else
          // TODO
          #endif
          block(self, key, object)
          return
        }
        
        var data: Data?
        do {
          data = try Data(contentsOf: url)
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
        }
        
        guard let tempData = data else {
          block(self, key, object)
          return
        }
        do {
          object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tempData)
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
        }
        
        do {
          try FileManager.default.removeItem(atPath: self.cachePath + "/\(key).plist")
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
        }
      } else {
        print("FFDiskCache Error: File not Exist")
      }
      
      block(self, key, object)
    }
  }
  
  private func data(forKey key: String, block: @escaping ((FFDiskCache, String, Data?) -> Void)) {
    diskQueue.async {
      var data: Data?
      
      if self.hasCache(forKey: key) {
        let filePath = "file://" + self.cachePath + "/\(key).plist"
        
        guard let url = URL(string: filePath) else {
          #if DEBUG
            print("FFDiskCache PathError: \(filePath)")
          #else
          // TODO
          #endif
          block(self, key, data)
          return
        }
        
        do {
          data = try Data(contentsOf: url)
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
        }
      }
      
      block(self, key, data)
    }
  }
  
  private func setData(_ data: Data, forKey key: String, block: @escaping ((FFDiskCache, String, Data?) -> Void)) {
    diskQueue.async {
      let filePath = "file://" + self.cachePath + "/\(key).plist"
      
      guard let url = URL(string: filePath) else {
        #if DEBUG
            print("FFDiskCache PathError: \(filePath)")
          #else
          // TODO
          #endif
        block(self, key, data)
        return
      }
      
      do {
        try data.write(to: url, options: .atomicWrite)
      } catch let error as NSError {
        #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
      }
      
      block(self, key, data)
    }
  }
  
  func object(forKey key: String, block: @escaping ((FFDiskCache, String, Any?) -> Void)) {
    data(forKey: key) { (cache, key, data) in
      var object: Any?
      
      guard let tempData = data else {
        block(self, key, object)
        return
      }
      
      do {
        object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tempData)
      } catch let error as NSError {
        #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
      }
      
      block(self, key, object)
    }
  }
  
  func setObject(_ object: Codable, forKey key: String, block: @escaping ((FFDiskCache, String, Any?) -> Void)) {
//    do {
      let data = NSKeyedArchiver.archivedData(withRootObject: object)
//      let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
      
      setData(data, forKey: key) { (cache, key, data) in
        block(self, key, object)
      }
//    } catch let error as NSError {
//            print("FFDiskCache Error: \(error.domain)")
//      block(self, key, object)
//    }
  }
  
  // MARK: - Public Synchronous Methods
  func removeAllObjects() {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeAllObjects { (cache) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  func removeObject(forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeObject(forKey: key) { (cache, key, object) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  private func data(forKey key: String) -> Data? {
    var tempData: Data?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    data(forKey: key) { (cache, key, data) in
      tempData = data
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return tempData
  }
  
  private func setData(_ data: Data, forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    setData(data, forKey: key) { (cache, key, data) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }

  func object(forKey key: String) -> Any? {
    var tempObject: Data?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    data(forKey: key) { (cache, key, object) in
      tempObject = object
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return tempObject
  }
  
  func setObject(_ object: Codable, forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    setObject(object, forKey: key) { (cache, key, object) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  // MARK: - Private Methods
  private func createCacheDirectory() {
    if !FileManager.default.fileExists(atPath: cachePath) {
      do {
        try FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
      } catch let error as NSError {
        #if DEBUG
            print("FFDiskCache Error: \(error.domain)")
          #else
          // TODO
          #endif
      }
    }
  }
  
  private func hasCache(forKey key: String) -> Bool {
    let filePath = cachePath + "/\(key).plist"
    if FileManager.default.fileExists(atPath: filePath) {
      return true
    }
    return false
  }
}
