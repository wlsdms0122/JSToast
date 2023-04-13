//
//  IntrinsicContentView.swift
//
//
//  Created by JSilver on 2023/02/18.
//

import UIKit

/// Calculate the intrinsic content size of the content view using `.systemLayoutSizeFitting(_:)` within the context of an auto-layout system view.
///
/// When converting a `UIView` to a `SwiftUI.View`, the system may not be able to calculate the intrinsic content size correctly.
/// To fix this, override `intrinsicContentSize` to calculate the size using auto-layout sizing.
///
/// If your minimum deployment target is iOS 16.0/Mac Catalyst 16.0 or later, I recommend implementing `sizeThatFits(_:uiView:context:)` in the `UIViewRepresentable` protocol.
///
/// ```swift
/// func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
///     let proposalSize = CGSize(
///         width: proposal.width ?? .infinity,
///         height: proposal.height ?? .infinity
///     )
///
///     return uiView.systemLayoutSizeFitting(
///         proposalSize,
///         withHorizontalFittingPriority: proposal.width != nil
///             ? .required
///             : .fittingSizeLevel,
///         verticalFittingPriority: proposal.height != nil
///             ? .required
///             : .fittingSizeLevel
///     )
/// }
/// ```
public class IntrinsicContentView<View: UIView>: UIView {
    // MARK: - Property
    public let content: View
    
    public override var intrinsicContentSize: CGSize {
        content.systemLayoutSizeFitting(super.intrinsicContentSize)
    }
    
    // MARK: - Initializer
    public init(_ content: View) {
        self.content = content
        super.init(frame: .zero)
        
        setUp()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func setUp() {
        setUpLayout()
        setUpState()
        setUpAction()
    }
    
    private func setUpLayout() {
        [
            content
        ]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    private func setUpState() {
        
    }
    
    private func setUpAction() {
        
    }
}
