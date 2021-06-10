//
//  SecurityElement.swift
//  AwDocReaderDemo
//
//  Created by Qingquan Zhao on 6/24/20.
//  Copyright © 2020 aware. All rights reserved.
//

import Foundation

class SecurityElement : Codable {
    
    var result : String?
    var elementType: Int?
    var diagnoseCode : Int?
    var lightIndex : Int?
    var percentValue : Int?
    var fragmentArea : FragmentArea?
    var locatedImageFragment: String?
    var expectedImagePattern: String?
    
}
