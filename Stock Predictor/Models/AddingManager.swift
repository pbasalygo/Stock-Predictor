//
//  AddingManager.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 16/05/2022.
//

import Foundation

protocol AddingManagerDelegate{
    func didUpdateData(_ data:CompanyDetailsModel)
}

struct AddingManager{
    var delegate:AddingManagerDelegate?
    let companies:[String] = ["Amazon","Apple", "Microsoft", "Tesla","Facebook", "Nvidia", "JPMorgan","Procter&Gamble","CoinBase","Shopify","Twitter","Google","Mercedes-Benz","McDonalds", "Kyndryl","Volkswagen","PayPal"]
    var selectedCompany = ""
    var companyFullName:String=""
    var stockPrice:Double=0.0
    mutating func DetermineShortcut(CompName:String)->String{
        switch CompName{
        case "Apple":
            return "AAPL"
        case "Amazon":
            return "AMZN"
        case "Microsoft":
            return "MSFT"
        case "Tesla":
            return "TSLA"
        case "Facebook":
            return "FB"
        case "Nvidia":
            return "NVDA"
        case "JPMorgan":
            return "JPM"
        case "Procter&Gamble":
            return "PG"
        case "CoinBase":
            return "COIN"
        case "Shopify":
            return "SHOP"
        case "Twitter":
            return "TWTR"
        case "Google":
            return "GOOGL"
        case "McDonalds":
            return "MCD"
        case "Kyndryl":
            return "KD"
        case "Volkswagen":
            return "VWAGY"
        case "Mercedes-Benz":
            return "DMLRY"
        case "PayPal":
            return "PYPL"
        default:
            return ""
        }
    }
    
    let apiKey = "?apikey=385fb503497668ab5e71c452d9d27946"
    
    var baseURL = "https://financialmodelingprep.com/api/v3/quote/"
    
    
    func prepareURL(shortcut:String)->String{
        let URL = "\(baseURL)\(shortcut)\(apiKey)"
        return URL
    }
    func performAPIRequest(url:String){
        if let url = URL(string: url){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){data,response,error in
                if error != nil{
                    print(error?.localizedDescription as Any)
                }
                if let safeData = data{
                    if let company = self.parseJSON(data: safeData){
                        print(company)
                        self.delegate?.didUpdateData(company)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(data:Data)->CompanyDetailsModel?{

        do{
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Array<CompanyDetailData>.self, from: data)
            let companyFullName = decodedData[0].name
            let StockPrice = decodedData[0].price
            let company = CompanyDetailsModel(name: companyFullName, price: StockPrice)
            return company
        }
        catch{
            print(error.localizedDescription)
            return nil
        }
    }
}
