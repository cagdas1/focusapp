import AppKit

class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusBarItem: NSStatusItem
    private var menu: NSMenu
    private var textInputWindowController: TextInputWindowController?

    private var activeTask: String? {
        didSet {
            updateStatusBarItemTitle()
        }
    }

    private var taskList: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: "taskList") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "taskList")
            updateMenuItems()
        }
    }

    override init() {
        statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()

        super.init()

        let tasks = UserDefaults.standard.stringArray(forKey: "taskList") ?? []
        taskList = tasks
        activeTask = taskList.first // Set the first task as active, if any

        updateMenuItems()
        updateStatusBarItemTitle() // Update the status bar item title on initialization
    }

    private func updateMenuItems() {
        menu.removeAllItems()

        for (index, task) in taskList.enumerated() {
            let menuItem = NSMenuItem(title: task, action: nil, keyEquivalent: "")
            
            let activateItem = NSMenuItem(title: "Activate", action: #selector(activateTask(_:)), keyEquivalent: "")
            activateItem.target = self
            activateItem.representedObject = task
            
            let deleteItem = NSMenuItem(title: "Remove", action: #selector(deleteTask(_:)), keyEquivalent: "")
            deleteItem.target = self
            deleteItem.representedObject = index

            menuItem.submenu = NSMenu()
            menuItem.submenu?.items = [activateItem, deleteItem]
            menu.addItem(menuItem)
        }

        menu.addItem(NSMenuItem.separator())
        addTaskAndQuitMenuItems()
        statusBarItem.menu = menu
    }

    private func updateStatusBarItemTitle() {
        let statusTitle = "✅" + (activeTask.map { " \($0)" } ?? "")
        statusBarItem.button?.title = statusTitle
    }

    @objc func showTextInputWindow() {
        if textInputWindowController == nil {
            textInputWindowController = TextInputWindowController()
            textInputWindowController?.onSubmit = { [weak self] text in
                self?.addTask(task: text)
            }
        }
        textInputWindowController?.textField.stringValue = "" // Clear the text field each time
        textInputWindowController?.showWindow()
    }

    @objc func addTask(task: String) {
        taskList.append(task)
    }

    @objc func deleteTask(_ sender: NSMenuItem) {
        if let index = sender.representedObject as? Int, taskList.indices.contains(index) {
            if let active = activeTask, taskList[index] == active {
                activeTask = nil
            }
            taskList.remove(at: index)
        }
    }

    @objc func activateTask(_ sender: NSMenuItem) {
        if let task = sender.representedObject as? String {
            activeTask = task
        }
    }

    private func addTaskAndQuitMenuItems() {
        let addTaskItem = NSMenuItem(title: "Add Task...", action: #selector(showTextInputWindow), keyEquivalent: "n")
        addTaskItem.target = self
        menu.addItem(addTaskItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
