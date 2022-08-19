//
//  AddCompanyViewController.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 16/05/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AddCompanyViewController: UIViewController {

    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var AddCompanyButton: UIBarButtonItem!
    var addingManager = AddingManager()
    
    
    let db  = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        PickerView.dataSource = self
        PickerView.delegate = self
        addingManager.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func AddCompanyButtonPressed(_ sender: UIBarButtonItem) {
     
       
            self.addingManager.performAPIRequest(url: self.addingManager.prepareURL(shortcut: self.addingManager.DetermineShortcut(CompName: self.addingManager.selectedCompany)))

           
        
    }
    
}

extension AddCompanyViewController:UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addingManager.companies.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return addingManager.companies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addingManager.selectedCompany = addingManager.companies[row]
    }
    
    
}
extension AddCompanyViewController:AddingManagerDelegate{
    func didUpdateData(_ data: CompanyDetailsModel) {
        DispatchQueue.main.async {
            self.addingManager.companyFullName = data.name
            self.addingManager.stockPrice = data.price
            
            if let userEmail = Auth.auth().currentUser?.email{
                self.db.collection("companies").document("\(self.addingManager.selectedCompany)\(userEmail)").setData( ["CompanyName":self.addingManager.selectedCompany, "UserEmail":userEmail,"CompanyShortcut":self.addingManager.DetermineShortcut(CompName: self.addingManager.selectedCompany),"CompanyFullName":self.addingManager.companyFullName,"CurrentStockPrice":self.addingManager.stockPrice, "CompanyPredictionScore":0]) { (error) in
                    if let e  = error{
                        let alert = UIAlertController(title: "Error!!", message: "There was an error writing your data\(e.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true)
                    }else{
                        let alert = UIAlertController(title: "Success!", message: "Data sucessfuly updated", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true)
                    }
                    
                
            }
        
        }
            
            
        }
        
        
    }
    
    
}
