import 'dart:async';
import 'package:mysql1/mysql1.dart';
import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';
import 'package:pageable_vaden/repository/base_repository.dart';
import 'package:pageable_vaden/settings.dart';
import 'package:pageable_vaden/sort.dart';

typedef FromMap<T> = T Function(Map<String, dynamic>);

/// The class for MySqlRepository implementation
///
/// The content is saved on a server for the credentials given
abstract class MySqlRepository<T extends BaseModel, ID>
    extends BaseRepository<T, ID> {
  /// Override this in every model to return the table name
  FromMap<T>? get fromMap;

  /// Override this in every model to return the table name
  String? get tableName;

  /// Override this in every model to return the table id column
  String? get idColumn;

  MySqlRepository();

  Future<MySqlConnection> _connect() async {
    final settings = Settings.getInstance();
    return await MySqlConnection.connect(
      ConnectionSettings(
        host: settings.host!,
        db: settings.database!,
        user: settings.user!,
        password: settings.password!,
        port: settings.port!,
      ),
    );
  }

  Future<void> _verifySettings() async {
    Settings settings = Settings.getInstance();

    if (!settings.isInitialized) {
      throw Exception(
        "The connection settings for MySqlRepository was not initialized.",
      );
    }

    if (tableName == null) throw Exception("The table name was not given.");
    if (idColumn == null) throw Exception("The colum id was not given.");
    if (fromMap == null) throw Exception("The fromMap function was not given.");
  }

  @override
  FutureOr<Page<T>> findAll({Pageable? pageable}) async {
    await _verifySettings();

    final limit = pageable!.size;
    final offset = pageable.offset;

    final conn = await _connect();

    try {
      final List<Sort> sorts = pageable.sort;

      String orderBy = sorts.isNotEmpty ? "Order By " : "";

      orderBy = orderBy + sorts.join(",");

      final res = await conn.query(
        'SELECT *, COUNT(*) OVER() AS total FROM $tableName $orderBy LIMIT ? OFFSET ?;',
        [limit, offset],
      );

      final int totalElements = res.isNotEmpty
          ? (res.first['total'] as int? ?? 0)
          : 0;

      final List<T> content = res.map((row) {
        final map = <String, dynamic>{};
        for (final col in row.fields.keys) {
          map[col] = row[col];
        }
        return fromMap!(map);
      }).toList();

      return Page(
        content: content,
        size: pageable.size,
        number: pageable.page,
        totalElements: totalElements,
      );
    } catch (e, stacktrace) {
      throw Exception(
        "Error while fetching data from server: ${e.toString()}\nStackTrace: $stacktrace",
      );
    }
  }

  @override
  FutureOr<T?> findById(ID id) async {
    await _verifySettings();

    final conn = await _connect();

    try {
      final res = await conn.query(
        'SELECT * FROM $tableName WHERE $idColumn = ?;',
        [id],
      );

      if (res.isEmpty) {
        return null;
      }

      final map = <String, dynamic>{};
      for (final col in res.first.fields.keys) {
        map[col] = res.first[col];
      }

      T data = fromMap!(map);

      return data;
    } catch (e, stacktrace) {
      throw Exception(
        "Error while fetching data from server: ${e.toString()}\nStackTrace: $stacktrace",
      );
    }
  }

  @override
  FutureOr<bool> remove(ID id) async {
    await _verifySettings();

    final conn = await _connect();

    try {
      final res = await conn.query(
        'Delete FROM $tableName where $idColumn = ?;',
        [id],
      );

      return !(res.affectedRows == null || res.affectedRows! < 1);
    } catch (e, stacktrace) {
      throw Exception(
        "Error while fetching data from server: ${e.toString()}\nStackTrace: $stacktrace",
      );
    }
  }

  @override
  FutureOr<T?> save(BaseModel model, {SaveType? type = SaveType.insert}) async {
    await _verifySettings();

    final conn = await _connect();
    final data = model.toJson();

    try {
      final idValue = data[idColumn];

      if (type == SaveType.insert) {
        data.remove(idColumn);

        final columns = data.keys.where((k) => k != idColumn).toList();
        final values = columns.map((k) => data[k]).toList();

        final placeholders = List.filled(columns.length, '?').join(', ');
        final sql =
            'INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)';

        final result = await conn.query(sql, values);

        final insertedId = result.insertId;

        if (insertedId != null) {
          return await findById(insertedId as ID);
        } else {
          return null;
        }
      } else if (type == SaveType.update) {
        if (idValue == -1) return null;

        // Obtem dados atuais
        final original = await findById(idValue as ID);
        if (original == null) return null;

        // Aqui pegamos APENAS os campos não-nulos do modelo que queremos atualizar
        final updateData = <String, dynamic>{};
        final originalMap = original.toJson();

        data.forEach((key, value) {
          if (key == idColumn) return; // ignora o ID
          // Se valor é null, mantemos o original (não atualiza)
          if (value == null) {
            updateData[key] = originalMap[key];
          } else {
            updateData[key] = value;
          }
        });

        // Prepara os dados para o UPDATE
        final columns = updateData.keys.toList();
        final values = columns.map((k) => updateData[k]).toList();
        values.add(idValue); // para o WHERE

        final setters = columns.map((k) => '$k = ?').join(', ');
        final sql = 'UPDATE $tableName SET $setters WHERE $idColumn = ?';

        await conn.query(sql, values);

        return await findById(idValue as ID);
      }

      return null;
    } catch (e, stacktrace) {
      throw Exception(
        "Error saving model: ${e.toString()}\nStackTrace: $stacktrace",
      );
    }
  }

  @override
  FutureOr<Page<T>> saveAll(
    List<BaseModel> list, {
    Pageable? pageable = const Pageable(),
    SaveType? type = SaveType.insert,
  }) async {
    await _verifySettings();

    if (list.isEmpty) {
      return Page<T>(
        content: [],
        size: pageable?.size ?? 0,
        number: pageable?.page ?? 0,
        totalElements: 0,
      );
    }

    final conn = await _connect();

    try {
      final firstMap = list.first.toJson();
      final columns = firstMap.keys.where((k) => k != idColumn).toList();

      if (type == SaveType.insert) {
        // Batch insert
        final placeholders = List.filled(columns.length, '?').join(', ');

        final valuesPlaceholders = List.filled(
          list.length,
          '($placeholders)',
        ).join(', ');

        final values = <dynamic>[];
        for (var model in list) {
          final map = model.toJson();
          for (var col in columns) {
            values.add(map[col]);
          }
        }

        final sql =
            'INSERT INTO $tableName (${columns.join(', ')}) VALUES $valuesPlaceholders';

        await conn.query(sql, values);
      } else if (type == SaveType.update) {
        // Batch update não é trivial no MySQL, geralmente faz-se um update individual (loop)
        for (var model in list) {
          final map = model.toJson();
          final idValue = map[idColumn];
          if (idValue == null) continue;

          final setters = columns.map((c) => '$c = ?').join(', ');
          final values = columns.map((c) => map[c]).toList();
          values.add(idValue);

          final sql = 'UPDATE $tableName SET $setters WHERE $idColumn = ?';
          await conn.query(sql, values);
        }
      }

      final savedModels = <T>[];
      for (var model in list) {
        final map = model.toJson();
        final idValue = map[idColumn];
        if (idValue != null) {
          final saved = await findById(idValue as ID);
          if (saved != null) savedModels.add(saved);
        }
      }

      return Page<T>(
        content: savedModels,
        size: savedModels.length,
        number: 0,
        totalElements: savedModels.length,
      );
    } catch (e, stacktrace) {
      throw Exception('Error in saveAll: $e\nStackTrace: $stacktrace');
    }
  }

  Future<Page<T>> customQuery({
    Pageable? pageable,
    required Future<List<T>> Function(MySqlConnection, String?) fn,
  }) async {
    final conn = await _connect();
    final content = await fn(conn, tableName);

    return Page<T>(
      content: content,
      number: pageable?.page ?? 0,
      size: pageable?.size ?? 20,
      totalElements: content.length,
    );
  }
}
