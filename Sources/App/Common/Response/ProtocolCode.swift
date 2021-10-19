//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/22.
//
enum ProtocolCode:Int, Codable {
    case unknow = 0
    case success = 200
    
    case failParamError = 400
    case failTokenInvalid = 401
    
    case failInternalError = 500
    
    case failAccountHasExisted = 10001
    case failAccountNoExisted = 10002
    case plistError = 100003
    
    case failArticleNoExisted = 20003
    
    func getMsg() ->String {
        return "\(self)"
    }
    
    func getCode() ->Int {
        return self.rawValue
    }
}
