enum ConnectivityStatus {
  /// Not checked yet (boot): no banner, no sync trigger.
  unknown,

  /// No network interface (airplane mode, Wi-Fi and mobile data off).
  offline,

  /// A network interface exists, but the backend does not answer
  /// (e.g. Wi-Fi without internet, captive portal).
  noInternet,

  /// The backend answers.
  online,
}
