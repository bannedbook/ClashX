//
//  MenuItemBaseView.swift
//  ClashX
//
//  Created by yicheng on 2019/11/1.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class MenuItemBaseView: NSView {
    private var isMouseInsideView = false
    private var isMenuOpen = false
    private let autolayout: Bool

    // MARK: Public

    var isHighlighted: Bool = false

    let effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.material = .popover
        effectView.state = .active
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow
        return effectView
    }()

    var cells: [NSCell?] {
        assertionFailure("Please override")
        return []
    }

    var labels: [NSTextField] {
        return []
    }

    static let labelFont: NSFont = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)

    init(frame frameRect: NSRect = NSRect(x: 0, y: 0, width: 0, height: 20), autolayout: Bool) {
        self.autolayout = autolayout
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setNeedsDisplay() {
        needsDisplay = true
    }

    func didClickView() {
        assertionFailure("Please override this method")
    }

    // MARK: Private

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        // background
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        if autolayout {
            effectView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            effectView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            effectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    // MARK: Override

    override func layout() {
        super.layout()
        if !autolayout {
            effectView.frame = bounds
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        labels.forEach { $0.textColor = (enclosingMenuItem?.isEnabled ?? true) ? NSColor.labelColor : NSColor.placeholderTextColor }
        let highlighted = isHighlighted && (enclosingMenuItem?.isEnabled ?? false)
        effectView.material = highlighted ? .selection : .popover
        cells.forEach { $0?.backgroundStyle = isHighlighted ? .emphasized : .normal }
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if let newWindow = newWindow, !newWindow.isKeyWindow {
            newWindow.becomeKey()
        }
        updateTrackingAreas()
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        guard autolayout else { return }
        if #available(macOS 10.15, *) {} else {
            if let view = superview {
                view.autoresizingMask = [.width]
            }
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
    }

    override func mouseUp(with event: NSEvent) {
        DispatchQueue.main.async {
            self.didClickView()
        }
    }
}
