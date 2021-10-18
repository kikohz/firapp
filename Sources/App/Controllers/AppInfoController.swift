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
        if input.name.count <= 0 || input.desc.count <= 0 || input.platform.count <= 0 {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "参数错误，请检查").makeFutureResponse(req: req)
        }
        let appinfo = AppInfo()
        appinfo.create(input)
        return appinfo.create(on: req.db).map {
            appinfo.desc = ""            //内容太多，所以忽略掉
            appinfo.screenshot = ""      //内容太多，所以忽略掉
            appinfo.filePath = ""
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
            var appid:UUID
        }
        let input = try req.content.decode(Input.self)
        guard input .file.data.readableBytes > 0 else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "文件为空，请检查").makeFutureResponse(req: req)
        }
        let isExeFile = ["ipa","apk"].contains(input.file.extension?.lowercased())
        if !isExeFile {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError, msg: "请检查文件类型").makeFutureResponse(req: req)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "y-m-d-HH-MM-SS-"
        let prefix = formatter.string(from: .init())
        let fileName = prefix + input.file.filename
        let path = req.application.directory.publicDirectory + fileName
//        let path = fileName
        //更新数据库
        let tempInfo = AppInfo()
        tempInfo.filePath = fileName
        tempInfo.id = input.appid
        self.updateAppinfo(req: req, info: tempInfo)
//        _ = tempInfo.update(on: req.db)
        return req.application.fileio.openFile(path: path, mode: .write, flags: .allowFileCreation(posixMode: 0x744), eventLoop: req.eventLoop).flatMap { handle in
            req.application.fileio.write(fileHandle: handle, buffer: input.file.data, eventLoop: req.eventLoop).flatMapThrowing { _ in
                try handle.close()
            }
            .flatMap { _ in
                let fileObj = AppFileObject(filePath: fileName, infoPlistPath: nil)
                return ResponseWrapper(protocolCode: .success, obj:fileObj ,msg:"上传成功").makeFutureResponse(req: req)
            }
        }
    }
    
    
    //MARK - private 操作
    //更新app info
    fileprivate func updateAppinfo(req:Request, info:AppInfo) {
//        _ = info.update(on: req.db)
        _ = AppInfo.find(info.id, on: req.db).map({ appinfo in
            if let appinfo = appinfo  {
                appinfo.filePath = info.filePath
                _ = appinfo.save(on: req.db)
            }
        })
    }
    //生成plist 文件
    fileprivate func generatePlistFile(req:Request, info:AppInfo) {
        
    }
}



