//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Fluent
import Vapor
import MySQLKit

struct UserController {
    // MARK - endpoints
    
    //用户登录
    func login(req:Request) throws ->EventLoopFuture<String> {
        do {
            let user = try req.auth.require(User.self)
            req.auth.login(user)
            //登录成功返回数据库中对应的token
            return UserToken.query(on: req.db).filter(\.$user.$id == user.id!).first().map {
                if let usertoken = $0 {
                    return ResponseWrapper(protocolCode: .success, obj: usertoken, msg: "登录成功").makeResponse()
                }
                else {
                    return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "登录失败，请检查您的登录信息").makeResponse()
                }
            }
        }
        catch {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "登录失败，请检查您的登录信息").makeFutureResponse(req: req)
        }
        //自己做验证
//        guard let basic = req.headers.basicAuthorization else {
//            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
//        }
//        return User.query(on: req.db)
//            .filter(\.$phone == basic.username)
//            .first()
//            .map {
//                do {
//                    if let user = $0, try Bcrypt.verify(basic.password, created: user.passwd) {
//                        req.auth.login(user)
//                        return ResponseWrapper(protocolCode: .success, obj: user, msg: "登录成功").makeResponse()
//                    }
//                    else {
//                        return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "登录失败，请检查您的登录信息").makeResponse()
//                    }
//                }
//                catch {
//                    // do nothing...
//                    return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "登录失败，请检查您的登录信息").makeResponse()
//                }
//            }
    }
    
    //注册用户
    func register(req:Request) throws ->EventLoopFuture<String> {
        do{
            try User.Create.validate(content: req)
            let input = try req.content.decode(User.Create.self)
            let user = User()
            try user.create(input,req)
            
            return user.create(on: req.db).map {
                
                do{
                    let token = try user.generateToken()     //生成token
                    _ = token.save(on: req.db).map{
                        ResponseWrapper(protocolCode: .success, obj: user, msg: "创建用户成功").makeResponse()}
                    return ResponseWrapper(protocolCode: .success, obj: token, msg: "创建用户成功").makeResponse()
                }
                catch{
                    return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeResponse()
                }
            }
        }
        catch {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
    }
    //通过用户token来返回用户信息
    func getUserinfo(req:Request) throws ->EventLoopFuture<String> {
        do{
            let user = try req.auth.require(User.self)
            user.passwd = ""
            return ResponseWrapper(protocolCode: .success, obj: user, msg: "获取用户信息成功").makeFutureResponse(req: req)
        }
        catch {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "认证失败，您的token已经失效").makeFutureResponse(req: req)
        }
    }
    
    
//------------------------------------------下面的根据业务逻辑暂时不对外开放，也没有做登录token认证-------------------------------
    //通过userid 也就是数据库主键来查找用户信息
    func get(req:Request) throws ->EventLoopFuture<String> {
        guard let userid = req.parameters.get("userid") as UUID? else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        return User.find(userid, on: req.db).map { user ->String in
            guard let user = user else {
                return ResponseWrapper<DefaultResponseObj>(protocolCode: .failAccountNoExisted).makeResponse()
            }
            return ResponseWrapper(protocolCode: .success, obj: user).makeResponse()
        }
    }
    //通过手机号查询用户信息
    func userWithPhone(req:Request) throws ->EventLoopFuture<String> {
        do{
            _ = try req.auth.require(UserToken.self)
            let userFindInfo = try req.query.decode(User.Find.self)
            guard userFindInfo.phone != nil else {
                return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
            }
            return User.query(on: req.db).filter(\.$phone == userFindInfo.phone!).first().map { user in
                user?.passwd = ""
                return ResponseWrapper(protocolCode: .success, obj: user).makeResponse()
                //直接执行sql语句方式查询
                //            let sql = """
                //            SELECT * FROM userinfo WHERE phone = \(userFindInfo.phone ?? "")
                //            """
                //            return (req.db as! MySQLDatabase).sql().raw(SQLQueryString(sql)).all(decoding: User.self).map {
                //                let obj = User.Get(phone: $0.first?.phone ?? "", nickname: $0.first?.nickname)
                //                return ResponseWrapper(protocolCode: .success, obj: obj).makeResponse()
                //            }
            }
        }
        catch{
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failTokenInvalid, msg: "登录失败，请检查您的登录信息").makeFutureResponse(req: req)
        }
    }
    //删除用户
    func delete(req:Request) throws ->EventLoopFuture<String> {
        guard let userid = req.parameters.get("userid") as UUID? else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        let user = User()
        user.id = userid
        return user.delete(on: req.db).map {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .success).makeResponse()
        }
    }
}
