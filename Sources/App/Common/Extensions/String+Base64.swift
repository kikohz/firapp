//
//  File.swift
//  
//
//  Created by Bllgo on 2021/10/11.
//

import Foundation

extension String {
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
