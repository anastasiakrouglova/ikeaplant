//
//  Plant.swift
//  IKEAplant
//
//  Created by Nastya Krouglova on 12/04/2019.
//  Copyright © 2019 Nastya Krouglova. All rights reserved.
//

import Foundation

class Plant {
    var id: Int;
    var plantName:String;
    var price:String;
    var temperature:String;
    var plantable: Bool;
    var height: String;
    var number: String;
    var country: String;
    
    
    init(id:Int, plantName:String, price:String, temperature:String, plantable: Bool, height: String, number: String, country: String){
        self.id = id;
        self.plantName = plantName;
        self.price = price;
        self.temperature = temperature;
        self.plantable = plantable;
        self.height = height;
        self.number = number;
        self.country = country;
    }
}
