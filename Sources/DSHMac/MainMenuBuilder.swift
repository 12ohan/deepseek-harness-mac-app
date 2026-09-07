import AppKit

/// Stable tags used by AppDelegate's menu validation and by regression tests.
enum MainMenuCommandTag: Int {
  case settings = 1001
  case newSession
  case openInBrowser
  case printPage
  case find
  case findNext
  case findPrevious
  case focusSessionSearch
  case toggleSidebar
  case reload
  case actualSize
  case zoomIn
  case zoomOut
  case help
}

struct MainMenuSet {
  let main: NSMenu
  let services: NSMenu
  let windows: NSMenu
  let help: NSMenu
}

/// Constructs the standard macOS menu hierarchy in one testable place.
enum MainMenuBuilder {
  static func build(appName: String, target: AppDelegate) -> MainMenuSet {
    let main = NSMenu(title: "Main")

    // Application
    let appMenu = NSMenu(title: appName)
    appMenu.addItem(item(
      "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:))))
    appMenu.addItem(.separator())
    appMenu.addItem(item(
      "Settings…", action: #selector(AppDelegate.showSettingsAction(_:)), key: ",",
      target: target, tag: .settings))
    appMenu.addItem(.separator())
    let services = NSMenu(title: "Services")
    let servicesItem = NSMenuItem(title: "Services", action: nil, keyEquivalent: "")
    servicesItem.submenu = services
    appMenu.addItem(servicesItem)
    appMenu.addItem(.separator())
    appMenu.addItem(item(
      "Hide \(appName)", action: #selector(NSApplication.hide(_:)), key: "h"))
    appMenu.addItem(item(
      "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), key: "h",
      modifiers: [.command, .option]))
    appMenu.addItem(item("Show All", action: #selector(NSApplication.unhideAllApplications(_:))))
    appMenu.addItem(.separator())
    appMenu.addItem(item(
      "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), key: "q"))
    main.addItem(topLevel(appName, submenu: appMenu))

    // File / session lifecycle
    let fileMenu = NSMenu(title: "File")
    fileMenu.addItem(item(
      "New Session", action: #selector(AppDelegate.newSessionAction(_:)), key: "n",
      target: target, tag: .newSession))
    fileMenu.addItem(.separator())
    fileMenu.addItem(item(
      "Open in Browser", action: #selector(AppDelegate.openInBrowserAction(_:)), key: "O",
      modifiers: [.command, .shift], target: target, tag: .openInBrowser))
    fileMenu.addItem(item(
      "Print…", action: #selector(AppDelegate.printPageAction(_:)), key: "p",
      target: target, tag: .printPage))
    fileMenu.addItem(.separator())
    fileMenu.addItem(item(
      "Close Window", action: #selector(NSWindow.performClose(_:)), key: "w"))
    main.addItem(topLevel("File", submenu: fileMenu))

    // Edit
    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(item("Undo", action: NSSelectorFromString("undo:"), key: "z"))
    editMenu.addItem(item(
      "Redo", action: NSSelectorFromString("redo:"), key: "Z", modifiers: [.command, .shift]))
    editMenu.addItem(.separator())
    editMenu.addItem(item("Cut", action: NSSelectorFromString("cut:"), key: "x"))
    editMenu.addItem(item("Copy", action: NSSelectorFromString("copy:"), key: "c"))
    editMenu.addItem(item("Paste", action: NSSelectorFromString("paste:"), key: "v"))
    editMenu.addItem(item(
      "Paste and Match Style", action: NSSelectorFromString("pasteAsPlainText:"), key: "V",
      modifiers: [.command, .option, .shift]))
    editMenu.addItem(item("Select All", action: NSSelectorFromString("selectAll:"), key: "a"))
    editMenu.addItem(.separator())

    let findMenu = NSMenu(title: "Find")
    findMenu.addItem(item(
      "Find…", action: #selector(AppDelegate.showFindAction(_:)), key: "f",
      target: target, tag: .find))
    findMenu.addItem(item(
      "Find Next", action: #selector(AppDelegate.findNextAction(_:)), key: "g",
      target: target, tag: .findNext))
    findMenu.addItem(item(
      "Find Previous", action: #selector(AppDelegate.findPreviousAction(_:)), key: "G",
      modifiers: [.command, .shift], target: target, tag: .findPrevious))
    findMenu.addItem(.separator())
    findMenu.addItem(item(
      "Focus Session Search", action: #selector(AppDelegate.focusSessionSearchAction(_:)), key: "f",
      modifiers: [.command, .option], target: target, tag: .focusSessionSearch))
    let findItem = NSMenuItem(title: "Find", action: nil, keyEquivalent: "")
    findItem.submenu = findMenu
    editMenu.addItem(findItem)

    let spellingMenu = NSMenu(title: "Spelling and Grammar")
    spellingMenu.addItem(item(
      "Show Spelling and Grammar", action: NSSelectorFromString("showGuessPanel:"), key: ":",
      modifiers: [.command]))
    spellingMenu.addItem(item(
      "Check Document Now", action: NSSelectorFromString("checkSpelling:"), key: ";"))
    spellingMenu.addItem(.separator())
    spellingMenu.addItem(item(
      "Check Spelling While Typing", action: NSSelectorFromString("toggleContinuousSpellChecking:")))
    spellingMenu.addItem(item(
      "Check Grammar With Spelling", action: NSSelectorFromString("toggleGrammarChecking:")))
    spellingMenu.addItem(item(
      "Automatically Correct Spelling", action: NSSelectorFromString("toggleAutomaticSpellingCorrection:")))
    let spellingItem = NSMenuItem(title: "Spelling and Grammar", action: nil, keyEquivalent: "")
    spellingItem.submenu = spellingMenu
    editMenu.addItem(spellingItem)

    let substitutionsMenu = NSMenu(title: "Substitutions")
    substitutionsMenu.addItem(item(
      "Smart Quotes", action: NSSelectorFromString("toggleSmartQuotes:")))
    substitutionsMenu.addItem(item(
      "Smart Dashes", action: NSSelectorFromString("toggleSmartDashes:")))
    substitutionsMenu.addItem(item(
      "Text Replacement", action: NSSelectorFromString("toggleAutomaticTextReplacement:")))
    let substitutionsItem = NSMenuItem(title: "Substitutions", action: nil, keyEquivalent: "")
    substitutionsItem.submenu = substitutionsMenu
    editMenu.addItem(substitutionsItem)

    let speechMenu = NSMenu(title: "Speech")
    speechMenu.addItem(item("Start Speaking", action: NSSelectorFromString("startSpeaking:")))
    speechMenu.addItem(item("Stop Speaking", action: NSSelectorFromString("stopSpeaking:")))
    let speechItem = NSMenuItem(title: "Speech", action: nil, keyEquivalent: "")
    speechItem.submenu = speechMenu
    editMenu.addItem(speechItem)
    main.addItem(topLevel("Edit", submenu: editMenu))

    // View
    let viewMenu = NSMenu(title: "View")
    viewMenu.addItem(item(
      "Toggle Sidebar", action: #selector(AppDelegate.toggleSidebarAction(_:)), key: "s",
      modifiers: [.command, .option], target: target, tag: .toggleSidebar))
    viewMenu.addItem(.separator())
    viewMenu.addItem(item(
      "Reload", action: #selector(AppDelegate.reloadPageAction(_:)), key: "r",
      target: target, tag: .reload))
    viewMenu.addItem(.separator())
    viewMenu.addItem(item(
      "Actual Size", action: #selector(AppDelegate.actualSizeAction(_:)), key: "0",
      target: target, tag: .actualSize))
    viewMenu.addItem(item(
      "Zoom In", action: #selector(AppDelegate.zoomInAction(_:)), key: "+",
      target: target, tag: .zoomIn))
    viewMenu.addItem(item(
      "Zoom Out", action: #selector(AppDelegate.zoomOutAction(_:)), key: "-",
      target: target, tag: .zoomOut))
    viewMenu.addItem(.separator())
    viewMenu.addItem(item(
      "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), key: "f",
      modifiers: [.command, .control]))
    main.addItem(topLevel("View", submenu: viewMenu))

    // Window
    let windowMenu = NSMenu(title: "Window")
    windowMenu.addItem(item(
      "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), key: "m"))
    windowMenu.addItem(item("Zoom", action: #selector(NSWindow.performZoom(_:))))
    windowMenu.addItem(.separator())
    windowMenu.addItem(item(
      "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:))))
    main.addItem(topLevel("Window", submenu: windowMenu))

    // Help
    let helpMenu = NSMenu(title: "Help")
    helpMenu.addItem(item(
      "DeepSeek Harness Help", action: #selector(AppDelegate.showHelpAction(_:)), key: "?",
      modifiers: [.command, .shift], target: target, tag: .help))
    main.addItem(topLevel("Help", submenu: helpMenu))

    return MainMenuSet(main: main, services: services, windows: windowMenu, help: helpMenu)
  }

  private static func topLevel(_ title: String, submenu: NSMenu) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    menuItem.submenu = submenu
    return menuItem
  }

  private static func item(
    _ title: String,
    action: Selector?,
    key: String = "",
    modifiers: NSEvent.ModifierFlags = [.command],
    target: AnyObject? = nil,
    tag: MainMenuCommandTag? = nil
  ) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
    if !key.isEmpty { menuItem.keyEquivalentModifierMask = modifiers }
    menuItem.target = target
    if let tag { menuItem.tag = tag.rawValue }
    return menuItem
  }
}
