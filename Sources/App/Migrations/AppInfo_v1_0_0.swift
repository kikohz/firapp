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
            .field(.screenshot,.string,.required)
            .field(.filePath,.string)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AppInfo.schema).delete()
    }
}
