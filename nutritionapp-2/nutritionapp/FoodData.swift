//
//  FoodData.swift
//  nutritionapp
//
//  Created by Anna-Maria Andreeva on 4/26/19.
//  Copyright © 2019 Yun, Yeji. All rights reserved.
//

import UIKit
import Foundation

protocol FoodDataProtocol
{
    func responseDataHandler(data:NSDictionary)
    func responseError(message:String)
}

class FoodData {
    private let urlSession = URLSession.shared
    private var dataTask:URLSessionDataTask? = nil
    var result = [Food] ()
    var nutri: nutrition = nutrition(calories: 0, carbs: 0, protein: 0, fat: 0, fiber: 0, sugar:0, measurement: "")
    private var _group:DispatchGroup = DispatchGroup()
    
    var group:DispatchGroup {
        get {return _group}
        set (newgroup) {_group = newgroup}
    }
    
    var delegate:FoodDataProtocol? = nil
    
    init(group: DispatchGroup) {
        self.group = group
    }
    //MARK : get data from API
    //first part to get food number, using keyword for user input
    func searchData (withSearch search:String){
        
        let base = "https://api.nal.usda.gov/ndb/search/?format=json&q="
        let urlPath = base + search + "&sort=r&max=25&api_key=8xqhEvNRGVoTehLPC1LKxUVLuCOlnI9rdkUGMy9N"
        let url:NSURL? = NSURL(string: urlPath)
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if let data = data {
                do{
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if let list = json["list"] as? NSDictionary {
                            let item = list["item"] as? NSMutableArray
                            //catch invalid response
                            if item == nil {self.delegate?.responseError(message: "data not found")
                                print("we got an error")
                                self.group.leave()
                            }
                            else{
                                //                                print (item!)
                                let count = item!.count
                                for i in 0...count-1 {
                                    let info = ((item![i]) as? NSDictionary)
                                    if info != nil {
                                        let name = ((info)!.value(forKey: "name") as! NSString)
                                        var objinfo = ((info)!.value(forKey: "manu") as! NSString)
                                        var name_array: [String] = name.components(separatedBy: ", ")
                                        let objectname = name_array[0]
                                        let number = info!.value(forKey: "ndbno") as!NSString
                                        if objinfo == "none"{
                                            objinfo = " "
                                        }
                                        let nutrient = nutrition(calories: 0, carbs: 0, protein: 0, fat: 0, fiber: 0, sugar:0, measurement: "")
                                        self.result.append(Food(name: objectname, info: objinfo as String, number: number as String, nutrients: nutrient))
                                        
                                    }
                                    else {
                                        self.delegate?.responseError(message: "data not found")
                                        print("we got an error")
                                        self.group.leave()
                                    }
                                }
                                self.group.leave()
                            }
                        }
                    }
                }
                    //invalid infos and input
                catch{
                    self.delegate?.responseError(message: "data not found")
                    print("we got an error")
                    self.group.leave()
                }
                
            }
        }
        dataTask.resume()
    }
    
    func reportData (withNumber number:String) {
        var calorie = 0
        var protein = 0
        var fat = 0
        var carbs = 0
        var fiber = 0
        var sugar = 0
        let base = "https://api.nal.usda.gov/ndb/reports/?ndbno="
        let urlPath = base + number + "&type=b&format=json&api_key=8xqhEvNRGVoTehLPC1LKxUVLuCOlnI9rdkUGMy9N"
        let url:NSURL? = NSURL(string: urlPath)
        let dataTask = self.urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if let data = data {
                do{
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if let report = json["report"] as? NSDictionary {
                            print(report)
                            let food = report["food"] as? NSDictionary
                            //catch invalid response
                            if food == nil {self.delegate?.responseError(message: "data not found")
                                print("we got an error")}
                            else{
                                //per 100 g
                                let nutrients = food!["nutrients"] as? NSMutableArray
                                if nutrients != nil {
                                    let nuts = nutrients!.count
                                    for i in 0...nuts-1{
                                        let en = nutrients![i] as! NSDictionary
                                        
                                        if en.value(forKey: "name") as! NSString == "Energy"{
                                            let energy = nutrients![i] as! NSDictionary
                                            let calories = energy.value(forKey: "value") as! NSString
                                            print(calories)
                                            //calories
                                            calorie = calories.integerValue
                                            //self.result[ind].calorie = cal
                                        }
                                        else if en.value(forKey: "name") as! NSString == "Protein"{
                                            let prot = nutrients![i] as! NSDictionary
                                            let proteins = prot.value(forKey: "value") as! NSString
                                            print(proteins)
                                            //protien
                                            protein = proteins.integerValue
                                        }
                                        else if en.value(forKey: "name") as! NSString == "Total lipid (fat)"{
                                            let lipid = nutrients![i] as! NSDictionary
                                            let fats = lipid.value(forKey: "value") as! NSString
                                            print(fats)
                                            //fat
                                            fat = fats.integerValue
                                        }
                                        else if en.value(forKey: "name") as! NSString == "Carbohydrate, by difference"{
                                            let carb = nutrients![i] as! NSDictionary
                                            let carbss = carb.value(forKey: "value") as! NSString
                                            print(carbss)
                                            //carbs
                                            carbs = carbss.integerValue
                                        }
                                        else if en.value(forKey: "name") as! NSString == "Fiber, total dietary"{
                                            let fib = nutrients![i] as! NSDictionary
                                            let fibers = fib.value(forKey: "value") as! NSString
                                            print(fibers)
                                            //carbs
                                            fiber = fibers.integerValue
                                        }
                                        else if en.value(forKey: "name") as! NSString == "Sugars, total"{
                                            let sug = nutrients![i] as! NSDictionary
                                            let sugars = sug.value(forKey: "value") as! NSString
                                            print(sugars)
                                            //carbs
                                            sugar = sugars.integerValue
                                        }
                                            
                                        else{
                                            continue
                                        }
                                    }
                                    
                                    self.nutri = nutrition(calories: calorie, carbs: carbs, protein: protein, fat: fat, fiber: fiber, sugar:sugar, measurement: "100g")
                                    
                                }
                                    
                                    
                                    
                                    
                                else {
                                    self.delegate?.responseError(message: "data not found")
                                    print("we got an error")
                                    
                                }
                                
                            }
                        }
                    }
                }
                    
                    
                    //invalid infos and input
                catch{
                    self.delegate?.responseError(message: "data not found")
                    print("we got an error")
                }
                
            }
        }
        dataTask.resume()
    }
}
