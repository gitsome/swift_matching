//
//  ImageEditViewController.swift
//  Matching
//
//  Created by john martin on 9/2/22.
//

import UIKit

class EditCardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var card: Card!
    var onEditComplete: (Card?, Data?) -> Void
    
    var imageHolder: UIView!
    var cardImageView: UIImageView!
    var imageFromCameraButton: UIButton?
    var imageFromLibraryButton: UIButton!
    var captionText: UITextField!
    var saveImageButton: UIButton!
    var deleteImagebutton: UIButton!

    var imageWasSet = false
    var imageWasChanged = false
    
    init (onEditComplete: @escaping ((Card?, Data?) -> Void)) {
        self.onEditComplete = onEditComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // load the root view programatically
    // if no view is automatically provided ( via Nib / Interface Builder ), then the view controller
    // will be asked for one, the default is to return an empty UIView,
    // you can override the default, but you must set the view property to something
    override func loadView() {
        super.loadView()
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)

//        This is an example of changing a constraint on switching to landscape or portrait mode
//        if let imageSize = cardImageView.image?.size {
//            let aspectRatio = imageSize.width / imageSize.height
//            let maxHeight = size.height * 0.3
//            let maxWidth = size.width - 60
//
//            cardImageHeightConstraint.isActive = false
//
//            if maxWidth / aspectRatio > maxHeight {
//                nextCardImageHeightConstraint = cardImageView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight)
//            } else {
//                nextCardImageHeightConstraint = cardImageView.heightAnchor.constraint(lessThanOrEqualTo: imageHolder.heightAnchor, constant: -20)
//            }
//
//            nextCardImageHeightConstraint.isActive = true
//            cardImageHeightConstraint = nextCardImageHeightConstraint
//        }
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // if the incoming card does not have an imageFileName, then it's assumed it already exists and is deletable
        if card.imageFileName != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(requestDeleteCard))
        }
        
        saveImageButton = UIButton(type: .system)
        saveImageButton.translatesAutoresizingMaskIntoConstraints = false
        saveImageButton.setTitle("Save Card", for: .normal)
        saveImageButton.backgroundColor = .systemBlue
        saveImageButton.setTitleColor(.white, for: .normal)
        saveImageButton.layer.cornerRadius = 8
        saveImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(saveImageButton)
        // constraints
        saveImageButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        saveImageButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        saveImageButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        saveImageButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        saveImageButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        // behavior
        saveImageButton.addTarget(self, action: #selector(saveCard), for: .touchUpInside)
                
        let imageFromLibraryButton = UIButton(type: .roundedRect)
        // presentation
        imageFromLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        imageFromLibraryButton.setTitle("Library", for: .normal)
        imageFromLibraryButton.backgroundColor = .clear
        imageFromLibraryButton.layer.cornerRadius = 8
        imageFromLibraryButton.layer.borderWidth = 1
        imageFromLibraryButton.layer.borderColor = UIColor.systemBlue.cgColor
        view.addSubview(imageFromLibraryButton)
        // constraints
        imageFromLibraryButton.bottomAnchor.constraint(equalTo: saveImageButton.topAnchor, constant: -15).isActive = true
        let leadingLibraryButtonConstraint = imageFromLibraryButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        leadingLibraryButtonConstraint.isActive = true
        imageFromLibraryButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        imageFromLibraryButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageFromLibraryButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        // behavior
        imageFromLibraryButton.addTarget(self, action: #selector(getImageFromLibrary), for: .touchUpInside)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        
            let newImageFromCameraButton = UIButton(type: .roundedRect)
            // presentation
            newImageFromCameraButton.translatesAutoresizingMaskIntoConstraints = false
            newImageFromCameraButton.setTitle("Camera", for: .normal)
            newImageFromCameraButton.backgroundColor = .clear
            newImageFromCameraButton.layer.cornerRadius = 8
            newImageFromCameraButton.layer.borderWidth = 1
            newImageFromCameraButton.layer.borderColor = UIColor.systemBlue.cgColor
            view.addSubview(newImageFromCameraButton)
            // constraints
            newImageFromCameraButton.bottomAnchor.constraint(equalTo: saveImageButton.topAnchor, constant: -15).isActive = true
            newImageFromCameraButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            // behavior
            newImageFromCameraButton.addTarget(self, action: #selector(getImageFromCamera), for: .touchUpInside)
            imageFromCameraButton = newImageFromCameraButton
            
            leadingLibraryButtonConstraint.isActive = false
            imageFromLibraryButton.leadingAnchor.constraint(equalTo: newImageFromCameraButton.trailingAnchor, constant: 15).isActive = true
            imageFromLibraryButton.widthAnchor.constraint(equalTo: newImageFromCameraButton.widthAnchor).isActive = true
        }
        
        captionText = UITextField()
        captionText.translatesAutoresizingMaskIntoConstraints = false
        captionText.placeholder = "Give a name"
        captionText.text = card.caption
        captionText.textAlignment = .left
        view.addSubview(captionText)
        // constraints
        captionText.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        captionText.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        captionText.setContentHuggingPriority(.defaultHigh, for: .vertical)
        captionText.setContentHuggingPriority(.defaultLow, for: .horizontal)
        captionText.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        // this style gives us better vertical padding
        captionText.borderStyle = .roundedRect
        captionText.layer.borderWidth = 1
        captionText.layer.cornerRadius = 2
        captionText.layer.borderColor = UIColor.systemGray.cgColor
        // an extension was added to allow automatic keyboard closure for all view controllers when text fields hit enter
        captionText.delegate = self
        
        // caption label
        let captionTextLabel = UILabel()
        captionTextLabel.text = "Name"
        captionTextLabel.textColor = .systemGray
        captionTextLabel.textAlignment = .left
        view.addSubview(captionTextLabel)
        // constraints
        captionTextLabel.translatesAutoresizingMaskIntoConstraints = false
        captionTextLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        captionTextLabel.centerYAnchor.constraint(equalTo: captionText.centerYAnchor).isActive = true
        captionTextLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 15).isActive = true
        captionTextLabel.trailingAnchor.constraint(equalTo: captionText.leadingAnchor, constant: -15).isActive = true
        
        imageHolder = UIView()
        imageHolder.translatesAutoresizingMaskIntoConstraints = false
        imageHolder.backgroundColor = .lightGray
        imageHolder.layer.cornerRadius = 5
        view.addSubview(imageHolder)
        imageHolder.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        imageHolder.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        imageHolder.topAnchor.constraint(equalTo: captionText.bottomAnchor, constant: 10).isActive = true
        imageHolder.bottomAnchor.constraint(equalTo: imageFromLibraryButton.topAnchor, constant: -10).isActive = true
        
        imageHolder.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageHolder.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        cardImageView = UIImageView()
        // presentation
        cardImageView.tintColor = UIColor.lightText
        cardImageView.contentMode = .scaleAspectFit
        
        // start with a placeholder image if the image doesn't exist
        if card.imageFileName == nil {
            
            let config = UIImage.SymbolConfiguration(pointSize: 128, weight: .light, scale: .default)
            let cameraIcon = UIImage(systemName: "camera.metering.unknown", withConfiguration: config)
            
            if let cameraIcon = cameraIcon {
                cardImageView.image = cameraIcon
            }
            
        } else {
            
            let imagesPath = CardsModelController.getImagePathNameForCard(card)
            
            if let imagesPath = imagesPath {
                cardImageView.image = UIImage(contentsOfFile: imagesPath.path)
                imageWasSet = true
            }
        }
        
        view.addSubview(cardImageView)
        
        
//          This was one approach, pinning to parent container
//          The problam was the UIImageView inherent size was forcing the parent container to grow
//          So in addition to this you need to modify the constraint on each change to landscape and back which is annoying
//            cardImageHeightConstraint = cardImageView.heightAnchor.constraint(lessThanOrEqualTo: imageHolder.heightAnchor, constant: -20)
//            cardImageHeightConstraint.isActive = true
        // cardImageHeightConstraint.priority = UILayoutPriority(800)
        
//            let cardImageWidthConstraint = cardImageView.widthAnchor.constraint(lessThanOrEqualTo: imageHolder.widthAnchor, constant: -20)
//            cardImageWidthConstraint.isActive = true
        // cardImageWidthConstraint.priority = UILayoutPriority(800)
                                
//            cardImageView.centerYAnchor.constraint(equalTo: imageHolder.centerYAnchor).isActive = true
//            cardImageView.centerXAnchor.constraint(equalTo: imageHolder.centerXAnchor).isActive = true
        
        // constraints
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 10).isActive = true
        cardImageView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -10).isActive = true
        cardImageView.topAnchor.constraint(equalTo: captionText.bottomAnchor, constant: 25).isActive = true
        cardImageView.bottomAnchor.constraint(equalTo: imageFromLibraryButton.topAnchor, constant: -25).isActive = true
        cardImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        cardImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    @objc func requestDeleteCard () {
        let ac = UIAlertController(title: "Delete Card", message: "Are you sure you want to delete this card?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteCard))
        present(ac, animated: true)
    }
    
    @objc func addNewCard () {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // find the image in the info
        guard let image = info[.editedImage] as? UIImage else { return }
        
        imageWasChanged = true
        imageWasSet = true
        
        // update the image and set the card's imageFileName to nil
        // the parent controller will know we set a new image clearing out the old one
        cardImageView.image = image
        card.imageFileName = nil
        
        dismiss(animated: true)
    }
    
    func deleteCard (action: UIAlertAction) {
        onEditComplete(nil, nil)
    }
    
    @objc func saveCard () {
        
        // first make sure we have what we need
        var caption = captionText.text ?? ""
        caption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
                
        if caption.count == 0 {
            let ac = UIAlertController(title: "Caption is Empty", message: "Please provide a caption for this card.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
            return
        }
        
        if !imageWasSet {
            let ac = UIAlertController(title: "Image is Empty", message: "Please provide an image for this card.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
            return
        }
        
        // get the jpeg data and let's tell our parent we are done
        if let jpegData = cardImageView.image?.jpegData(compressionQuality: 0.8) {
            
            card.caption = caption
            
            if !imageWasChanged {

                onEditComplete(card, nil)
                
            } else {
                
                let imageName = UUID().uuidString
                card.imageFileName = imageName
                onEditComplete(card, jpegData)
            }
            
        } else {
            print("could not get the jpeg data")
        }
    }
        
    @objc func getImageFromCamera () {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func getImageFromLibrary () {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}
