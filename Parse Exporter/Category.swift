//
//  Category.swift
//  Parse Exporter
//
//  Created by Nick Dalke on 2/2/17.
//  Copyright © 2017 Nick Dalke. All rights reserved.
//

import Cocoa
import Parse

class Category: PFObject, PFSubclassing {

    static func parseClassName() -> String {
        return "Category"
    }
    
    @NSManaged var name : String!
    @NSManaged var icon : PFFile!
    
}
