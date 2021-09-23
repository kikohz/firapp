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
    //创建用户
    func create(req:Request) throws ->EventLoopFuture<String> {
        let input = try req.content.decode(UserCreateObject.self)
        if input.phone.count <= 0 || input.passwd.count <= 0 {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        let user = UserModel()
        user.create(input)
        return user.create(on: req.db).map {
//            user.mapGet()
//            return ResponseWrapper(protocolCode: .success, obj: user).makeResponse()
            return ResponseWrapper(protocolCode: .success, obj: user, msg: "创建用户成功").makeResponse()
        }
    }
    //通过userid 也就是数据库主键来查找用户信息
    func get(req:Request) throws ->EventLoopFuture<String> {
        guard let userid = req.parameters.get("userid") as UUID? else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        return UserModel.find(userid, on: req.db).map { user ->String in
            guard let user = user else {
                return ResponseWrapper<DefaultResponseObj>(protocolCode: .failAccountNoExisted).makeResponse()
            }
            return ResponseWrapper(protocolCode: .success, obj: user).makeResponse()
        }
    }
    //通过手机号查询用户信息
    func userWithPhone(req:Request) throws ->EventLoopFuture<String> {
        let userFindInfo = try req.query.decode(UserFindObject.self)
        if userFindInfo.phone == nil {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        else {
            let sql = """
            SELECT * FROM userinfo WHERE phone = \(userFindInfo.phone ?? "")
            """
            return (req.db as! MySQLDatabase).sql().raw(SQLQueryString(sql)).all(decoding: UserModel.self).map {
                let obj = UserGetObject(phone: $0.first?.phone ?? "", nickname: $0.first?.nickname)
                return ResponseWrapper(protocolCode: .success, obj: obj).makeResponse()
            }
        }
    }
    //删除用户
    func delete(req:Request) throws ->EventLoopFuture<String> {
        guard let userid = req.parameters.get("userid") as UUID? else {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .failParamError).makeFutureResponse(req: req)
        }
        let user = UserModel()
        user.id = userid
        return user.delete(on: req.db).map {
            return ResponseWrapper<DefaultResponseObj>(protocolCode: .success).makeResponse()
        }
    }
}
