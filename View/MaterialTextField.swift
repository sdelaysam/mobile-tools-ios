//
//  MaterialTextField.swift
//  iOS
//  inspired by https://github.com/roytornado/RSFloatInputView/blob/master/RSFloatInputView/Classes/RSFloatInputView.swift
//  Created by Sergey Petrov on 4/22/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

public class MaterialTextField: UIView {

    public enum BorderStyle {
        case bottom, round
    }
    
    var normalPlaceholderFontSize: CGFloat = 16
    var focusedPlaceholderFontSize: CGFloat = 14
    var normalPlaceholderColor: UIColor = UIColor(red: 96, green: 96, blue: 96, alpha: 1)
    var focusedPlaceholderColor: UIColor = .systemBlue
    var normalBackgroundColor: UIColor = UIColor(red: 236, green: 236, blue: 236, alpha: 1)
    var focusedBackgroundColor: UIColor = UIColor(red: 219, green: 219, blue: 219, alpha: 1)
    var disabledBackgroundColor: UIColor = UIColor(red: 236, green: 236, blue: 236, alpha: 1)
    var normalBorderColor: UIColor = UIColor(red: 31, green: 31, blue: 31, alpha: 1)
    var focusedBorderColor: UIColor = .systemBlue
    var textColor: UIColor = UIColor(red: 31, green: 31, blue: 31, alpha: 1)
    var fontName: String = "HelveticaNeue"
    var inputFontSize: CGFloat = 16
    var errorFontSize: CGFloat = 14
    var errorColor: UIColor = .red
    var disabledAlpha: CGFloat = 0.8
    
    var horizontalInset: CGFloat = 16
    var verticalInset: CGFloat = 8
    
    var placeholderTopInset: CGFloat = 4
    var placeholderBottomInset: CGFloat = 4
    var placeholderErasePadding: CGFloat = 5
    
    var leftInset: CGFloat = 16
    var rightInset: CGFloat = 16
    var topInset: CGFloat = 8
    var bottomInset: CGFloat = 8
    var leftIconSize: CGFloat = 30
    var rightIconSize: CGFloat = 30
    var textInnerPadding: CGFloat = 2
    var iconInnerPadding: CGFloat = 8
    var normalLineWidth: CGFloat = 1.0
    var focusedLineWidth: CGFloat = 2.0
    var cornerRadius: CGFloat = 10.0
    
    let textField = UITextField()
    private var errorLabel: UILabel? = nil
    private var leftIconView: UIImageView? = nil
    private var rightIconView: UIImageView? = nil
    private let placeholderLabel = CATextLayer()
    private let backgroundLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let animationDuration: Double = 0.2
    private let textFieldGap: CGFloat = 2
    
    var text: String? {
        get { return textField.text }
        set {
            textField.text = newValue
            layout()
            syncLayers()
        }
    }

    var isEnabled: Bool {
        get { return textField.isEnabled }
        set {
            textField.isEnabled = newValue
            syncLayers()
        }
    }

    var borderStyle: BorderStyle = .bottom {
        didSet {
            layout()
        }
    }
    
    var placeholder: String? {
        get { return placeholderLabel.string as? String }
        set {
            placeholderLabel.string = newValue
            layout()
            layer.removeAllAnimations()
        }
    }
    
    var error: String? {
        get { return errorLabel?.text }
        set {
            getErrorLabel().text = newValue
            invalidateIntrinsicContentSize()
            layout()
            syncLayers()
        }
    }

    var leadingIconImage: UIImage? {
        get { return isRtl ? rightIconView?.image : leftIconView?.image }
        set {
            (isRtl ? getRightIconView() : getLeftIconView()).image = newValue
            layout()
        }
    }

    var trailingIconImage: UIImage? {
        get { return isRtl ? leftIconView?.image : rightIconView?.image }
        set {
            (isRtl ? getLeftIconView() : getRightIconView()).image = newValue
            layout()
        }
    }
    
    var leadingIconTintColor: UIColor? {
        get { return isRtl ? rightIconView?.tintColor : leftIconView?.tintColor }
        set {
            (isRtl ? getRightIconView() : getLeftIconView()).tintColor = newValue
        }
    }

    var trailingIconTintColor: UIColor? {
        get { return isRtl ? leftIconView?.tintColor : rightIconView?.tintColor }
        set {
            (isRtl ? getLeftIconView() : getRightIconView()).tintColor = newValue
            layout()
        }
    }

    var isEditing: Bool {
        return textField.isEditing
    }
    
    var isPlaceholderFloating: Bool {
        return textField.isEditing || textField.text?.isEmpty == false
    }
    
    var isError: Bool {
        return errorLabel?.text?.isEmpty == false
    }
    
    private var isRtl: Bool {
        return UIView.userInterfaceLayoutDirection(for: textField.semanticContentAttribute) == .rightToLeft
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        var totalWidth: CGFloat = 200
        if leftIconView?.image != nil {
            totalWidth += leftIconSize + iconInnerPadding
        }
        if rightIconView?.image != nil {
            totalWidth += rightIconSize + iconInnerPadding
        }
        var totalHeight: CGFloat = topInset + 4*textFieldGap + focusedPlaceholderFontSize + textInnerPadding + inputFontSize + bottomInset
        if error != nil {
            errorLabel!.preferredMaxLayoutWidth = totalWidth
            totalHeight += errorLabel!.intrinsicContentSize.height + 2*textInnerPadding
        }
        return CGSize(width: leftInset + totalWidth + rightInset, height: totalHeight)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        layout()
        syncLayers()
    }
    
    private func setup() {
        borderLayer.contentsScale = UIScreen.main.scale
        backgroundLayer.contentsScale = UIScreen.main.scale
        placeholderLabel.contentsScale = UIScreen.main.scale
        placeholderLabel.allowsFontSubpixelQuantization = true
        placeholderLabel.font = CGFont(fontName as CFString)
        placeholderLabel.disableTextMorphing()
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(borderLayer)
        layer.addSublayer(placeholderLabel)
        addSubview(textField)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focus)))
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        
        textField.textColor = textColor
        textField.font = UIFont(name: fontName, size: inputFontSize)
    }

    private func getLeftIconView() -> UIImageView {
        guard let leftIconView = leftIconView else {
            let view = UIImageView()
            addSubview(view)
            self.leftIconView = view
            return view
        }
        return leftIconView
    }

    private func getRightIconView() -> UIImageView {
        guard let rightIconView = rightIconView else {
            let view = UIImageView()
            addSubview(view)
            self.rightIconView = view
            return view
        }
        return rightIconView
    }

    private func getErrorLabel() -> UILabel {
        guard let errorLabel = errorLabel else {
            let view = UILabel()
            view.lineBreakMode = .byWordWrapping
            view.numberOfLines = 0
            view.font = UIFont(name: fontName, size: errorFontSize)
            view.textColor = errorColor
            addSubview(view)
            self.errorLabel = view
            return view
        }
        return errorLabel
    }
    
    private func layout(_ animated: Bool = false) {
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        
        let inputHeight = inputFontSize + 2*textFieldGap
        let normalPlaceholderHeight = normalPlaceholderFontSize + 2*textFieldGap
        let focusedPlaceholderHeight = focusedPlaceholderFontSize + 2*textFieldGap
        let backgroundTop: CGFloat
        let backgroundHeight: CGFloat
        let inputTop: CGFloat
        let normalPlaceholderTop: CGFloat
        let floatingPlaceholderTop: CGFloat
        
        switch borderStyle {
        case .bottom:
            backgroundTop = 0
            backgroundHeight = topInset + focusedPlaceholderHeight + textInnerPadding + inputHeight + bottomInset
            inputTop = topInset + focusedPlaceholderHeight + textInnerPadding
            normalPlaceholderTop = (backgroundHeight - normalPlaceholderHeight) / 2
            floatingPlaceholderTop = topInset
        case .round:
            backgroundTop = focusedPlaceholderHeight / 2
            backgroundHeight = topInset + focusedPlaceholderHeight / 2 + textInnerPadding + inputHeight + bottomInset
            inputTop = backgroundTop + (topInset + focusedPlaceholderHeight) / 2 + textInnerPadding
            normalPlaceholderTop = inputTop + (inputHeight - normalPlaceholderHeight) / 2
            floatingPlaceholderTop = 0
        }
        
        var inputLeft = leftInset
        if let leftIconView = leftIconView {
            if leftIconView.image != nil {
                leftIconView.frame = CGRect(x: leftInset, y: backgroundTop + (backgroundHeight - leftIconSize)/2, width: leftIconSize, height: leftIconSize)
                inputLeft += leftIconSize + iconInnerPadding
                leftIconView.isHidden = false
            } else {
                leftIconView.isHidden = true
            }
        }
        var inputRight = rightInset
        if let rightIconView = rightIconView {
            if rightIconView.image != nil {
                rightIconView.frame = CGRect(x: frame.width - rightInset - rightIconSize, y: backgroundTop + (backgroundHeight - rightIconSize)/2, width: rightIconSize, height: rightIconSize)
                inputRight += rightIconSize + iconInnerPadding
                rightIconView.isHidden = false
            } else {
                rightIconView.isHidden = true
            }
        }
        
        let inputWidth = frame.width - inputLeft - inputRight
        textField.frame = CGRect(x: inputLeft, y: inputTop, width: inputWidth, height: inputHeight)
        
        
        let floatingPlaceholderLeft: CGFloat
        switch borderStyle {
        case .bottom:
            floatingPlaceholderLeft = inputLeft
        case .round:
            floatingPlaceholderLeft = max(cornerRadius, leftInset) + textFieldGap + placeholderErasePadding
        }
        
        if isPlaceholderFloating && placeholder?.isEmpty == false {
            placeholderLabel.frame = CGRect(x: floatingPlaceholderLeft, y: floatingPlaceholderTop, width: inputWidth, height: normalPlaceholderHeight) // normalPlaceholderHeight is not a mistake
        } else {
            placeholderLabel.frame = CGRect(x: inputLeft, y: normalPlaceholderTop, width: inputWidth, height: normalPlaceholderHeight)
        }
        
        if let errorLabel = errorLabel {
            errorLabel.frame = CGRect(x: leftInset, y: backgroundTop + backgroundHeight + textInnerPadding, width: bounds.width - leftInset - rightInset, height: bounds.height - backgroundTop - backgroundHeight - 2*textInnerPadding)
            if errorLabel.text?.isEmpty == false {
                errorLabel.isHidden = false
            } else {
                errorLabel.isHidden = true
            }
        }
        
        switch borderStyle {
        case .bottom:
            let backgroundRect = CGRect(x: 0, y: backgroundTop, width: bounds.width, height: backgroundHeight)
            backgroundLayer.path = UIBezierPath(roundedRect: backgroundRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: backgroundRect.maxY - normalLineWidth))
            path.addLine(to: CGPoint(x: backgroundRect.width, y: backgroundRect.maxY - normalLineWidth))
            borderLayer.path = path.cgPath

        case .round:
            backgroundLayer.path = nil
            
            let backgroundRect = CGRect(x: 0, y: backgroundTop, width: bounds.width, height: backgroundHeight)
            let path = UIBezierPath()
          
            // top-left
            path.addArc(withCenter: CGPoint(x: backgroundRect.minX + cornerRadius, y: backgroundRect.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: 3*CGFloat.pi/2, clockwise: true)
            
            if isPlaceholderFloating {
                // erase line for floating placeholder
                let startErase = floatingPlaceholderLeft - placeholderErasePadding
                let endErase = startErase + placeholderLabel.preferredFrameSize().width + 2 * placeholderErasePadding
                path.addLine(to: CGPoint(x: startErase, y: backgroundRect.minY))
                path.move(to: CGPoint(x: endErase, y: backgroundRect.minY))
            }

            // top line
            path.addLine(to: CGPoint(x: backgroundRect.maxX - cornerRadius, y: backgroundRect.minY))
            
            // top-right
            path.addArc(withCenter: CGPoint(x: backgroundRect.maxX - cornerRadius, y: backgroundRect.minY + cornerRadius), radius: cornerRadius, startAngle: 3*CGFloat.pi/2, endAngle: 0, clockwise: true)
        
            // right line
            path.addLine(to: CGPoint(x: backgroundRect.maxX, y: backgroundRect.maxY - cornerRadius))
            
            // bottom-right
            path.addArc(withCenter: CGPoint(x: backgroundRect.maxX - cornerRadius, y: backgroundRect.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)

            // bottom line
            path.addLine(to: CGPoint(x: backgroundRect.minX + cornerRadius, y: backgroundRect.maxY))

            // bottom-left
            path.addArc(withCenter: CGPoint(x: backgroundRect.minX + cornerRadius, y: backgroundRect.maxY - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
            
            // left line
            path.addLine(to: CGPoint(x: backgroundRect.minX, y: backgroundRect.minY + cornerRadius))

            borderLayer.path = path.cgPath
        }
        
        if !animated {
            CATransaction.commit()
        }
    }

    private func syncLayers(_ animated: Bool = false) {
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        if isPlaceholderFloating {
            placeholderLabel.fontSize = focusedPlaceholderFontSize
        } else {
            placeholderLabel.fontSize = normalPlaceholderFontSize
        }
        let isError = self.isError
        let isEnabled = self.isEnabled
        if isEditing && isEnabled {
            placeholderLabel.foregroundColor = (isError ? errorColor : focusedPlaceholderColor).cgColor
            backgroundLayer.fillColor = focusedBackgroundColor.cgColor
            backgroundLayer.strokeColor = nil
            borderLayer.strokeColor = (isError ? errorColor : focusedBorderColor).cgColor
            borderLayer.lineWidth = focusedLineWidth
            borderLayer.fillColor = nil
        } else {
            placeholderLabel.foregroundColor = (isError ? errorColor : normalPlaceholderColor).cgColor.copy(alpha: isEnabled ? 1.0 : disabledAlpha)
            backgroundLayer.fillColor = (isEnabled ? normalBackgroundColor : disabledBackgroundColor).cgColor
            backgroundLayer.strokeColor = nil
            borderLayer.strokeColor = (isError ? errorColor : normalBorderColor).cgColor.copy(alpha: isEnabled ? 1.0 : disabledAlpha)
            borderLayer.lineWidth = normalLineWidth
            borderLayer.fillColor = nil
        }
        textField.alpha = isPlaceholderFloating ? 1.0 : 0.0
        if !animated {
            CATransaction.commit()
        }
    }
    
    @objc private func focus() {
        textField.becomeFirstResponder()
        changeToFloat(animated: true)
    }

    @objc private func editingDidBegin() {
        changeToFloat(animated: true)
    }
    
    @objc private func editingDidEnd() {
        if let text = textField.text, text.count > 0 {
          changeToFloat(animated: true)
        } else {
          changeToIdle(animated: true)
        }
    }
    
    private func changeToFloat(animated: Bool) {
        layout(animated)
        syncLayers(animated)
    }
    
    private func changeToIdle(animated: Bool) {
        layout(animated)
        syncLayers(animated)
    }
}
