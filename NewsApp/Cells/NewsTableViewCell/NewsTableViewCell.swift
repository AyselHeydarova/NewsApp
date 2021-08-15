//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 11.08.21.
//

import UIKit
import CoreData
import SDWebImage

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!

    var saveButtonTapped: (() -> ())?

    @IBAction func saveTapped(_ sender: UIButton) {
        let image: UIImage? = sender.currentImage == UIImage(systemName: "bookmark")
            ? UIImage(systemName: "bookmark.fill")
            : UIImage(systemName: "bookmark")

        sender.setImage(image, for: .normal)
        saveButtonTapped?()
    }

    func configure(imageURL: String,
                   title: String,
                   description: String,
                   source: String,
                   author: String) {
        articleImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        titleLabel.text = title
        descriptionLabel.text = description
        sourceLabel.text = source
        authorLabel.text = author
        favButton.tintColor = .black

        NSLayoutConstraint.activate(
            [
                articleImageView.heightAnchor.constraint(equalTo: articleImageView.widthAnchor, multiplier: 0.5)
            ])

    }
}
