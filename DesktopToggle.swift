import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var isHidden = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.finder", "CreateDesktop"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        task.launch()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        isHidden = (output == "0" || output == "false")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()

        let menu = NSMenu()
        let toggleItem = NSMenuItem(title: "Toggle Desktop Icons", action: #selector(toggleDesktop), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu

        NSApp.setActivationPolicy(.accessory)
    }

    @objc func toggleDesktop() {
        isHidden.toggle()
        let value = isHidden ? "false" : "true"

        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", value]
        task.launch()
        task.waitUntilExit()

        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["-HUP", "Finder"]
        killTask.launch()

        updateIcon()
    }

    @objc func quit() {
        if isHidden {
            let task = Process()
            task.launchPath = "/usr/bin/defaults"
            task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", "true"]
            task.launch()
            task.waitUntilExit()

            let killTask = Process()
            killTask.launchPath = "/usr/bin/killall"
            killTask.arguments = ["Finder"]
            killTask.launch()
        }
        NSApp.terminate(nil)
    }

    func updateIcon() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: isHidden ? "eye.slash" : "eye", accessibilityDescription: "Desktop Toggle")
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
