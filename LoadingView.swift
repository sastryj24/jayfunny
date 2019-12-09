//
//  LoadingView.swift
//  HGC Internal
//
//  Created by Apple on 12/4/19.
//  Copyright © 2019 Jay Sastry. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIViewController {
    
    // initialize a global variable to contain the token generated by a the API
    static var keys: String = ""
    
    // create a UILabel to prompt user to open app
    @IBOutlet var enter: UILabel!
    
    // create arrays to contain all works decoded from API and a search list
    var searchList: [work] = []
    var works: [work] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("hi1")
        
        // initialize initial text to blank
        enter.text = ""
        
        // check whether URL exists and can be accessed
        let url = URL(string: "https://wrapapi.com/use/sastryj24/cs50/hgclogin/latest?username=jsastry&password=Veritas18%21&wrapAPIKey=QoUv0L22KUQYHSKo7LfSOHsVQcmglUJW")
        guard let u = url else {
            print("drat")
            return
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // initialize URl session
        URLSession.shared.dataTask(with: u) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                
                // store cookies associated with the URL request
                ViewController.self.cookie = HTTPCookieStorage.shared.cookies!
                
                // decode the struct created by the API to pass to each subsequent API request
                let key = try JSONDecoder().decode(loginKey.self, from: data)
                LoadingView.self.keys = key.stateToken
//                print(LoadingView.self.keys)
                self.tableData(token: LoadingView.self.keys)
            }
            catch let error {
                print("\(error)")
            }
        }.resume()
    }
    
    func tableData(token: String) {
        
        // check whether URL of API that returns all songs titles
        let url2 = URL(string: "https://wrapapi.com/use/sastryj24/cs50/hgcinternal2/latest?stateToken=\(token)&wrapAPIKey=QoUv0L22KUQYHSKo7LfSOHsVQcmglUJW")
        guard let u = url2 else {
            return
        }
        
        // begin URL session
        URLSession.shared.dataTask(with: url2!) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                
                // navigate to struct containing an array of works
                let datum = try JSONDecoder().decode(outside.self, from: data)
                let worksList = datum.data
                self.works = worksList.piece
//                print(self.works.count)
                
                // filter out members of the array without a title
                self.works = self.works.filter {($0.title != nil)}
                
                // set the search list to contain all works pulled from the website
                self.searchList = self.works
                           
                // Upon completion of the API request, alert the user they can enter app
                DispatchQueue.main.async {
                    self.enter.text = "Swipe Left to Enter..."                           }
                }
                catch let error {
                    print("\(error)")
                }
        }.resume()

    }
    
    // create IBAction to trigger a segue to the table view controller of song titles
    @IBAction func SwipeToEnter(_ sender: UISwipeGestureRecognizer) {
        nextView()
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if(segue.identifier == "GoToTableView")
//        {
//            self.performSegue(withIdentifier: "GoToTableView", sender: self)
//            print("Hi")
//        }
        
        
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // pass data collected from the API request to the tableView in the next viewcontroller
        if segue.identifier == "GoToTableView" {
            if let destination = segue.destination as? ViewController {
                destination.searchList = searchList
                destination.works = works
                }
        }
    }
    
    // function to move to the next view
    func nextView() {
        print("hi")
        self.performSegue(withIdentifier: "GoToTableView", sender: nil)
    }
    

}
