//
//  HomePageViewController.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 13/05/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class HomePageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LogOutButton: UIBarButtonItem!
    
    @IBOutlet weak var AddButton: UIBarButtonItem!
    let db  = Firestore.firestore()
    let currentUserEmail = Auth.auth().currentUser?.email
    let refreshControl = UIRefreshControl()
    
    var companies:[Company]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
           refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
           tableView.addSubview(refreshControl)
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:"TableViewCell", bundle: nil), forCellReuseIdentifier: "CompanyCell")
        loadCompanies()

        // Do any additional setup after loading the view.
    }
    @objc func refresh(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "HomeToAdd", sender: self)

    }
    
    @IBAction func LogOutButton(_ sender: UIBarButtonItem) {
        
       do {
           try Auth.auth().signOut()
           navigationController?.popToRootViewController(animated: true)
       } catch let signOutError as NSError {
         print("Error signing out: %@", signOutError)
       }
         
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Do any required setup for this segue such as passing in data loading required views and specifying how you want the segue to be performed such as if you want the view to be pushed, or presented as a popover etc... for example:
        if let vc = segue.destination as? CompanyDetailsViewController {
            let indexPath = self.tableView.indexPathForSelectedRow
            vc.companyName = self.companies[indexPath!.row].name
            vc.compShort = self.companies[indexPath!.row].shortcut
            vc.userEmail = self.companies[indexPath!.row].userEmail
            // Downcast to the desired view controller.
        // Configure the view controller here...
        }
    }
    
    func loadCompanies(){
        db.collection("companies").addSnapshotListener {(querySnapshot, error) in
            self.companies = []
        if let e  = error{
            print("Theree was an issue with reading data from database. \(e)")
        }else{
            if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let userEmail = data["UserEmail"] as? String, let companyName = data["CompanyName"] as? String, let compShort = data["CompanyShortcut"] as? String,let stockPrice = data["CurrentStockPrice"] as? Double, data["UserEmail"] as? String == self.currentUserEmail{
                        let newCompany = Company(name: companyName, shortcut: compShort, userEmail: userEmail, stockPrice: stockPrice)
                        self.companies.append(newCompany)
                        DispatchQueue.main.async {
                            
                            self.tableView.reloadData()
                        }
                        
                    }
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
extension HomePageViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as! TableViewCell
        cell.CompanyNameLabel.text = companies[indexPath.row].name
        cell.ShortNameLabel.text = companies[indexPath.row].shortcut
        cell.StockPriceLabel.text = String(companies[indexPath.row].stockPrice)
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    
}

extension HomePageViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                DispatchQueue.main.async {self.performSegue(withIdentifier: "HomeToDetails", sender: self)
           
        }
        
        
    }
    
}

