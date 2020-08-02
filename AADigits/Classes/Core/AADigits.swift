//
//  AADigits.swift
//  AADigits
//
//  Created by Adolfho Athyla on 31/07/20.
//  Copyright © 2020 a7hyla. All rights reserved.
//

import UIKit

public protocol AADigitsProtocol {
    
    //get only properties
    var mainColor: UIColor! { get }
    var errorColor: UIColor! { get }
    var borderWidth: CGFloat! { get }
    var borderRadius: CGFloat! { get }
    var isSecureTextEntry: Bool { get }
    
    //callbacks
    var full: ((_ text: String) -> ())? { get set }
    var incomplete: (() -> ())? { get set }
    
    //public methods
    func err()
    func fix()
    func swapSecureTextEntry()
    func resignFirstResponder()
}

open class AADigits: NSObject, UITextFieldDelegate, AADigitsProtocol {
    
    open var fields: [UITextField]!
    
    open var full: ((_ text: String) -> ())?
    open var incomplete: (() -> ())?
    
    open var mainColor: UIColor!
    open var errorColor: UIColor!
    open var borderWidth: CGFloat!
    open var borderRadius: CGFloat!
    
    open var isSecureTextEntry: Bool {
        return fields.first!.isSecureTextEntry
    }
    
    // MARK: - Init Methods
    public init(fields: [UITextField],
         isSecureTextEntry: Bool = false,
         isSMSCode: Bool = false,
         mainColor: UIColor = Colors.defaultMainColor,
         errorColor: UIColor = Colors.defaultErrorColor,
         borderWidth: CGFloat = 2.0,
         borderRadius: CGFloat = 5.0,
         keyboardType: UIKeyboardType = .numberPad) {
        super.init()
        self.fields = fields
        self.mainColor = mainColor
        self.errorColor = errorColor
        self.borderWidth = borderWidth
        self.borderRadius = borderRadius
        self.prepare(keyboardType: keyboardType,
                     isSecureTextEntry:
            isSecureTextEntry, isSMSCode: isSMSCode)
    }
    
    private func prepare(keyboardType: UIKeyboardType, isSecureTextEntry: Bool, isSMSCode: Bool) {
        for field in fields {
            field.delegate = self
            field.textAlignment = .center
            field.borderStyle = .none
            field.inputAccessoryView = UIView()
            field.tintColor = mainColor
            field.text = "\u{200B}"
            field.keyboardType = keyboardType
            field.isSecureTextEntry = isSecureTextEntry
            prepare(field: field)
            isSMSCode ? prepareToSMSCode(field: field) : nil
        }
    }
    
    private func prepare(field: UITextField) {
        field.layer.borderColor = mainColor.cgColor
        field.layer.borderWidth = borderWidth
        field.round(with: borderRadius)
    }
    
    private func prepareToSMSCode(field: UITextField) {
        if #available(iOS 12.0, *) {
            field.textContentType = .oneTimeCode
        }
        field.text = ""
    }
    
    // MARK: - Public Methods
    open func err() {
        for field in fields {
            field.layer.borderColor = errorColor.cgColor
            field.layer.borderWidth = borderWidth
            field.round(with: borderRadius)
        }
    }
    
    open func fix() {
        for field in fields {
            field.layer.borderColor = mainColor.cgColor
            field.layer.borderWidth = borderWidth
            field.round(with: borderRadius)
        }
    }
    
    open func swapSecureTextEntry() {
        fields.forEach { (field) in
            field.isSecureTextEntry = !field.isSecureTextEntry
        }
    }
    
    open func resignFirstResponder() {
        for field in fields {
            field.resignFirstResponder()
        }
    }
    
    
    // MARK: - Private Methods
    private func getIndex(of textField: UITextField) -> Int? {
        return fields.firstIndex(of: textField)
    }
    
    private func getTextField(at index: Int) -> UITextField? {
        return index >= fields.startIndex && index <= (fields.endIndex-1) ? fields[index] : nil
    }
    
    private func isFull() -> Bool {
        let mandatoryFields = fields.filter { (field) -> Bool in
            return field.text != nil && !field.text!.isEmpty && field.text! != "\u{200B}"
        }
        return mandatoryFields.count == fields!.count
    }
    
    // MARK: - UITextField delegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let fullFields = fields.filter { (field) -> Bool in
            guard let text = field.text else { return false }
            return !text.isEmpty && text != "\u{200B}"
        }
        if fullFields.count == 0 {
            guard let first = fields.first, !first.isFirstResponder else { return }
            DispatchQueue.main.async {
                first.becomeFirstResponder()
            }
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if isFull() {
            let text = fields.reduce("") { (concat, field) -> String in
                guard let text = field.text, !text.isEmpty, text != "\u{200B}" else { return "" }
                return concat + text
            }
            if let full = full {
                full(text)
            }
        } else {
            if let incomplete = incomplete {
                incomplete()
            }
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let index = getIndex(of: textField) else { return false }
        
        guard !string.isEmpty else {
            guard let prev = getTextField(at: index-1) else {
                if let incomplete = incomplete {
                    incomplete()
                }
                return true
            }
            if let text = textField.text, !text.isEmpty {
                textField.text = "\u{200B}"
            } else {
                prev.text = "\u{200B}"
            }
            prev.becomeFirstResponder()
            return false
        }
        
        guard let next = getTextField(at: index+1) else {
            textField.text = string
            resignFirstResponder()
            return true
        }
        if let text = textField.text, !text.isEmpty, text != "\u{200B}" {
            if let nextText = next.text, !nextText.isEmpty, nextText != "\u{200B}" {
                textField.text = string
            } else {
                next.text = string
            }
        } else {
            textField.text = string
        }
        guard isFull() else {
            next.becomeFirstResponder()
            return true
        }
        resignFirstResponder()
        return true
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
}

