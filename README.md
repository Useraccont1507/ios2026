# Zaryad

Пошук зарядних станцій для електромобілів (iOS).

**Призначення:** знаходити зарядні станції поблизу, дивитись деталі та зберігати перевірені станції в обране з оцінкою.
**Користувач:** власник електромобіля.
**Джерело даних:** Open Charge Map API (станції) і Firebase — Auth (акаунти) та Firestore (обране).

## Навчальні дисципліни

Код один для обох дисциплін; різниться лише те, що здається.

### iOS-розробка — практичні роботи

| Робота | Тег | Що зроблено |
|---|---|---|
| №1 | `practical-1` | Базові моделі (`ChargingStation`, `FavoriteStation`), сценарій «Обране», Swift-конструкції (див. нижче) |
| №2 | `practical-2` | MVVM, патерни, SOLID — [docs/Architecture.md](docs/Architecture.md) |
| №3 | `practical-3` | Координатори, карта MapKit, деталі станції, навігація — [docs/Navigation.md](docs/Navigation.md) |
| №4 | `practical-4` | Мережевий шар, Open Charge Map, Firebase (Auth + Firestore по HTTP), профіль, геолокація — [docs/Run.md](docs/Run.md) |

### ЖЦРПЗ — лабораторні роботи

| Робота | Де |
|---|---|
| №1 Специфікація вимог | Окремий документ |
| Архітектура ПЗ (Clean-lite, MVVM + Coordinator, UML) | Окремий документ |
| №4 Базова структура коду | Цей репозиторій: структура проєкту, ролі та запуск — нижче |

## Структура проєкту

```
Zaryad/
├── App/            — точка входу, AppCoordinator, TabBarCoordinator, конфіг Firebase
├── NavigationKit/  — базовий Coordinator, HostingController
├── Core/           — інфраструктура
│   ├── Network/    — Endpoint (builder), RequestManager, RawResponse, NetworkError
│   ├── Location/   — LocationService (CoreLocation)
│   ├── Observing/  — ObserverList (підписки з weak owner)
│   └── UI/Toast/   — тост помилок
├── Domain/         — сутності та протоколи репозиторіїв (без залежностей від фреймворків)
├── Data/           — реалізації репозиторіїв
│   ├── DTO/        — OCMStationDTO, FavoriteStationDTO
│   ├── Endpoint/   — OCMEndpoint, FirestoreEndpoint
│   ├── Mappers/    — StationMapper (DTO ↔ домен)
│   ├── Firebase/   — FirebaseService (Auth SDK), FirestoreCoder
│   └── Repository/ — StationsRepository, FirebaseAuthRepository, FirebaseFavoritesRepository
├── Feature/        — фічі: Coordinator + Assembly + Screens (View / VM / Models / Mappers)
│   ├── MapFeature/
│   ├── StationDetailsFeature/
│   ├── FavoritesStationFeature/
│   └── ProfileFeature/
└── UIResources/    — асети, LaunchScreen
docs/               — архітектура, навігація, запуск
firestore.rules     — правила безпеки Firestore
```

Залежності спрямовані до `Domain`: фічі працюють з протоколами репозиторіїв, конкретні реалізації (`Data`) передаються через координатори й Assembly.

## Ролі

Проєкт виконує одна людина — **Ілля Верезей**, full-stack: вимоги й архітектура, iOS-клієнт (UI, навігація, бізнес-логіка), інтеграція з Open Charge Map та Firebase, налаштування Firestore Rules, тестування на симуляторі.

Робота в Git: кожна лабораторна — окрема гілка `lab-N`, яка зливається в `dev`; підсумок позначається тегом `practical-N`.

## Запуск

Відкрити `Zaryad.xcodeproj` у Xcode, дочекатися завантаження пакета Firebase, запустити схему `Zaryad` на симуляторі (iOS 17+). Власний сервер не потрібен.

На карті надати доступ до локації — піде перший запит до Open Charge Map. Детально, з перевіркою станів: [docs/Run.md](docs/Run.md).

## Основні сценарії
- Пошук станцій на карті навколо користувача, картка та деталі станції, маршрут в Apple Maps.
- Акаунт (реєстрація / вхід Email + пароль).
- Додавання станції в обране з оцінкою (Карта → станція → «Детальніше» → «В обране»), видалення, перегляд у табі «Обране». Обране прив'язане до акаунта.

## Сутності

### `ChargingStation` — доменна модель станції
Дзеркалить POI-схему Open Charge Map. Ключові поля: `id: Int`, `addressInfo` (назва, адреса, координати, країна), `operatorInfo`, `statusType` (операційна/ні), `usageType`, `connections` (роз'єми: тип, потужність кВт, AC/DC, кількість), `numberOfPoints`, `dateLastVerified`.
📄 `Zaryad/Domain/Models/ChargingStation.swift`

### `FavoriteStation` — обрана станція
Відрізняється тим, що користувач додає **оцінку** та нотатку.
```
station: ChargingStation, rate: Int, note: String?
```
📄 `Zaryad/Domain/Models/FavoriteStation.swift`

### `FavoriteStationUIModel` — модель для UI
Готові для показу поля + власна ідентичність.
```
id: UUID          // унікальний id для List/ForEach
stationId: Int    // id станції з домену
name, address, power: PowerTier, powerKW: Int?, connectorsText, rate, note, needToDelete
```
📄 `.../FavoritesList/Models/FavoriteStationUIModel.swift` (+ `enum PowerTier` — градація потужності)

## Де в коді реалізовано Swift-конструкції

| Конструкція | Де |
|---|---|
| `struct` | `ChargingStation`, `FavoriteStation`, `FavoriteStationUIModel`, `FavoriteStationUIMapper` |
| `class` | `FavoriteListVM`, `FirebaseFavoritesRepository`, `RequestManager` |
| `protocol` | `PFavoritesRepository`, `PFavoriteListVM` |
| `enum` | `PowerTier`, `FavoriteListViewState`, `FavoritesStationEvent` |
| `var` / `let`, властивості, методи, `init` | `FavoriteListVM` (`@Published var state`, `let repo`, `init(repo:)`, `remove`, `loadStations`) |
| колекція + обробка (`map`/`filter`/`compactMap`/`forEach`) | `FavoriteStationUIMapper`, `FavoriteListVM` |
| словник (колекція) | `domainStationsById: [Int: FavoriteStation]` у `FavoriteListVM` |
| optional + безпечне розгортання (`guard let`, `?.`, `compactMap`) | `FavoriteStationUIMapper`, `FavoriteListVM` |
| умовна конструкція (`switch`/`guard`) | `FavoritesListView` (стани екрана), `FavoriteListVM` |

## Стек
Swift · UIKit + SwiftUI (UIHostingController) · MapKit · CoreLocation · MVVM + Coordinator · URLSession · Open Charge Map · Firebase Auth + Firestore (REST).
