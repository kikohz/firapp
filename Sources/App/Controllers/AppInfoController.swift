//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Fluent
import Vapor
import MySQLKit

struct AppInfoController {
    // MARK - endpoints
    //发布应用--也就是上传用户信息
    func publish(req:Request) throws ->EventLoopFuture<String> {
        let input = try req.content.decode(AppInfpCreateObject.self)
        if input.name.count <= 0 || input.desc.count <= 0 || input.scteenshot.count <= 0 {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        let appinfo = AppInfo()
        appinfo.create(input)
        return appinfo.create(on: req.db).map {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .success, msg: "应用发布成功").makeResponse()
        }
    }
    
//    func uploadFile(req:Request) throws ->EventLoopFuture<String> {
//        return "上传成功"
//    }
}



