//
//  ViewController.swift
//  PhotosApp
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController, QLPreviewPanelDataSource {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var filenameLabel: NSTextField!
    
    @IBOutlet weak var bottomView: NSView!
    
    
    // MARK: - Properties
    
    var photos = [[PhotoInfo]]()
    
    let thumbnailSize = NSSize(width: 130.0, height: 130.0)
    
    var showSectionHeaders = false
    
    var previewURL: URL?
    
    let photoItemIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "photoItemIdentifier")
    
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        configureCollectionView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // MARK: - Implemented Methods
    
    func configureUI() {
        self.progressBar.isHidden = true
        filenameLabel.stringValue = ""
    }
    
    
    func prepareToCreateThumbnails(for totalPhotos: Int) {
        progressBar.isHidden = false
        progressBar.minValue = 0.0
        progressBar.maxValue = Double(totalPhotos)
        progressBar.doubleValue = 0.0
        bottomView.isHidden = true
    }
    
    
    func performPostThumbnailCreationActions() {
        progressBar.isHidden = true
        bottomView.isHidden = false
    }
    
    
    func updateProgress(withValue value: Int) {
        progressBar.doubleValue = Double(value)
    }
    
    
    func getProcessedPhotos() {
        if photos.count > 0 {
            self.photos[self.photos.count - 1] = PhotoHelper.shared.photosToProcess
        }
    }
    
    
    func configureAndShowQuickLook() {
        guard let ql = QLPreviewPanel.shared() else { return }
        ql.dataSource = self
        ql.makeKeyAndOrderFront(self.view.window)
    }
    
    
    
    // MARK: - QLPreviewPanelDataSource
       
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }

    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        guard let previewURL = previewURL else { return nil }
        return previewURL as QLPreviewItem
    }
    
    
    
    // MARK: - IBOutlet Properties
    
    @IBAction func importPhotos(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.message = "Select a folder to import photos from..."
        let response = panel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            if let selectedURL = panel.directoryURL {
                var newPhotos = [PhotoInfo]()
                PhotoHelper.shared.importPhotoURLs(from: selectedURL, to: &newPhotos)
                photos.append(newPhotos)
                
                createThumbnails()
            }
        }
    }
    
    
    @IBAction func toggleSectionHeaders(_ sender: Any) {
        showSectionHeaders = !showSectionHeaders
        collectionView.reloadData()
    }
    
    
    @IBAction func removeSelectedPhotos(_ sender: Any) {
        if collectionView.selectionIndexPaths.count > 0 {
            let sortedSelectedIndexPaths = collectionView.selectionIndexPaths.sorted(by: >)
            sortedSelectedIndexPaths.forEach { photos[$0.section].remove(at: $0.item) }
            collectionView.deleteItems(at: collectionView.selectionIndexPaths)
            
            for (index, _) in photos.enumerated().reversed() {
                if photos[index].count == 0 {
                    photos.remove(at: index)
                    collectionView.reloadData()
                }
            }
            
            filenameLabel.stringValue = ""
        }
    }
    
    
    
    // MARK: - Put Methods To Implement Here
    
    func createThumbnails() {
        guard let recentPhotos = photos.last else { return }
        prepareToCreateThumbnails(for: recentPhotos.count)
        PhotoHelper.shared.createThumbnails(for: recentPhotos, desiredSize: thumbnailSize, progress: { (currentPhoto) in
            
            DispatchQueue.main.async {
                self.updateProgress(withValue: currentPhoto)

                if currentPhoto.isMultiple(of: 20) {
                    self.getProcessedPhotos()

                    self.collectionView.reloadData()
                    self.collectionView.enclosingScrollView?.contentView.scroll(to:
                        NSPoint(x: 0.0, y: self.collectionView.collectionViewLayout?.collectionViewContentSize.height ?? 0.0))
                }
            }
            
           }) { () in
                DispatchQueue.main.async {
                    self.getProcessedPhotos()
                    self.performPostThumbnailCreationActions()
                    self.collectionView.reloadData()
                    self.collectionView.enclosingScrollView?.contentView.scroll(to: NSPoint(x: 0.0, y: 0.0))
                }
           }
    }
    
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.enclosingScrollView?.borderType = .noBorder
        collectionView.register(NSNib(nibNamed: "PhotoItem", bundle: nil), forItemWithIdentifier: photoItemIdentifier)
        
        configureFlowLayout()
        // configureGridLayout()
    }
    

    func configureFlowLayout() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 30.0
        flowLayout.minimumLineSpacing = 30.0
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        collectionView.collectionViewLayout = flowLayout
    }
 
    
    /*
    func configureGridLayout() {
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumInteritemSpacing = 30.0
        gridLayout.minimumLineSpacing = 30.0
        gridLayout.minimumItemSize = NSSize(width: 150.0, height: 150.0)
        gridLayout.maximumItemSize = NSSize(width: 150.0, height: 150.0)
        gridLayout.maximumNumberOfColumns = 3
        gridLayout.maximumNumberOfRows = 2
        collectionView.collectionViewLayout = gridLayout
    }
    */
}



// MARK: - NSCollectionViewDataSource
extension ViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return photos.count
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos[section].count
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let item = collectionView.makeItem(withIdentifier: photoItemIdentifier, for: indexPath) as? PhotoItem else { return NSCollectionViewItem() }
        
        item.imageView?.image = photos[indexPath.section][indexPath.item].thumbnail
        
        item.doubleClickActionHandler = { [weak self] in
            self?.previewURL = self?.photos[indexPath.section][indexPath.item].url
            self?.configureAndShowQuickLook()
        }
        
        return item
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        
        guard let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath) as? HeaderView else { return NSView() }
        
        guard photos[indexPath.section].count > 0, let url = photos[indexPath.section][0].url else { return NSView() }
        
        view.label.stringValue = url.deletingLastPathComponent().lastPathComponent + " (\(photos[indexPath.section].count))"
        return view
    }
}



// MARK: - NSCollectionViewDelegateFlowLayout
extension ViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

        guard let indexPath = indexPaths.first else { return }
        
        guard let url = photos[indexPath.section][indexPath.item].url else { filenameLabel.stringValue = ""; return }
        filenameLabel.stringValue = url.lastPathComponent
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 150.0, height: 150.0)
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        
        return showSectionHeaders ? NSSize(width: 0.0, height: 60.0) : .zero
    }
}
