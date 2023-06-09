//
//  RecipePreviewViewController.swift
//  Smartketo
//
//  Created by Pubudu Dilshan on 2023-05-21.
//
import UIKit
import WebKit

class cipePreviewViewController: UIViewController {

    private let titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "reps count"
        return label
    }()

    private let overViewLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "engaging body parts"
        label.numberOfLines = 0
        return label
    }()

    private let calLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemGray3
        label.numberOfLines = 0
        label.layer.cornerRadius = 120/2
        label.font = .systemFont(ofSize: 18, weight: .semibold)

        return label
    }()

    private let webView: WKWebView = {
    let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overViewLabel)
        view.addSubview(calLabel)

        configureConstraints()
    }

    func configureConstraints(){
        let webViewConstraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ]

        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant:  20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]

        let overViewConstraints = [
            overViewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overViewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overViewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        let calLabelConstraints = [
            calLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calLabel.topAnchor.constraint(equalTo: overViewLabel.bottomAnchor, constant: 25),
            calLabel.widthAnchor.constraint(equalToConstant: 180),
            calLabel.heightAnchor.constraint(equalToConstant: 40)

        ]

        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(overViewConstraints)
        NSLayoutConstraint.activate(calLabelConstraints)
    }


    func configure(with model: cipePreviewViewModel){
        titleLabel.text = model.title
        overViewLabel.text = model.recipeDesc
        calLabel.text = model.calories

        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }

        webView.load(URLRequest(url: url))
    }

}
