//
//  ViewController.swift
//  Notes
//
//  Created by Omotayo on 11/05/2022.
//

import UIKit

class NotesViewController: UIViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Note>! = nil
    private var notesCollectionView: UICollectionView! = nil
    
    private var notes: [Note]?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateCollectionView()
    }

    @objc
    private func didTapAddButton() {
        let addNoteVC = AddNoteViewController()
        addNoteVC.delegate = self
        let navVC = UINavigationController(rootViewController: addNoteVC)
        navVC.navigationBar.prefersLargeTitles = true
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }

    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureCollectionView() {
        notesCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        notesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(notesCollectionView)
        notesCollectionView.delegate = self
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Note> { cell, indexPath, note in
            var content = cell.defaultContentConfiguration()
            content.text = note.title
            content.textToSecondaryTextVerticalPadding = 8
            content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            content.textProperties.color = .label
            content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
            content.secondaryTextProperties.color = .secondaryLabel
            
            let bodyTextArray = note.body.components(separatedBy: " ")
            
            if (bodyTextArray.count > 8) {
                var bodyText = bodyTextArray[0...8].joined(separator: " ")
                bodyText.append("...")
                content.secondaryText = bodyText
            } else {
                content.secondaryText = note.body
            }
            
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Note>(collectionView: notesCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, note: Note) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: note)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.main])
        
        if let notes = notes {
            snapshot.appendItems(notes)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func fetchNotes() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            notes = try managedContext.fetch(Note.fetchRequest())
        } catch let error as NSError {
            fatalError("Unable to fetch. \(error) = \(error.userInfo)")
        }
    }
    
    private func updateCollectionView() {
        guard let notes = notes else {
            return
        }
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(notes)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension NotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
}

extension NotesViewController: AddNoteViewControllerDelegate {
    func didFinishAddingNote() {
        fetchNotes()
        updateCollectionView()
    }
}

