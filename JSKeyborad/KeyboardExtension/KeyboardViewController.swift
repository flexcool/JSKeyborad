import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    private var hostingController: UIHostingController<KeyboardView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateKeyboardHeight()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateAppearance()
    }
    
    private func setupKeyboardView() {
        let keyboardView = KeyboardView(
            onTextInsert: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onTextDelete: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            contextProvider: self
        )
        
        let hosting = UIHostingController(rootView: keyboardView)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)
        view.addSubview(hosting.view)
        
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hosting.didMove(toParent: self)
        hostingController = hosting
    }
    
    private func updateKeyboardHeight() {
        let height: CGFloat
        switch DataStore.shared.settings.keyboardHeight {
        case .compact:
            height = 180
        case .standard:
            height = 216
        case .tall:
            height = 260
        }
        
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight > 667 {
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        }
    }
    
    private func updateAppearance() {
        if let proxy = textDocumentProxy as UITextInputTraits? {
            let isDark = proxy.keyboardAppearance == .dark
            hostingController?.rootView.updateAppearance(isDark: isDark)
        }
    }
}

extension KeyboardViewController: KeyboardContextProviding {
    var documentContextBeforeInput: String? {
        textDocumentProxy.documentContextBeforeInput
    }
    
    var documentContextAfterInput: String? {
        textDocumentProxy.documentContextAfterInput
    }
    
}
