//
//  MainTableViewController.swift
//  BookFinderWithCodableEx
//
//  Created by runnysun on 2022/10/24.
//

import UIKit

class MainTableViewController: UITableViewController {
   
    @IBOutlet weak var btnPrev: UIBarButtonItem!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    let apiKey = "KakaoAK 694940e28c76593291be000930b7eca9"
    
    var books:[Book] = []
    var page = 1
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        searchBar.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func search(with query:String?, page:Int){
        guard let query = query else { return }
        let str = "https://dapi.kakao.com/v3/search/book?query=\(query)&page=\(page)"
        //한글을 인코딩하는 방식
        if let strURL = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: strURL) {
            var request = URLRequest(url: url)
            request.addValue(apiKey, forHTTPHeaderField: "Authorization")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data else {return}
                let decoder = JSONDecoder()
                do {
                    let root = try decoder.decode(ResultData.self, from: data)
                    self.books = root.documents
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.btnNext.isEnabled = !root.meta.is_end
                    }
                    
                } catch {
                    print("파싱실패")
                }
                
            }
            task.resume()
            
        }
        btnPrev.isEnabled = page > 1
        
    }
    func handler(data:Data?, response:URLResponse?, error:Error){
        
    }
    
    
    @IBAction func actNext(_ sender: Any) {
        page += 1
        search(with: searchBar.text, page: page)
    }
    
    @IBAction func actPrev(_ sender: Any) {
        page -= 1
        search(with: searchBar.text, page: page)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let book = books[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        if let url = URL(string: book.thumbnail) {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            session.dataTask(with: request) { data, _ , error in
                if let data = data{
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        imageView?.image = image
                    }
                }
            }.resume()
        }
        
        
        let lblTitle = cell.viewWithTag(2) as? UILabel
        lblTitle?.text = book.title
        
        let lblAuthors = cell.viewWithTag(3) as? UILabel
        lblAuthors?.text = book.authors.joined(separator: ", ")
        
        let lblPublisher = cell.viewWithTag(4) as? UILabel
        lblPublisher?.text = book.publisher
        
        let lblPrice = cell.viewWithTag(5) as? UILabel
        lblPrice?.text = "\(book.price)"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let book = self.books[indexPath.row]
            let vc = segue.destination as? DetailViewController
            vc?.strURL = book.url
        }
       
    }
   

}

extension MainTableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        page = 1
        search(with: searchBar.text, page:1)
        //키보드를 자동적으로 내리는 리소스
        searchBar.resignFirstResponder()
    }
}
