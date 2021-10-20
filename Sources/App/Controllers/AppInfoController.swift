//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Fluent
import Vapor
import MySQLKit
import Foundation

struct AppInfoController {
    // MARK - endpoints
    //发布应用--也就是上传应用信息
    func publish(req:Request) throws ->EventLoopFuture<String> {
//        req.logger.info(req.description)
        let input = try req.content.decode(AppInfpCreateObject.self)
        if input.name.count <= 0 || input.desc.count <= 0 || input.platform.count <= 0 || input.bundleId.count <= 0 {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "参数错误，请检查").makeFutureResponse(req: req)
        }
        let appinfo = AppInfo()
        appinfo.create(input)
        return appinfo.create(on: req.db).map {
            appinfo.desc = ""            //内容太多，所以忽略掉
            appinfo.screenshot = ""      //内容太多，所以忽略掉
            appinfo.filePath = ""
            appinfo.plistPath = ""
            return ResponseWrapper(protocolCode: .success, obj: appinfo, msg: "应用发布成功").makeResponse()
        }
    }
    
    //获取应用信息
    func appInfo(req:Request) throws ->EventLoopFuture<String> {
        guard let appid = req.parameters.get("appid") as UUID?   else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError,msg: "参数错误，请检查").makeFutureResponse(req: req)
        }
        return AppInfo.find(appid, on: req.db).map { info in
            guard let info = info else {
                return ResponseWrapper<DefaultResponseObj>(protocolCode: .failAccountNoExisted, msg: "没有找到数据").makeResponse()
            }
            return ResponseWrapper(protocolCode: .success, obj: info,msg:"请求成功").makeResponse()
        }
    }
    //通过bid获取应用信息
    func appInfoWithBid(req:Request) throws->EventLoopFuture<String> {
        guard let bid = req.parameters.get("bid") as String? else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError,msg: "参数错误，请检查").makeFutureResponse(req: req)
        }
        return AppInfo.query(on: req.db).filter(\.$bid == bid).first().map {appinfo in
            guard let info = appinfo else {
                return ResponseWrapper<DefaultResponseObj>(protocolCode: .failAccountNoExisted, msg: "没有找到数据").makeResponse()
            }
            return ResponseWrapper(protocolCode: .success, obj: info,msg:"请求成功").makeResponse()
        }
    }
    
    //获取应用列表
    func fetchAll(req:Request) throws ->EventLoopFuture<String> {
        req.logger.info("fetchAll")
        return AppInfo.query(on: req.db).all().map { appList in
            return ResponseWrapper(protocolCode: .success, obj: appList,msg:"请求成功").makeResponse()
        }
    }
    //上传安装包
    func uploadFile(req:Request) throws ->EventLoopFuture<String> {
        struct Input:Content{
            var file:File
//            var appid:UUID
            var bid:String
        }
        let input = try req.content.decode(Input.self)
        guard input .file.data.readableBytes > 0 else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "文件为空，请检查").makeFutureResponse(req: req)
        }
        let isExeFile = ["ipa","apk"].contains(input.file.extension?.lowercased())
        if !isExeFile {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "请检查文件类型").makeFutureResponse(req: req)
        }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "y-m-d-HH-MM-SS-"
        let prefix = String(format:"%.0f", Date().timeIntervalSince1970)
//        let prefix = formatter.string(from: .init())
        let fileName = prefix + input.file.filename
        let path = req.application.directory.publicDirectory + fileName
        //更新数据库
        let tempInfo = AppInfo()
        tempInfo.filePath = "/file/" + fileName
        tempInfo.plistPath = "/file/\(input.bid).plist"
        tempInfo.bid = input.bid
        self.updateAppinfo(req: req, info: tempInfo)
        return req.application.fileio.openFile(path: path, mode: .write, flags: .allowFileCreation(posixMode: 0x744), eventLoop: req.eventLoop).flatMap { handle in
            req.application.fileio.write(fileHandle: handle, buffer: input.file.data, eventLoop: req.eventLoop).flatMapThrowing { _ in
                try handle.close()
            }
            .flatMap { _ in
                let fileObj = AppFileObject(filePath: tempInfo.filePath, infoPlistPath: tempInfo.plistPath)
                return ResponseWrapper(protocolCode: .success, obj:fileObj ,msg:"上传成功").makeFutureResponse(req: req)
            }
        }
    }
    
    //删除应用
    func delete(req:Request) throws ->EventLoopFuture<String> {
        let deleteInfo = try req.query.decode(AppDeleteObj.self)
        guard deleteInfo.appid != nil else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError,msg: "参数错误，请检查").makeFutureResponse(req: req)
        }
        let info = AppInfo()
        info.id = deleteInfo.appid
        return info.delete(on: req.db).map {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .success, msg: "删除成功").makeResponse()
        }
    }
    
    //MARK - private 操作
    //更新app info
    fileprivate func updateAppinfo(req:Request, info:AppInfo) {
        _ = AppInfo.query(on: req.db).filter(\.$bid == info.bid).first().map({ appinfo in
            if let appinfo = appinfo  {
                appinfo.filePath = info.filePath
                appinfo.plistPath = info.plistPath
                _ = appinfo.save(on: req.db)
                //iOS 需要生成 plist文件
                if appinfo.platform == "iOS" {
                    let path = req.application.directory.publicDirectory + "\(info.bid).plist"
                    do{
                        try self.generatePlistFile(plistFilePath: path, appinfo: appinfo)
                    }
                    catch {}
                }
            }
        })
    }
    //生成plist 文件
    fileprivate func generatePlistFile(plistFilePath:String, appinfo:AppInfo) throws{
        let host = Environment.get("SERVICE_HOST") ?? "https://fir.bllgo.com"
        let ipaurl = host + appinfo.filePath!
        let iconUrl = appinfo.icon
        let appVersion = "1.0.0"
        let plistStr = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>items</key>
                <array>
                    <dict>
                        <key>assets</key>
                        <array>
                            <dict>
                                <key>kind</key>
                                <string>software-package</string>
                                <key>url</key>
                                <string>\(ipaurl)</string>
                            </dict>
                            <dict>
                                 <key>kind</key>
                                 <string>display-image</string>
                                 <key>need-shine</key>
                                 <integer>0</integer>
                                 <key>url</key>
                                 <string>\(iconUrl)</string>
                            </dict>
                        </array>
                        <key>metadata</key>
                        <dict>
                            <key>bundle-identifier</key>
                            <string>\(appinfo.bundleId)</string>
                            <key>bundle-version</key>
                            <string>\(appVersion)</string>
                            <key>kind</key>
                            <string>software</string>
                            <key>subtitle</key>
                            <string>在线安装</string>
                            <key>title</key>
                            <string>\(appinfo.name)</string>
                        </dict>
                    </dict>
                </array>
            </dict>
        </plist>
        """
        try plistStr.write(toFile: plistFilePath, atomically: true, encoding: .utf8)
//        let softPackage = ["kid":"software-package","url":ipaurl]
//        let iconDsNode:[String:Any] = ["kid":"display-image","needs-shine":false,"url":iconUrl]
//        let assets = [softPackage,iconDsNode]
//        let metadata:[String:Any] = ["bundle-identifier":appinfo.bundleId ,"bundle-version":appVersion,"kind":"software","title":appinfo.name]
//        let plistInfo:[String:Any] = ["assets":assets,"metadata":metadata]
//        let plistS = [plistInfo]
//        let plistRoot = ["items":plistS]
//
//        let data = try PropertyListSerialization.data(fromPropertyList: plistRoot, format: .xml, options: 0)
//        try data.write(to: URL(fileURLWithPath: plistFilePath))
    }
}



