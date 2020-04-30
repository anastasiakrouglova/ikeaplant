//
//  HomeViewController.swift
//  IKEAplant
//
//  Created by Nastya Krouglova on 16/04/2019.
//  Copyright © 2019 Nastya Krouglova. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var plants:AllPlants?
    var plant: Plant?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         loadJSON()
    }
    
    // MARK: JSON INLADEN
    func loadJSON(){
        let url = Bundle.main.url(forResource: "plants", withExtension: "json")
            
        if let path = url{
            do {
                let data = try Data(contentsOf: path)
                let result = try JSON(data: data)
                parseJSON(json: result)
            } catch{
                print("ERROR: JSON DATA CAN NOT BE LOADED")
                }
        } else {
            print("ERROR: PATH TO JSON IS NOT CORRECT")
        }
    }
        
    func parseJSON(json: JSON){
        var tempList:[Plant] = [];
        for (_,subJSON) in json["plants"]{
            let item: Plant = Plant(id: subJSON["id"].intValue, plantName: subJSON["plantName"].stringValue, price: subJSON["price"].stringValue,temperature: subJSON["temperature"].stringValue, plantable: subJSON["plantable"].boolValue, height: subJSON["height"].stringValue, number: subJSON["number"].stringValue, country: subJSON["country"].stringValue)
            tempList.append(item)
        }
        plants = AllPlants(plantList: json["plantList"].stringValue, list: tempList)
        print(tempList.count)
    }
    
    
    // MARK: DATASOURCE METHODS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants!.list.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! PlantsCollectionViewCell
        
        myCell.image.image = UIImage(named: plants!.list[indexPath.item].plantName.lowercased())
        myCell.name.text = plants!.list[indexPath.item].plantName
        myCell.price.text = plants!.list[indexPath.item].price
        
        return myCell;
    }
    
    
    // MARK: DELEGATE METHODS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print ( "user interactie on cell: \(indexPath.item) " )
        performSegue(withIdentifier: "gotoDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDetail"{
            let vc = segue.destination as! DetailViewController;
            let index = (sender as! IndexPath).item;
            let selectedPlant = plants?.list[index];
            vc.plant = selectedPlant;
            vc.allPlants = plants;
        }
    }
}

