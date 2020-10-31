//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Joseph Miller on 10/23/20.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // FIXME: Dismiss keyboard when done typing
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        // save image post to parse
        let post = PFObject(className: "Posts")
        post["author"] = PFUser.current()!
        post["caption"] = commentField.text
        
        guard let imageData = imageView.image?.pngData() else {
            print("No image")
            return
        }
        let file = PFFileObject(data: imageData)
        post["image"] = file
        
        post.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("save")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            // for simulator
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the picked the image and resize
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
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
