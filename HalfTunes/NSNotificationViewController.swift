//
//  NSNotificationViewController.swift
//  HalfTunes
//
//  Created by Alaxabo on 4/10/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit

class NSNotificationViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [Track]()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(SearchViewController.dismissKeyboard))
        return recognizer
    }()

    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getUpdateSearchResult(_:)), name: NSNotification.Name(rawValue: didUpdateSearchResult), object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getUpdateSearchResult(_ notification: Notification){
        let result = notification.object as? [Track]
        self.searchResults = result!
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NSNotificationViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TrackCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TrackCell
        
        let track = searchResults[indexPath.row]
        cell.artistLabel?.text = track.artist
        cell.titleLabel?.text = track.name
        // Configure the cell...
        
        return cell
    }
}

extension NSNotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}


extension NSNotificationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss the keyboard
        dismissKeyboard()
        
        if !searchBar.text!.isEmpty {
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
            NetworkManager.shared.updateSearchResultFromUrl(url!)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }

}
