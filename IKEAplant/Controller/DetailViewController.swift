//
//  DetailViewController.swift
//  IKEAplant
//
//  Created by Nastya Krouglova on 12/04/2019.
//  Copyright © 2019 Nastya Krouglova. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var plant: Plant!;
    var allPlants: AllPlants!;
    var currentItem: Int = 0;
    
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var country: UITextView!
    @IBOutlet weak var height: UITextView!
    @IBOutlet weak var plantable: UITextView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var temperature: UITextView!
    @IBOutlet weak var buttonAR: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentItem = plant!.id;
        
        showItemWith(index: self.currentItem);
        
        //default direction is right
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.state == .ended {
            switch sender.direction {
            case .left:
                print(self.currentItem);
                if ((self.currentItem + 1) >= allPlants.list.count - 1) {
                    self.currentItem = 0
                } else {
                    self.currentItem += 1
                }
                showItemWith(index: self.currentItem);
                
            case .right:
                print(self.currentItem);

                if ((self.currentItem - 1) <= 0) {
                    self.currentItem = allPlants.list.count - 1
                    
                } else {
                    self.currentItem -= 1
                }
                showItemWith(index: self.currentItem);
                
            default:
                break
            }
        }
    }
    
    func showItemWith(index:Int){
        let myPlant = allPlants.list[index];
        
        name.text = myPlant.plantName;
        number.text = myPlant.number;
        height.text = myPlant.height;
        
        if (myPlant.plantable == true) {
            plantable.text = "plantable";
            plantable.textColor = UIColor.darkGray;
            buttonAR.alpha = 1
        } else {
            plantable.text = "not plantable";
            plantable.textColor = UIColor.red;
            buttonAR.alpha = 0
        }
        country.text = myPlant.country;
        
        image.image = UIImage(named: myPlant.plantName.lowercased());
        price.text = myPlant.price;
        temperature.text = myPlant.temperature;
    }

    @IBAction func buttonToAR(_ sender: UIButton){
        self.currentItem += 1;
        print("dit is de currentItem uiteindelijk \(self.currentItem)")
        //performSegue(withIdentifier: "gotoAR", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAR"{
        let vc = segue.destination as! ViewController;
        vc.gettedId = self.currentItem;
        }
    }
}

