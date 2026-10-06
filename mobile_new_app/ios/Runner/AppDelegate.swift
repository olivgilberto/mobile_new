import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Before any Dart code opens a database.
    excludeLocalDatabasesFromBackup()
    // Background isolate used by workmanager needs the plugins too.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // Must match WorkmanagerSyncScheduler.taskName and the
    // BGTaskSchedulerPermittedIdentifiers entry in Info.plist.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "outbox_sync",
      earliestBeginInSeconds: NSNumber(value: 60 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Must match `SqlcipherLocalDatabaseFactory.directoryName`
  /// (adapter_db_sqlcipher), inside Library/Application Support — never
  /// Documents, which the Files app can expose.
  private let localDatabasesDirectory = "local_databases"

  /// Keeps every module's encrypted database out of iCloud/computer
  /// backups. The flag on the folder covers its current and future files
  /// (`-wal`, `-journal` included). Idempotent: runs on every launch.
  private func excludeLocalDatabasesFromBackup() {
    guard let applicationSupport = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first else { return }
    // Created with intermediates: Application Support may not exist yet.
    var directory = applicationSupport.appendingPathComponent(localDatabasesDirectory, isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try directory.setResourceValues(values)
    } catch {
      NSLog("Could not exclude \(localDatabasesDirectory) from backup: \(error)")
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
