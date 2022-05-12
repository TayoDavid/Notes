//
//  AddNoteViewController.swift
//  Notes
//
//  Created by Omotayo on 11/05/2022.
//

import UIKit

protocol AddNoteViewControllerDelegate {
    func didFinishAddingNote()
}

class AddNoteViewController: UIViewController {
    
    var delegate: AddNoteViewControllerDelegate?

    private var titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return field
    }()
    
    private var bodyTextView: UITextView = {
        let view = UITextView()
        view.text = "Type in here..."
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = .placeholderText
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add Note"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        bodyTextView.delegate = self
        titleField.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubViews(views: titleField, bodyTextView)
        
        titleField.frame = CGRect(x: 20, y: 120, width: view.width - 40, height: 44)
        bodyTextView.frame = CGRect(x: 16, y: titleField.bottom + 20, width: view.width - 32, height: view.bottom - 250)
    }
    
    @objc
    private func didTapSaveButton() {
        if titleField.text!.isEmpty || bodyTextView.text.isEmpty {
            let alertController = UIAlertController(
                title: "Fields Required",
                message: "Please enter a title and body for your note!",
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let note = Note(context: managedContext)
        note.title = titleField.text!
        note.body = bodyTextView.text
        note.created = Date.now
        
        do {
            try managedContext.save()
            let alertController = UIAlertController(title: "Note Saved", message: "Note has been saved successfully!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didFinishAddingNote()
                self.dismiss(animated: true) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            
        } catch let error as NSError {
            fatalError("Error saving person to core data. \(error.userInfo)")
        }
    }
}

extension AddNoteViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleField.resignFirstResponder()
        if textField == titleField && !titleField.text!.isEmpty {
            bodyTextView.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        bodyTextView.becomeFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == bodyTextView && bodyTextView.text == "Type in here..." {
            textView.text = ""
            bodyTextView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == bodyTextView && bodyTextView.text.isEmpty {
            textView.text = "Type in here..."
            bodyTextView.textColor = .placeholderText
        }
    }
}
    
    

