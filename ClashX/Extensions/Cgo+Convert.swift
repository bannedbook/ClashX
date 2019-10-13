//
//  Cgo+Convert.swift
//  ClashX
//
//  Created by yicheng on 2019/10/2.
//  Copyright © 2019 west2online. All rights reserved.
//

extension String {
    func goStringBuffer() -> UnsafeMutablePointer<Int8> {
        return UnsafeMutablePointer<Int8>(mutating: withCString{$0})
    }
}


extension UnsafeMutablePointer where Pointee == Int8 {
    func toString() -> String{
        return String(cString: self)
    }
}

extension Bool {
    func goObject()->GoUint8 {
        return self == true ? 1 : 0
    }
}
