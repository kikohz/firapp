//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Foundation
import Fluent
struct AppInfo_v1_0_0:Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AppInfo.schema)
            .id()
            .field(.name,.string,.required)
            .field(.desc,.string,.required)
            .field(.screenshot,.string)
            .field(.filePath,.string)
            .field(.plistPath,.string)
            .field(.platform,.string,.required)
            .field(.icon,.string,.required)
            .field(.bundleId,.string,.required).unique(on: .bundleId)   //unique添加约束 没有重复值
            .field(.bid,.string,.required)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AppInfo.schema).delete()
    }
}
