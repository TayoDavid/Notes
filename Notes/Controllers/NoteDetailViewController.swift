//
//  NotesDetailViewController.swift
//  Notes
//
//  Created by Omotayo on 12/05/2022.
//

import UIKit

class NoteDetailViewController: UIViewController {
    
    var note: Note?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    private var titleField: UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return field
    }()
    
    private var bodyTextView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = .label
        view.clipsToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        if let note = note {
            titleField.text = note.title
            bodyTextView.text = note.body
        }
        
        bodyTextView.delegate = self
        titleField.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubViews(views: titleField, bodyTextView)
        
        titleField.frame = CGRect(x: 12, y: 120, width: view.width - 24, height: 44)
        bodyTextView.frame = CGRect(x: 8, y: titleField.bottom + 8, width: view.width - 16, height: view.bottom - 220)
    }
}

extension NoteDetailViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignFirstResponder()
        guard let note = self.note else { return }
        if textField == titleField && titleField.text!.trim() != note.title {
            let managedContext = appDelegate.persistentContainer.viewContext
            note.title = titleField.text!.trim()
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                fatalError("\(error.userInfo)")
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resignFirstResponder()
        guard let note = self.note else { return }
        if textView == bodyTextView && bodyTextView.text.trim() != note.body {
            let managedContext = appDelegate.persistentContainer.viewContext
            note.body = bodyTextView.text
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                fatalError("\(error.userInfo)")
            }
        }
    }
}
