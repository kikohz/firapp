//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/22.
//

import Vapor

class ResponseWrapper<T:Codable>:Codable {
    private var code:ProtocolCode!
    private var msg :String = ""
    private var obj: T?
    
    init(protocolCode: ProtocolCode) {
        self.code = protocolCode
        self.msg = protocolCode.getMsg()
    }
    
    init(obj:T) {
        self.code = ProtocolCode.success
        self.obj = obj
        self.msg = ProtocolCode.success.getMsg()
    }
}
