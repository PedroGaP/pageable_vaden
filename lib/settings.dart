class Settings {
  static String? dbHost;
  static String? dbDatabase;
  static String? dbUser;
  static String? dbPassword;
  static int? dbPort;

  bool get isInitialized =>
      !((dbHost == null || dbHost!.isEmpty) ||
          (dbDatabase == null || dbDatabase!.isEmpty) ||
          (dbUser == null || dbUser!.isEmpty));

  String? get host => dbHost;
  String? get database => dbDatabase;
  String? get user => dbUser;
  String? get password => dbPassword;
  int? get port => dbPort;

  Settings({
    required String host,
    required String database,
    required String user,
    String? password = "",
    int? port = 3306,
  }) {
    dbHost ??= host;
    dbDatabase ??= database;
    dbUser ??= user;
    dbPassword ??= password;
    dbPort ??= port;
  }

  factory Settings.getInstance() => Settings(
    host: dbHost ?? "",
    database: dbDatabase ?? "",
    user: dbUser ?? "",
    password: dbPassword,
    port: dbPort,
  );
}
