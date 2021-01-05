//
//  XTILoger.swift
//  XTInputKit
//    参考代码：https://github.com/honghaoz/Loggerithm
//    (仿写)
//  Created by xt-input on 2018/1/3.
//  Copyright © 2018年 Input. All rights reserved.
//

import UIKit

fileprivate let xtiloger = XTILoger()

public enum XTILogerLevel: Int {
    public typealias RawValue = Int

    case all = 0
    case info = 1
    case debug = 2
    case warning = 3
    case error = 4
    case off = 5
}

extension XTILogerLevel: Comparable {
    public static func < (lhs: XTILogerLevel, rhs: XTILogerLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: XTILogerLevel, rhs: XTILogerLevel) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: XTILogerLevel, rhs: XTILogerLevel) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }

    public static func > (lhs: XTILogerLevel, rhs: XTILogerLevel) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

/// 请在 "Swift Compiler - Custom Flags" 选项查找 "Other Swift Flags" 然后在DEBUG配置那里添加"-D DEBUG".
public class XTILoger {
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let dateShortFormatter = DateFormatter()

    /// 保存到日志文件的等级
    public var saveFileLevel = XTILogerLevel.warning
    /// 文件名字格式，支持Y(year)、WY(weekOfYear)、M(month)、D(day) 例如，以2018/3/21为例 "Y-WY"=>2018Y-12WY "Y-M-D"=>2018Y-3M-21D "Y-M"=>2018Y-3M，通过这类的组合可以构成一个日志文件保存一天、一周、一个月、一年等方式。建议使用"Y-WY" or "Y-M"，一定要用"-"隔开
    public var fileFormatter = "Y-WY"
    /// 是否打印时间戳
    public var isShowLongTime = true

    /// 是否打印日志等级
    public var isShowLevel = true
    /// 是否打印线程
    public var isShowThread = true
    /// release模式下默认打印日志的等级
    public var releaseLogLevel: XTILogerLevel!

    /// debug模式下默认打印日志的等级
    public var debugLogLevel: XTILogerLevel!

    /// 是否打印文件名
    public var isShowFileName = true

    /// 是否打印调用所在的函数名字
    public var isShowFunctionName = true

    /// 是否打印调用所在的行数
    public var isShowLineNumber = true

    private var logLevel: XTILogerLevel! {
        #if DEBUG
            return debugLogLevel
        #else
            return releaseLogLevel
        #endif
    }

    internal required init() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateShortFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateShortFormatter.dateFormat = "HH:mm:ss.SSS"
        debugLogLevel = XTILogerLevel.all
        releaseLogLevel = XTILogerLevel.warning
    }

    fileprivate func loger(format: String, _ args: [Any?]) -> String {
        guard let ranges = try? NSRegularExpression(pattern: "%*%", options: []) else {
            return ""
        }

        let matches = ranges.matches(in: format, options: [], range: NSRange(format.startIndex..., in: format))

        var value = ""
        var index = 0
        if args.isEmpty {
            return format
        }

        for i in 0 ..< matches.count {
            let len = (i < matches.count - 1 ? matches[i + 1].range.location : format.count) - matches[i].range.location
            let range = Range(NSMakeRange(matches[i].range.location, len), in: format)
            if let tempRange = range {
                var tempFormat = "\(format[tempRange])"
                if !tempFormat.hasPrefix("% ") && index < args.count {
                    let arg = args[index]
                    index = index + 1
                    if arg != nil, let cVarArg = arg as? CVarArg {
                        tempFormat = String(format: tempFormat, cVarArg)
                    } else {
                        tempFormat = String(describing: arg)
                    }
                }
                value = value + tempFormat
            }
        }
        return value
    }

    @discardableResult public static func info(format: String,
                                               function: String = #function,
                                               file: String = #file,
                                               line: Int = #line,
                                               _ args: Any?...) -> String {
        return xtiloger.log(.info, function: function, file: file, line: line, value: xtiloger.loger(format: format, args))
    }

    @discardableResult public static func info(_ value: Any?,
                                               function: String = #function,
                                               file: String = #file,
                                               line: Int = #line) -> String {
        return xtiloger.log(.info, function: function, file: file, line: line, value: value)
    }

    @discardableResult public static func debug(format: String,
                                                function: String = #function,
                                                file: String = #file,
                                                line: Int = #line,
                                                _ args: Any?...) -> String {
        return xtiloger.log(.debug, function: function, file: file, line: line, value: xtiloger.loger(format: format, args))
    }

    @discardableResult public static func debug(_ value: Any?,
                                                function: String = #function,
                                                file: String = #file,
                                                line: Int = #line) -> String {
        return xtiloger.log(.debug, function: function, file: file, line: line, value: value)
    }

    @discardableResult public static func warning(format: String,
                                                  function: String = #function,
                                                  file: String = #file,
                                                  line: Int = #line,
                                                  _ args: Any?...) -> String {
        return xtiloger.log(.warning, function: function, file: file, line: line, value: xtiloger.loger(format: format, args))
    }

    @discardableResult public static func warning(_ value: Any?,
                                                  function: String = #function,
                                                  file: String = #file,
                                                  line: Int = #line) -> String {
        return xtiloger.log(.warning, function: function, file: file, line: line, value: value)
    }

    @discardableResult public static func error(format: String,
                                                function: String = #function,
                                                file: String = #file,
                                                line: Int = #line,
                                                _ args: Any?...) -> String {
        return xtiloger.log(.error, function: function, file: file, line: line, value: xtiloger.loger(format: format, args))
    }

    @discardableResult public static func error(_ value: Any?,
                                                function: String = #function,
                                                file: String = #file,
                                                line: Int = #line) -> String {
        return xtiloger.log(.error, function: function, file: file, line: line, value: value)
    }

    /// 打印日志
    /// - Parameters:
    ///   - level: 日志等级
    ///   - format: 要打印的数据的结构
    ///   - args: 要打印的数据数组
    /// - Returns: 打印的内容
    fileprivate func log(_ level: XTILogerLevel,
                         function: String,
                         file: String,
                         line: Int,
                         value: Any?) -> String {
        if logLevel > level {
            return ""
        }

        let dateTime = isShowLongTime ? "\(dateFormatter.string(from: Date()))" : "\(dateShortFormatter.string(from: Date()))"
        var levelString = ""
        switch level {
        case .info:
            levelString = "[INFO\t]"
        case .debug:
            levelString = "[DEBUG\t]"
        case .warning:
            levelString = "[WARNING]"
        case .error:
            levelString = "[ERROR\t]"
        default:
            break
        }
        levelString = isShowLevel ? levelString : ""

        var fileString = ""
        if isShowFileName {
            fileString += "[" + (file as NSString).lastPathComponent
            if isShowLineNumber {
                fileString += ":\(line)"
            }
            fileString += "]"
        }
        if fileString.isEmpty && isShowLineNumber {
            fileString = "line:\(line)"
        }
        var functionString = isShowFunctionName ? function : ""

        let threadId = String(unsafeBitCast(Thread.current, to: Int.self), radix: 16, uppercase: false)
        let isMain = isShowThread ? Thread.current.isMainThread ? "[Main]" : "[Global]<0x\(threadId)>" : ""
        let infoString = "\(dateTime) \(levelString) \(fileString) \(isMain) \(functionString)".trimmingCharacters(in: CharacterSet(charactersIn: " "))

        var logString: String
        if let tempValue = value {
            logString = infoString + (infoString.isEmpty ? "" : " => ") + String(describing: tempValue)
        } else {
            logString = infoString + (infoString.isEmpty ? "" : " => ") + String(describing: value)
        }

        printToFile(level, log: logString)
        xt_print(logString)
        return logString + "\n"
    }

    /// 通过日志等级获取当前日志文件的路径
    /// - Parameter level: 日志等级
    /// - Returns: 文件路径
    public static func getCurrentLogFilePath(_ level: XTILogerLevel) -> String {
        let fileName = xtiloger.returnFileName(level)
        let logFilePath = getLogDirectory() + fileName
        if !FileManager.default.fileExists(atPath: logFilePath) {
            FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        }
        return logFilePath
    }

    /// 获取日志文件夹的路径，没有该文件夹就创建
    /// - Returns: 日志文件夹的路径
    public static func getLogDirectory() -> String {
        let logDirectoryPath = NSHomeDirectory() + "/Documents/XTILoger/"
        if !FileManager.default.fileExists(atPath: logDirectoryPath) {
            try? FileManager.default.createDirectory(atPath: logDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        return logDirectoryPath
    }

    /// 获取所有日志文件的路径
    /// - Returns: 所有日志文件的路径
    public static func getLogFilesPath() -> [String] {
        var filesPath = [String]()
        do {
            filesPath = try FileManager.default.contentsOfDirectory(atPath: getLogDirectory())
        } catch {}
        return filesPath
    }

    /// 清理日志文件
    /// - Returns: 操作结果
    @discardableResult public static func cleanLogFiles() -> Bool {
        getLogFilesPath().forEach { path in
            do { try FileManager.default.removeItem(atPath: self.getLogDirectory() + "/" + path) } catch {}
        }
        return getLogFilesPath().isEmpty
    }

    fileprivate func xt_print(_ string: String) {
        #if DEBUG
            print(string)
        #endif
    }

    fileprivate func printToFile(_ level: XTILogerLevel, log string: String) {
        if logLevel > level {
            return
        }
        let logFilePath = XTILoger.getCurrentLogFilePath(level)
        if FileManager.default.fileExists(atPath: logFilePath) {
            let writeHandler = FileHandle(forWritingAtPath: logFilePath)
            writeHandler?.seekToEndOfFile()
            if let data = ("\n" + string).data(using: String.Encoding.utf8) {
                writeHandler?.write(data)
            }
            writeHandler?.closeFile()
        } else {
            FileManager.default.createFile(atPath: logFilePath, contents: string.data(using: String.Encoding.utf8), attributes: nil)
        }
    }

    fileprivate func returnFileName(_ level: XTILogerLevel) -> String {
        var fileNameString = ""
        switch level {
        case .info:
            fileNameString = "info"
        case .debug:
            fileNameString = "debug"
        case .warning:
            fileNameString = "warning"
        case .error:
            fileNameString = "error"
        default:
            break
        }
        let dateComponents = Calendar.current.dateComponents(Set<Calendar.Component>.init(arrayLiteral: .year, .month, .day, .weekOfYear), from: Date())
        let fileFormatters = fileFormatter.components(separatedBy: "-")
        fileFormatters.forEach { string in
            switch string {
            case "D":
                fileNameString += "-\(dateComponents.day!)"
            case "WY":
                fileNameString += "-\(dateComponents.weekOfYear!)"
            case "M":
                fileNameString += "-\(dateComponents.month!)"
            case "Y":
                fileNameString += "-\(dateComponents.year!)"
            default:
                break
            }
        }
        fileNameString += ".log"
        return fileNameString
    }
}
