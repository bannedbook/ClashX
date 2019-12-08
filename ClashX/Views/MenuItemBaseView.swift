//
//  MenuItemBaseView.swift
//  ClashX
//
//  Created by yicheng on 2019/11/1.
//  Copyright © 2019 west2online. All rights reserved.
//

import Carbon
import Cocoa

class MenuItemBaseView: NSView {
    private var isMouseInsideView = false
    private var isMenuOpen = false
    private var eventHandler: EventHandlerRef?
    private let handleClick: Bool
    private let autolayout: Bool

    deinit {
        freeEventHandler()
    }

    // MARK: Public

    var isHighlighted: Bool {
        let enable = enclosingMenuItem?.isEnabled ?? true
        return (isMouseInsideView || isMenuOpen) && enable
    }

    let effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.material = .popover
        effectView.state = .active
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow
        return effectView
    }()

    var labels: [NSTextField] {
        assertionFailure("Please override")
        return []
    }

    static let labelFont = NSFont.menuFont(ofSize: 14)

    init(frame frameRect: NSRect = NSRect(x: 0, y: 0, width: 0, height: 20),
         handleClick: Bool,
         autolayout: Bool) {
        self.handleClick = handleClick
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

    func updateBackground(_ label: NSTextField) {
        label.cell?.backgroundStyle = isHighlighted ? .emphasized : .normal
    }

    // MARK: Private

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        // background
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        effectView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        effectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func updateCarbon() {
        if window != nil {
            freeEventHandler()
            if let dispatcher = GetEventDispatcherTarget() {
                let eventHandlerCallback: EventHandlerUPP = { eventHandlerCallRef, eventRef, userData in
                    guard let userData = userData else { return 0 }
                    let itemView: MenuItemBaseView = bridge(ptr: userData)
                    itemView.didClickView()
                    return 0
                }

                let eventSpecs = [EventTypeSpec(eventClass: OSType(kEventClassMouse), eventKind: UInt32(kEventMouseUp))]

                InstallEventHandler(dispatcher, eventHandlerCallback, 1, eventSpecs, bridge(obj: self), &eventHandler)
            }
        } else {
            freeEventHandler()
        }
    }

    private func freeEventHandler() {
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    // MARK: Override

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        effectView.material = isHighlighted ? .selection : .popover
        labels.forEach { updateBackground($0) }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if handleClick {
            updateCarbon()
        }
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
        trackingAreas.forEach { removeTrackingArea($0) }
        enclosingMenuItem?.submenu?.delegate = self
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    }

    override func mouseEntered(with event: NSEvent) {
        isMouseInsideView = true
        setNeedsDisplay()
    }

    override func mouseExited(with event: NSEvent) {
        isMouseInsideView = false
        setNeedsDisplay()
    }
}

extension MenuItemBaseView: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        isMenuOpen = true
        setNeedsDisplay()
    }

    func menuDidClose(_ menu: NSMenu) {
        isMenuOpen = false
        setNeedsDisplay()
    }
}
