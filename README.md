# 📦 PageableVaden

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) ![WIP](https://img.shields.io/badge/status-WIP-yellow) [![Pub Version](https://img.shields.io/pub/v/pageable_vaden.svg)](https://pub.dev/packages/pageable_vaden) ![Made with Dart](https://img.shields.io/badge/Made%20with-Dart-0175C2.svg?logo=dart)

**PageableVaden** é uma package para Dart desenvolvida para uso na framework **Vaden** – uma framework que facilita a criação de APIs REST do lado do servidor com Dart.

Inspirada na abordagem do `Pageable` do Spring Boot, esta package fornece uma implementação simples, extensível e integrada de paginação e ordenação de dados, com suporte a repositórios automáticos e integração fluida com controladores e serviços da Vaden.

---

## ⚙️ Inicialização do projeto

> [!WARNING]
> A package ainda não possui lançamentos no pub.dev pois ainda está numa fase inicial.

Para criar um projeto basta inserir a seguinte linha no `pubspec.yaml` do seu projeto dart gerado no gerador do [Vaden](https://start.vaden.dev) criado pela Flutterando.

```yaml
dependencies:
  pageable_vaden:
```

OU

```cli
dart pub add pageable_vaden
```

> [!WARNING]
> A package ainda não possui lançamentos no pub.dev pois ainda está numa fase inicial.

---

## ✨ Principais Funcionalidades

- ✅ Estrutura padrão para paginação de resultados (`page`, `size`, `sort`, etc.)
- ✅ Criação automática de repositórios integrados com Vaden
- ✅ Classe `Page<T>` para representar a resposta paginada com metadados
- ✅ Suporte a ordenação (`sortBy`, `direction`) e paginação configurável
- ✅ Fácil integração com controllers, services e repositories

---

## 📚 Como Usar (Passo-a-Passo)

A seguir, um exemplo resumido de como usar a PageableVaden com a framework Vaden:

### 1️⃣ Iniciar a App com Settings

```dart
Future<void> main(List<String> args) async {
  final vaden = VadenApp();

  Settings(
    database: "database",
    host: "host",
    user: "user",
    password: "root",
    port: 0000,
  );

  // Add every new Repository created with pageable_vaden package.
  vaden.injector.add(UserRepository.new);
  vaden.injector.add(UserMysqlRepository.new);

  await vaden.setup();
  final server = await vaden.run(args);
  print('Server listening on port ${server.port}');
}

```

### 2️⃣ Criar o Modelo

```dart
import 'package:pageable_vaden/base_model.dart';
import 'package:vaden/vaden.dart';

@Component(true)
class User extends BaseModel<int> {
  String? username;
  String? email;
  DateTime? createdAt;

  User({
    required super.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map map) => User(
    id: map['id'] as int? ?? -1,
    username: map['username'] as String?,
    email: map["email"] as String?,
    createdAt: map['created_at'] as DateTime?,
  );

  String? _formatForMySQL(DateTime? dt) {
    if (dt == null) return null;
    return dt.toLocal().toString().split('.').first; // YYYY-MM-DD HH:MM:SS
  }

  @override
  Map toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "created_at": _formatForMySQL(createdAt),
  };
}

```

### 3️⃣ Criar um DTO (opcional)

```dart
@DTO()
class UserDto {
  final int? id;
  final String username;
  final String email;
  final String? created_at;

  const UserDto({
    required this.username,
    required this.email,
    this.id,
    this.created_at = "1977-1-1",
  });
}

```

### 4️⃣ Criar o Mapper (opcional)

```dart
class UserMapper {
  static User fromDto({required UserDto dto}) {
    return User(
      id: dto.id ?? -1,
      username: dto.username,
      email: dto.email,
      createdAt: DateTime.tryParse(dto.created_at!) ?? DateTime.now(),
    );
  }
}

```

### 5️⃣ Criar o Repositório

```dart
@Repository()
class UserMysqlRepository extends MySqlRepository<User, int> {
  /// Override this in every repository to return the table name
  @override
  String get tableName => "users";

  /// Override this in every repository to return table id column
  @override
  String? get idColumn => "id";

  /// Override this in every repository to parse Map to the Model
  @override
  User Function(Map<String, dynamic> p1)? get fromMap => (e) => User.fromMap(e);

  UserMysqlRepository();
}


```

### 6️⃣ Criar o Service

```dart
@Component()
class UserService {
  final UserRepository _repository;
  final UserMysqlRepository _repositoryMysql;

  UserService(this._repository, this._repositoryMysql);

  FutureOr<Page<User>> getAllUsersMySql({Pageable? pageable}) async {
    return await _repositoryMysql.findAll(pageable: pageable);
  }

  FutureOr<User?> addUserMySql({required UserDto userDto}) async {
    User user = UserMapper.fromDto(dto: userDto);
    print(user.toJson());
    return await _repositoryMysql.save(user);
  }

  FutureOr<Page<User>> addAllUsersMySql({required List<User> list}) {
    return _repositoryMysql.saveAll(list);
  }

  FutureOr<User?> getUserByIdMySql({required int id}) {
    return _repositoryMysql.findById(id);
  }

  FutureOr<bool> removeUserMySql({required int id}) {
    return _repositoryMysql.remove(id);
  }

  Future<User?> updateUserMySql({required UserUpdateDto userDto}) async {
    User user = UserMapper.fromUpdateDto(dto: userDto);
    print(user.toJson());
    return await _repositoryMysql.save(user, type: SaveType.update);
  }
}

```

### 7️⃣ Criar o Controller

```dart
@Controller("/user")
@Api(tag: "User")
class UserController {
  UserService _service;

  UserController(this._service);

  @Get("/mysql")
  Future<Response> getUsersMySql(Request request) async {
    Pageable pageable = request.pageable;

    Page<User> page = await _service.getAllUsersMySql(pageable: pageable);

    return Response.ok(jsonEncode(page.toJson()));
  }

  @Post("/mysql")
  Future<Response> saveUserMySql(Request request, @Body() UserDto user) async {
    User? userAdded = await _service.addUserMySql(userDto: user);

    return Response.ok(jsonEncode(userAdded?.toJson()));
  }

  @Delete("/mysql/<id>")
  Future<Response> removeUserMySql(Request request, @Param("id") int id) async {
    bool userRemoved = await _service.removeUserMySql(id: id);

    return Response.ok(
      jsonEncode({
        "message":
            userRemoved
                ? "User $id removed."
                : "Couldn't find user with id $id",
      }),
    );
  }

  @Put("/mysql")
  Future<Response> updateUserMySql(
    Request request,
    @Body() UserUpdateDto userDto,
  ) async {
    User? user = await _service.updateUserMySql(userDto: userDto);
    return Response.ok(
      jsonEncode(
        user ?? {"message": "Couldn't find user with id ${userDto.id}"},
      ),
    );
  }
}

```

---

## 🧪 Estado Atual

A `PageableVaden` ainda está em desenvolvimento ativo. Algumas funcionalidades estão em fase de testes e serão melhoradas nas próximas versões.

---

## 🛣️ Roadmap

| Estado        | Funcionalidade                                                 |
| ------------- | -------------------------------------------------------------- |
| ✅            | Paginação e ordenação básicas (page, size, sort)               |
| ✅            | Repositórios automáticos (MySql, Local)                        |
| ✅            | Classe Page<T> com metadados (totalPages, etc.)                |
| ✅            | Suporte a múltiplas ordenações (sort=name,asc&sort=email,desc) |
| 🟡            | Filtros dinâmicos (ex: filter=name:joao)                       |
| 🟡            | Paginação Cursor-based                                         |
| 🟡            | Repositórios PostgreSQL e MongoDB                              |
| 🔜            | CLI para geração automática de repositórios e DTOs             |
| Mais em breve | Mais em breve                                                  |

## 📄 Licença

MIT License © 2025
