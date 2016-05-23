//
//  main.swift
//  zipline
//
//  Created by Adam Nemecek on 5/18/16.
//  Copyright © 2016 Adam Nemecek. All rights reserved.
//

import Foundation

func printErr(string: String, newLine: Bool = true) {
  if newLine {
    fputs(string + "\n", stderr)
  }
  else {
    fputs(string, stderr)
  }
}

func *(string: String, factor: Int) -> String {
  return [String](count: factor, repeatedValue: string).reduce("", combine: +)
}

func input() -> String {
  let keyboard = NSFileHandle.fileHandleWithStandardInput()
  let inputData = keyboard.availableData
  return NSString(data: inputData, encoding:NSUTF8StringEncoding) as! String
}

extension String {
  func trim() -> String {
    return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      .stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
  }
}

extension NSFileManager {
  static var pwd: String {
    return defaultManager().currentDirectoryPath
  }

  static func dirExistsAtPath(path: String) -> Bool {
    var directory: ObjCBool = ObjCBool(false)
    return defaultManager().fileExistsAtPath(path, isDirectory: &directory) && directory
  }

  static func gitAtPath(path: String) -> Bool {
    let p = NSString.pathWithComponents([path, ".git"])
    return dirExistsAtPath(p)
  }
}

struct ZipLine: CollectionType {
  let components: [String]

  init(path: String? = nil) {
    let p = path ?? NSFileManager.pwd
    self.components = (p as NSString).pathComponents
  }

  var startIndex: Int {
    return 0
  }

  var endIndex: Int {
    return components.endIndex
  }

  var lastIndex: Int {
    return endIndex - 1
  }

  subscript (idx: Int) -> String {
    return components[idx]
  }

  subscript (bounds: Range<Int>) -> String {
    let pathComponents =  [String](components[bounds])

    return NSString.pathWithComponents(pathComponents) as String
  }

  func displayGen() -> AnyGenerator<(Int, String, Bool)> {
    var g = generate()
    var choice = lastIndex

    return AnyGenerator {
      defer {
        choice -= 1
      }

      return g.next().map {
        (choice, $0, NSFileManager.gitAtPath($0))
      }
    }
  }

  func displayPaths() {
    for (idx, (choice, path, git)) in displayGen().enumerate() {
      let spaceString = " " * idx
      var s = "\(spaceString) \(choice): \(path)"
      if git {
        s += "    (git)"
      }
      printErr(s)
    }
  }

  func getLevel() -> Int? {
    printErr("Zipline to [\(startIndex)-\(lastIndex)]: ", newLine: false)

    let i = input().trim()
    if let input = Int(i) where indices.contains(input) {
      return lastIndex - input
    }

    printErr("The input should be between [\(startIndex)-\(lastIndex)]")
    return nil
  }

  func promptUser() -> Int? {
    printErr("Which directory do you want to zipline to?")
    displayPaths()
    while true {
      if let choice = getLevel() {
        return choice
      }
    }
  }
}

func zipLine() {
  let z = ZipLine(path: nil)
  if let input = z.promptUser() {
    let path = z[0...input]
    print(path)
  }
}

zipLine()




