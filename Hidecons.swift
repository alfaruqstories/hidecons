import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var isHidden = false
    var toggleItem: NSMenuItem!
    var launchAtLoginItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.finder", "CreateDesktop"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        isHidden = (output == "0" || output == "false")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let menu = NSMenu()

        toggleItem = NSMenuItem(title: "", action: #selector(toggleDesktop), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        NSApp.setActivationPolicy(.accessory)

        updateUI()
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

        isHidden = newHidden

        let killTask = Process()
        killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killTask.arguments = ["-HUP", "Finder"]
        try? killTask.run()

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
            let plistPath = (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAgents/com.hidecons.app.plist")
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

    @objc func quit() {
        if isHidden {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
            task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", "true"]
            try? task.run()
            task.waitUntilExit()

            let killTask = Process()
            killTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
            killTask.arguments = ["-HUP", "Finder"]
            try? killTask.run()
            killTask.waitUntilExit()
        }
        NSApp.terminate(nil)
    }

    func updateUI() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: isHidden ? "eye.slash" : "eye", accessibilityDescription: "Hidecons")
        }
        updateToggleItem()
        updateLaunchAtLoginItem()
    }

    func updateToggleItem() {
        toggleItem.title = isHidden ? "Show Desktop Icons" : "Hide Desktop Icons"
    }

    func updateLaunchAtLoginItem() {
        if #available(macOS 13.0, *) {
            launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        } else {
            let plistPath = (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAgents/com.hidecons.app.plist")
            launchAtLoginItem.state = FileManager.default.fileExists(atPath: plistPath) ? .on : .off
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
