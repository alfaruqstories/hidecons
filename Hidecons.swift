import Cocoa
import ServiceManagement
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var isHidden = false
    var previousHidden: Bool? = nil
    var toggleItem: NSMenuItem!
    var undoItem: NSMenuItem!
    var launchAtLoginItem: NSMenuItem!
    var notificationsItem: NSMenuItem!
    var menu: NSMenu!
    var globalHotkeyMonitor: Any?

    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Read current Finder state
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.finder", "CreateDesktop"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        isHidden = (output == "0" || output == "false")

        // Status item — left click toggles, right click opens menu
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.action = #selector(handleClick)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Build menu
        menu = NSMenu()
        menu.delegate = self

        toggleItem = NSMenuItem(title: "", action: #selector(toggleDesktop), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        undoItem = NSMenuItem(title: "Undo", action: #selector(undoToggle), keyEquivalent: "z")
        undoItem.target = self
        undoItem.isEnabled = false
        menu.addItem(undoItem)

        menu.addItem(NSMenuItem.separator())

        launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)

        notificationsItem = NSMenuItem(title: "Notify on Toggle", action: #selector(toggleNotifications), keyEquivalent: "")
        notificationsItem.target = self
        menu.addItem(notificationsItem)

        menu.addItem(NSMenuItem.separator())

        let bugItem = NSMenuItem(title: "Report a Bug", action: #selector(reportBug), keyEquivalent: "")
        bugItem.target = self
        menu.addItem(bugItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        NSApp.setActivationPolicy(.accessory)

        // Global hotkey: ⌥⌘H (keyCode 4 = H)
        globalHotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection([.option, .command, .shift, .control])
            guard flags == [.option, .command], event.keyCode == 4 else { return }
            self?.toggleDesktop()
        }

        updateUI()
    }

    // Left click: instant toggle. Right click: menu.
    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            updateLaunchAtLoginItem()   // always fresh on open
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
        } else {
            toggleDesktop()
        }
    }

    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }

    @objc func toggleDesktop() {
        let newHidden = !isHidden
        let value = newHidden ? "false" : "true"

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", value]
        try? task.run()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else { return }

        previousHidden = isHidden   // store for undo
        isHidden = newHidden

        let killTask = Process()
        killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killTask.arguments = ["-HUP", "Finder"]
        try? killTask.run()

        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)

        if notificationsEnabled {
            sendToggleNotification()
        }

        updateUI()
    }

    @objc func undoToggle() {
        guard let prev = previousHidden else { return }

        let value = prev ? "false" : "true"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", value]
        try? task.run()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else { return }

        isHidden = prev
        previousHidden = nil

        let killTask = Process()
        killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killTask.arguments = ["-HUP", "Finder"]
        try? killTask.run()

        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        updateUI()
    }

    @objc func toggleLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            if SMAppService.mainApp.status == .enabled {
                try? SMAppService.mainApp.unregister()
            } else {
                try? SMAppService.mainApp.register()
            }
        } else {
            let plistPath = (NSHomeDirectory() as NSString)
                .appendingPathComponent("Library/LaunchAgents/com.hidecons.app.plist")
            if FileManager.default.fileExists(atPath: plistPath) {
                try? FileManager.default.removeItem(atPath: plistPath)
            } else {
                let execPath = ProcessInfo.processInfo.arguments[0]
                let plist: [String: Any] = [
                    "Label": "com.hidecons.app",
                    "ProgramArguments": [execPath],
                    "RunAtLoad": true
                ]
                (plist as NSDictionary).write(toFile: plistPath, atomically: true)
            }
        }
        updateLaunchAtLoginItem()
    }

    @objc func toggleNotifications() {
        if notificationsEnabled {
            notificationsEnabled = false
            updateNotificationsItem()
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                DispatchQueue.main.async {
                    self.notificationsEnabled = granted
                    self.updateNotificationsItem()
                }
            }
        }
    }

    @objc func reportBug() {
        NSWorkspace.shared.open(URL(string: "https://github.com/alfaruqstories/hidecons/issues")!)
    }

    @objc func quit() {
        if let monitor = globalHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        NSApp.terminate(nil)
    }

    func sendToggleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hidecons"
        content.body = isHidden ? "Desktop icons hidden" : "Desktop icons visible"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func updateUI() {
        if let button = statusItem.button {
            let symbol = isHidden ? "square.grid.2x2.fill" : "square.grid.2x2"
            if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Hidecons") {
                image.isTemplate = true     // adapts to dark/light menu bar automatically
                button.image = image
            }
            button.toolTip = isHidden ? "Desktop icons: hidden" : "Desktop icons: visible"
        }
        updateToggleItem()
        updateUndoItem()
        updateLaunchAtLoginItem()
        updateNotificationsItem()
    }

    func updateToggleItem() {
        toggleItem.title = isHidden ? "Show Desktop Icons" : "Hide Desktop Icons"
    }

    func updateUndoItem() {
        if let prev = previousHidden {
            undoItem.title = prev ? "Undo — Restore Icons" : "Undo — Hide Icons"
            undoItem.isEnabled = true
        } else {
            undoItem.title = "Undo"
            undoItem.isEnabled = false
        }
    }

    func updateLaunchAtLoginItem() {
        if #available(macOS 13.0, *) {
            launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        } else {
            let plistPath = (NSHomeDirectory() as NSString)
                .appendingPathComponent("Library/LaunchAgents/com.hidecons.app.plist")
            launchAtLoginItem.state = FileManager.default.fileExists(atPath: plistPath) ? .on : .off
        }
    }

    func updateNotificationsItem() {
        notificationsItem.state = notificationsEnabled ? .on : .off
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
