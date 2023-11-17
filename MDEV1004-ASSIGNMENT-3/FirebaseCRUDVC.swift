import UIKit
import Alamofire
import Kingfisher

class FirebaseCRUDVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var books: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        KingfisherManager.shared.defaultOptions = [.fromMemoryCacheOrRefresh]
        fetchBooksFromMongoDB()
    }
    
    func fetchBooksFromMongoDB() {
        let url = "http://localhost:3000/books"
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Received JSON: \(value)")
                if let booksData = try? JSONSerialization.data(withJSONObject: value),
                   let fetchedBooks = try? JSONDecoder().decode([Book].self, from: booksData) {
                    DispatchQueue.main.async {
                        self.books = fetchedBooks
                        self.tableView.reloadData()
                    }
                } else {
                    print("Error decoding books data")
                }
            case .failure(let error):
                print("Error fetching books: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        let book = books[indexPath.row]
        
        let bookRating: Double = book.rating
        let ratingString = String(bookRating)
       

        cell.titleLabel?.text = book.title
        cell.authorLabel?.text = book.author
        cell.ratingLabel?.text = ratingString

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = books[indexPath.row]
            showDeleteConfirmationAlert(for: book) { confirmed in
                if confirmed {
                    self.deleteBook(at: indexPath)
                }
            }
        }
    }


    func showDeleteConfirmationAlert(for book: Book, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteBook(at indexPath: IndexPath) {
        // Implement the code to delete a book from MongoDB here
    }

    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
