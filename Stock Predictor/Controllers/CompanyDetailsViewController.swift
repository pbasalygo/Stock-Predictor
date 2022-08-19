//
//  CompanyDetailsViewController.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 17/05/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Swifter
import SwiftyJSON
import CoreML

class CompanyDetailsViewController: UIViewController {

    @IBOutlet weak var PredictionLabel: UILabel!
    @IBOutlet weak var MakePredictionButton: UIBarButtonItem!
    @IBOutlet weak var StockPriceLabel: UILabel!
    @IBOutlet weak var ShortNameLabel: UILabel!
    @IBOutlet weak var FullNameLabel: UILabel!
    var addingManager = AddingManager()
    let classifier  = TwitterSentimentClassifier2()
    let swifter = Swifter(consumerKey: "dV9FhPEYEou5jMDvdquR0BxN2", consumerSecret: "bStNOFvlxo5BYsWoKLlGgP6DIApwF8hIu7h79yo3Wu2y0A7ZdL")
    let db  = Firestore.firestore()
    let currentUserEmail = Auth.auth().currentUser?.email
    var companyName:String = "empty"
    var compShort:String = "empty"
    var userEmail:String = "empty"
    var PredictionScore:Int = 0
    var StockPrice:Double = 0.0
    var PredictionText:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        
        print(companyName)
        print(compShort)
        print(userEmail)
        ShortNameLabel.text = companyName
        PredictionLabel.text = "None, yet"
        addingManager.delegate = self
        
        
        self.addingManager.performAPIRequest(url: self.addingManager.prepareURL(shortcut: self.addingManager.DetermineShortcut(CompName: self.companyName)))
        loadDetails()
    }
    func loadDetails(){
        db.collection("companies").document("\(companyName)\(userEmail)").addSnapshotListener {(querySnapshot, error) in
            
        if let e  = error{
            print("Theree was an issue with reading data from database. \(e)")
        }else{
            if let snapshotDocument = querySnapshot?.data(){
                if let compFullName = snapshotDocument["CompanyFullName"] as? String, let stockPrice = snapshotDocument["CurrentStockPrice"] as? Double,
                    let predictionScore = snapshotDocument["CompanyPredictionScore"] as? Double{
                    
            
            
                        DispatchQueue.main.async {
                            self.FullNameLabel.text = compFullName
                            self.StockPrice = stockPrice
                            self.StockPriceLabel.text = String(stockPrice)
                            self.PredictionLabel.text = String(predictionScore)
                        }
                    
                        
                    }
                }
            }
        }
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
    func determinePrediction(score:Int)->String{
        switch score{
        case 50..<100:
            return "Definitely buy stocks!"
        case 25..<49:
            return "Recomended to buy stocks!"
        case 10..<24:
            return "Close call, but in favour of buying stocks!"
        case 1..<9:
            return "Very close call, impossible to predict"
        case 0:
            return "Call impossible , equal amount of positive and negative opinions"
        case -10 ..< -1:
            return "Very close call impossible to predict"
        case -25 ..< -11:
            return "Close call but rather not buy stocks!"
        case -50 ..< -26:
            return "It is recommended not to buy stocks!"
        case -100 ..< -51:
            return "Definitely not buy stocks!"
        default:
            return "error"
            
        }
    }
    @IBAction func MakePredictionPressed(_ sender: Any) {
        let myGroup = DispatchGroup()
        myGroup.enter()
            self.swifter.searchTweet(using: "@\(self.companyName)",lang: "en", count: 100,tweetMode: .extended, success: { (results, metadata) in
                
            var tweets = [TwitterSentimentClassifier2Input]()
            for i in 0..<100{
                if let tweet  = results[i]["full_text"].string{
                    let tweetForInput = TwitterSentimentClassifier2Input.init(text: tweet)
                    tweets.append(tweetForInput)
                    
                }
                    
                }
                print(tweets.count)
                
                myGroup.leave()
                
            do{
                myGroup.enter()
                let predictions = try self.classifier.predictions(inputs: tweets)
                
                var companyScore = 0
                var predictionText = ""
                for item in predictions{
                   
                    if item.label == "Positive"{
                        companyScore += 1
                    }
                    else{
                        companyScore -= 1
                    }
                    
                }
                self.PredictionScore = companyScore
                self.PredictionLabel.text = String(companyScore)
                
                predictionText = self.determinePrediction(score: companyScore)
                self.PredictionText = predictionText
                myGroup.leave()
            }catch{
                print("there was an error during predicting!!!")
            }
        }){ (error) in
            print("there was an error\(error)")
            
        }
        myGroup.notify(queue: .main){
            if let userEmail = Auth.auth().currentUser?.email{
                self.db.collection("companies").document("\(self.companyName)\(userEmail)").setData( ["CompanyName": self.ShortNameLabel.text!, "UserEmail":userEmail,"CompanyShortcut":self.addingManager.DetermineShortcut(CompName: self.ShortNameLabel.text!),"CompanyFullName":self.FullNameLabel.text!,"CurrentStockPrice":self.StockPrice, "CompanyPredictionScore":self.PredictionScore]) { (error) in
                    if let e  = error{
                        let alert = UIAlertController(title: "Error!!", message: "There was an error writing your data\(e.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true)
                    }else{
                        let alert = UIAlertController(title: "Success!", message: "Data sucessfuly updated, predictionS score for \(self.ShortNameLabel.text!) is \(self.PredictionScore). The prediction for buying actions of this company is:  \(self.PredictionText!)", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                                                self.present(alert, animated: true)
                        
                        
                    }
                    
                
            }
        
        }
        }
        
        
        
    }
}

extension CompanyDetailsViewController:AddingManagerDelegate{
    func didUpdateData(_ data: CompanyDetailsModel) {
        DispatchQueue.main.async {
            var NewStockPrice = data.price
            
            if let userEmail = Auth.auth().currentUser?.email{
                self.db.collection("companies").document("\(self.companyName)\(userEmail)").updateData(["CurrentStockPrice" : NewStockPrice])
                self.StockPriceLabel.text = String(NewStockPrice)
        }
    }
    
    
}
    }
