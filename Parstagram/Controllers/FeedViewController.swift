//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Joseph Miller on 10/23/20.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Comment input
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        // Dismiss keyboard by dragging down
        tableView.keyboardDismissMode = .interactive
        // Notification to hide keyboard
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // make parse query
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        // use query to get posts and reload table view
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Message Input Bar
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        dismissComment()
    }
    
    func dismissComment() {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        // Clear and dismiss the input
        dismissComment()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Table View Data Source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of comments + 1 for post + 1 for comment input
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        let user = post["author"] as! PFUser
        
        if indexPath.row == 0 {
            // post cell is row 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String ?? ""
            // image
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af.setImage(withURL: url)
            return cell
        } else if indexPath.row <= comments.count {
            // comment cells for row <= # of comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            cell.commentLabel.text = comment["text"] as? String
            return cell
        } else {
        // last cell is comment input
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    // MARK: - Table View Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1 {
            // Raise keyboard
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
//        Fake comment
//        comment["text"] = "Great picture!"
//        comment["post"] = post
//        comment["author"] = PFUser.current()!
//        post.add(comment, forKey: "comments")
//        post.saveInBackground { (success: Bool, error: Error?) in
//            if success {
//                print("Comment saved")
//            } else {
//                print("Error saving comment")
//            }
//        }
    }
    
    // MARK: - Interface Builder Actions
    
    @IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
        print("logout")
        PFUser.logOut()
        // switch back to login scren
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate
        else {
            print("Scene Delegate not found")
            return
        }
        delegate.window?.rootViewController = loginViewController
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
