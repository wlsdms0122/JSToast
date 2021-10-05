//
//  DefautToast.swift
//  JSToaster
//
//  Created by jsilver on 2021/10/05.
//

import UIKit

open class DefaultToast: UIView {
    // MARK: - View
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.textColor = .black
        
        return view
    }()
    
    // MARK: - Property
    open var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    // MARK: - Initializer
    public init(title: String) {
        super.init(frame: .zero)
        
        commonInit(title: title)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func commonInit(title: String) {
        setUpComponent(title: title)
        setUpAction()
        setUpLayout()
    }
    
    private func setUpComponent(title: String) {
        backgroundColor = .init(red: 243 / 255, green: 243 / 255, blue: 243 / 255, alpha: 1)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .init(width: 0, height: 2)
        
        self.title = title
    }
    
    private func setUpAction() {
        
    }
    
    private func setUpLayout() {
        [titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48)
        ])
    }
    
    deinit {
        print("deinited \(self)")
    }
}
