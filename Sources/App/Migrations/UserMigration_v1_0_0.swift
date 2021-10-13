//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/16.
//

import Foundation
import Fluent
struct UserMigration_v1_0_0:Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("phone",.string,.required)
            .field("passwd",.string,.required)
            .field("nickname",.string)
            .unique(on: .phone, name: "phone")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
