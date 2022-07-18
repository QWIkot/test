import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet var textFild: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var autoComletePossibilities = [String]()
    var autoComlete = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.jsonAutoParts()
        
    }
    
    func setupNavigationBar() {
        
        self.navigationItem.title = "Weather Now"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let city = searchController.searchBar.text {
            print(city)
        }
    }
    
    func searchAutocomleteEntriesWithSubstring(_ substring: String) {
        autoComlete.removeAll(keepingCapacity: false)
        for key in autoComletePossibilities {
            let myString:NSString! = key as NSString
            let substringRange:NSRange! = myString.range(of: substring)
            if (substringRange.location == 0) {
                autoComlete.append(key)
            }
        }
        tableView.reloadData()
    }
    
    func jsonAutoParts() {
        guard let path = Bundle.main.path(forResource: "cities", ofType: "json") else {
            return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let object = try JSONDecoder().decode(CityModel.self, from: data)
            print(object)
            for city in object.city {
                autoComletePossibilities.append(city.name)
            }
        } catch {
            print("Data err")
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let index = indexPath.row as Int
        cell.textLabel!.text = autoComlete[index]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.autoComlete.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        searchController.searchBar.text = selectedCell.textLabel!.text
        tableView.isHidden = true
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        searchAutocomleteEntriesWithSubstring(substring)
        return true
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        tableView.isHidden = false
        let substring = (searchController.searchBar.text! as NSString).replacingCharacters(in: range, with: text)
        searchAutocomleteEntriesWithSubstring(substring)
        return true
    }
}


