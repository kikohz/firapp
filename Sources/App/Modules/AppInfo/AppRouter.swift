//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Vapor
struct AppRouter:RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appinfo = AppInfoController()
        let v1Routes = routes.grouped("v1")
        v1Routes.post("publish", use: appinfo.publish(req:))
        v1Routes.get("appinfo",":appid", use: appinfo.appInfo(req:))
        v1Routes.get("appinfo",":bid", use: appinfo.appInfoWithBid(req:))
        
        v1Routes.on(.POST, "upload", body: .collect(maxSize: "100mb"), use: appinfo.uploadFile(req:))
        v1Routes.get("allapp", use: appinfo.fetchAll(req:))
//        v1Routes.post("upload", use: appinfo.uploadFile(req:))
         //测试页面
        v1Routes.get("uploadtest") { req ->EventLoopFuture<View> in
            req.leaf.render("result")
        }
    }
}
