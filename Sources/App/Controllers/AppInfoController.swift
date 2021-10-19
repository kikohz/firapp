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
    
    //MARK - private 操作
    //更新app info
    fileprivate func updateAppinfo(req:Request, info:AppInfo) {
        _ = AppInfo.query(on: req.db).filter(\.$bid == info.bid).first().map({ appinfo in
            if let appinfo = appinfo  {
                appinfo.filePath = info.filePath
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
        let softPackage = ["kid":"software-package","url":ipaurl]
        let iconDsNode:[String:Any] = ["kid":"display-image","needs-shine":false,"url":iconUrl]
        let assets = [softPackage,iconDsNode]
        let metadata:[String:Any] = ["bundle-identifier":appinfo.bundleId ,"bundle-version":appVersion,"kind":"software","title":appinfo.name]
        let plistInfo:[String:Any] = ["assets":assets,"metadata":[metadata]]
        let plistRoot = ["items":plistInfo]
        let data = try PropertyListSerialization.data(fromPropertyList: plistRoot, format: .xml, options: 0)
        try data.write(to: URL(fileURLWithPath: plistFilePath))
    }
    
//    fileprivate func generatePlistFile(req:Request, info:AppInfo) throws ->String {
//        let host = "https://arm.bllgo.com"
//        let ipaurl = host + info.filePath!
//        let path = host + "/file/\(info.bid).plist"
//        _ = AppInfo.query(on: req.db).filter(\.$bid == info.bid).first().map { appinfo in
//            if appinfo != nil {
//                let iconUrl = ""
//                let appVersion = "1.0.0"
//                let softPackage = ["kid":"software-package","url":ipaurl]
//        //        let iconNode:[String:Any] = ["kid":"full-size-image","needs-shine":false,"url":iconUrl]
//                let iconDsNode:[String:Any] = ["kid":"display-image","needs-shine":false,"url":iconUrl]
//                let assets = [softPackage,iconDsNode]
//                let metadata:[String:Any] = ["bundle-identifier":appinfo?.bundleId ?? "","bundle-version":appVersion,"kind":"software","title":appinfo?.name ?? ""]
//                let plistInfo:[String:Any] = ["assets":assets,"metadata":[metadata]]
//                let plistRoot = ["items":plistInfo]
//                do{
//                    let data = try PropertyListSerialization.data(fromPropertyList: plistRoot, format: .xml, options: 0)
//                    try data.write(to: URL(fileURLWithPath: path))
//                }
//                catch {
//                }
//            }
//        }
//        return path
//    }
}



