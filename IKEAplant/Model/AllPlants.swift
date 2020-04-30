//
//  AllPlants.swift
//  IKEAplant
//
//  Created by Nastya Krouglova on 12/04/2019.
//  Copyright © 2019 Nastya Krouglova. All rights reserved.
//

import Foundation

class AllPlants {
    
    var plantList:String;
    var list: [Plant];
    
    init(plantList:String, list:[Plant]){
        self.plantList = plantList;
        self.list = list;
    }
}
