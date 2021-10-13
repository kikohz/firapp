//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Vapor
struct UserRouter:RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userController = UserController()
        let v1Routes = routes.grouped("v1")
        //注册
        v1Routes.post("register", use: userController.register(req:))
        
        //登录
        let passwordProtected = v1Routes.grouped(User.authenticator())
        passwordProtected.post("login", use: userController.login(req:))
        
        //查找-通过登录token获取用户信息
        let tokenProtected = v1Routes.grouped(UserToken.authenticator())
        tokenProtected.get("userinfo", use: userController.getUserinfo(req:))
        
        
        
        
        //-----------------------测试用到--------------------------------
        //respods to GET /user/xxxx
        routes.get("user",":userid", use: userController.get(req:))
        
        //respods to GET /user/phone=xxx
        routes.get("user", use: userController.userWithPhone(req:))
        
        routes.on(.DELETE, "user", use: userController.delete(req:))
    }
}
