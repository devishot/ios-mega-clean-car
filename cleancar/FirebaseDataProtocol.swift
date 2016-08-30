//
//  FirebaseDataProtocol.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation


protocol FirebaseDataProtocol {
    var id: String { get }
    static var childRefName: String { get }
    
    func toDict(withId: Bool) -> NSMutableDictionary

}