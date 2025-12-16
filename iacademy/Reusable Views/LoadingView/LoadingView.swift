//
//  LoadingView.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class LoadingView: UIView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setup(in view: UIView) {
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isUserInteractionEnabled = true
        view.insertSubview(self, at: 99999)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupViews() {
        let bgView = UIView()
        bgView.backgroundColor = .Gray_50
        bgView.layer.cornerRadius = 12
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowRadius = 3
        bgView.layer.shadowOffset = .zero
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = false
        activityIndicator.color = .Blue_Brand_500
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(activityIndicator)
        addSubview(bgView)
        
        NSLayoutConstraint.activate([
            
            bgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            bgView.widthAnchor.constraint(equalToConstant: 80),
            bgView.heightAnchor.constraint(equalToConstant: 80),
            
            activityIndicator.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: bgView.centerYAnchor)
        ])
    }
    
}
