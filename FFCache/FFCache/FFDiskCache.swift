//
//  FFDiskCache.swift
//  FFCache
//
//  Created by onefboy on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

public class FFDiskCache: NSObject {
  
  private var diskQueue: DispatchQueue!
  private var cachePath: String!
  private let FFDiskCacheName = "FFDiskCache"
  
  public static let shared: FFDiskCache = {
    let disk = FFDiskCache()
    disk.diskQueue = DispatchQueue(label: "com.onefboy.ffcache.disk")
    
    let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    disk.cachePath = "\(documentPath ?? "")/\(disk.FFDiskCacheName)"
    
    disk.createCacheDirectory()
    
    return disk
  }()
  
  private override init() {}
  
  // MARK: - Public Asynchronous Methods
  public func removeAllObjectsAsync(_ block: @escaping ((FFDiskCache) -> Void)) {
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
            print("FFDiskCache removeAllObjectsAsync: \(error)")
          #else
          // TODO
          #endif
        }
      }
      
      block(self)
    }
  }
  
  public func removeObjectAsync(forKey key: String, block: @escaping ((FFDiskCache, String) -> Void)) {
    diskQueue.async {
      if self.hasCache(forKey: key) {
        do {
          try FileManager.default.removeItem(atPath: self.cachePath + "/\(key).plist")
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache removeObjectAsync: \(error)")
          #else
          // TODO
          #endif
        }
      } else {
        print("FFDiskCache Error: File not Exist")
      }
      
      block(self, key)
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
          block(self, key, nil)
          return
        }
        
        do {
          data = try Data(contentsOf: url)
        } catch let error as NSError {
          #if DEBUG
            print("FFDiskCache Error: \(error)")
          #else
          // TODO
          #endif
          block(self, key, nil)
          return
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
        return
      }
      
      do {
        try data.write(to: url, options: .atomicWrite)
      } catch let error as NSError {
        #if DEBUG
          print("FFDiskCache Error: \(error)")
        #else
        // TODO
        #endif
        return
      }
      
      block(self, key, data)
    }
  }
  
  public func objectAsync<T: Codable>(forKey key: String, ofType type: T.Type, block: @escaping ((FFDiskCache, String, T?) -> Void)) {
    data(forKey: key) { (cache, key, data) in
      var object: T?
      
      guard let tempData = data else {
        block(self, key, nil)
        return
      }
      
      do {
        let decoder = JSONDecoder()
        object = try decoder.decode(T.self, from: tempData)
      } catch _ as NSError {
//        #if DEBUG
//        print("FFDiskCache objectAsync: \(error)")
//        #else
//        // TODO
//        #endif
//        block(self, key, nil)
//        return
        
        do {
          if let temp = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tempData) as? T {
            object = temp
          }
        } catch let error as NSError {
          #if DEBUG
          print("FFDiskCache objectAsync: \(error.domain)")
          #else
          // TODO
          #endif
        }
      }
      
      block(self, key, object)
    }
  }
  
  public func setObjectAsync<T: Codable>(_ object: T, forKey key: String, block: @escaping ((FFDiskCache, String, T?) -> Void)) {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(object)
      setData(data, forKey: key) { (cache, key, data) in
        block(self, key, object)
      }
    } catch _ as NSError {
//      #if DEBUG
//      print("FFDiskCache setObjectAsync: \(error)")
//      #else
//      // TODO
//      #endif
//      block(self, key, nil)
      
      let data = NSKeyedArchiver.archivedData(withRootObject: object)
      setData(data, forKey: key) { (cache, key, data) in
        block(self, key, object)
      }
    }
  }
  
  // MARK: - Public Synchronous Methods
  public func removeAllObjects() {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeAllObjectsAsync { (cache) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  public func removeObject(forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeObjectAsync(forKey: key) { (cache, key) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }

  public func object<T: Codable>(forKey key: String, ofType type: T.Type) -> T? {
    var tempObject: T?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    objectAsync(forKey: key, ofType: type) { (cache, key, object) in
      tempObject = object
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return tempObject
  }
  
  public func setObject<T: Codable>(_ object: T, forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    setObjectAsync(object, forKey: key) { (cache, key, object) in
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
            print("FFDiskCache createCacheDirectory: \(error)")
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
