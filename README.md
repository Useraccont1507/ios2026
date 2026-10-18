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
| №5 Інтеграція компонентів і залежності | Розділ [«ЖЦРПЗ — Лабораторна №5»](#жцрпз--лабораторна-5) |

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
ZaryadTests/        — unit-тести (Swift Testing)
docs/               — архітектура, навігація, запуск, скриншоти
firestore.rules     — правила безпеки Firestore
```

Залежності спрямовані до `Domain`: фічі працюють з протоколами репозиторіїв, конкретні реалізації (`Data`) передаються через координатори й Assembly.

## Ролі

Проєкт виконує одна людина — **Ілля Верезей**, full-stack: вимоги й архітектура, iOS-клієнт (UI, навігація, бізнес-логіка), інтеграція з Open Charge Map та Firebase, налаштування Firestore Rules, тестування на симуляторі.

Робота в Git: кожна лабораторна — окрема гілка `lab-N`, яка зливається в `dev`; підсумок позначається тегом `practical-N`.

## Запуск

Відкрити `Zaryad.xcodeproj` у Xcode, дочекатися завантаження пакета Firebase, запустити схему `Zaryad` на симуляторі (iOS 17+). Власний сервер не потрібен.

На карті надати доступ до локації — піде перший запит до Open Charge Map. Детально, з перевіркою станів: [docs/Run.md](docs/Run.md).

## ЖЦРПЗ — Лабораторна №5

Інтеграція компонентів і управління залежностями. Вимоги — зі специфікації (Лаб. №1).

### Метод інтеграції

Зовнішні сервіси, власного бекенду немає:

| Сервіс | Роль | Як інтегровано |
|---|---|---|
| Open Charge Map API | станції | REST (`OCMEndpoint` → `RequestManager`) |
| Firebase Authentication | акаунти | Firebase iOS SDK (`FirebaseService`) |
| Cloud Firestore (`zaryad-12303`, `europe-central2`) | обране | REST (`FirestoreEndpoint` → `RequestManager`), правила — `firestore.rules` |

Відхилення від стеку специфікації (Auth REST + Realtime Database): Auth через SDK — токен у Keychain (NFR-5); дані — Firestore REST, обмін залишився по HTTP.

### Залежності

| Залежність | Менеджер | Версія |
|---|---|---|
| firebase-ios-sdk (`FirebaseCore`, `FirebaseAuth`) | Swift Package Manager | `upToNextMajor` від 13.0.1, зафіксовано в `Package.resolved` |

`Package.resolved` у репозиторії (`Zaryad.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`) — однакові версії в усіх.

### Функціональні вимоги

| ID | Вимога | Статус | Де / як перевірити |
|---|---|---|---|
| FR-1 | Перелік станцій у радіусі | ✅ | Карта → «Список» (за відстанню) — `MapScreenView`, `MapVM` |
| FR-2 | Станції на карті (піни) | ✅ | Таб «Карта» — `MapScreenView` |
| FR-3 | Деталі станції | ✅ | Пін / рядок → «Детальніше» — `StationDetailsView` |
| FR-4 | Реєстрація (email + пароль) | ✅ | Профіль → «Створити акаунт» — `AuthVM`, `FirebaseAuthRepository` |
| FR-5 | Авторизація | ✅ | Профіль → «Увійти» |
| FR-6 | Додати в обране | ✅ | Деталі → «В обране» — `FirebaseFavoritesRepository` |
| FR-7 | Власна оцінка | ✅ | Попап оцінки 1–5 — `RatingPopup` |
| FR-8 | Перелік збережених | ✅ | Таб «Обране» — `FavoritesListView` |
| FR-9 | Видалити станцію з обраного | ✅ | Кошик у рядку / «В обраному» в деталях |
| FR-10 | Очистити все обране | ⏳ | Середній пріоритет — наступна ітерація (специфікація, розд. 7) |
| FR-11 | Фільтр за роз'ємом і потужністю | ⏳ | Середній пріоритет — наступна ітерація (специфікація, розд. 7) |
| FR-12 | Повторний пошук у видимій зоні | ✅ | Автопошук після зупинки камери + «Повторити» при помилці — `MapScreenView` |
| FR-13 | Маршрут у застосунку карт | ✅ | Деталі → «Маршрут» (Apple Maps) — `StationDetailsVM.openRoute` |
| FR-14 | Поточне місцезнаходження | ✅ | Запит доступу на старті, карта центрується — `LocationService` |
| FR-15 | Вихід з акаунта | ✅ | Профіль → «Вийти» |
| FR-16 | Обмеження для ролі «Гість» | ✅ | Гість → «В обране» → перехід у Профіль — `PProfileProvider` |

### Нефункціональні вимоги

| ID | Вимога | Статус | Як забезпечено |
|---|---|---|---|
| NFR-1 | Пошук ≤ 2 с | ✅ | Один запит після зупинки камери, попередній скасовується; `maxresults=100` |
| NFR-2 | Кешування в пам'яті | ⏳ | Наступна ітерація |
| NFR-3 | Типи помилок, повтор | ✅ | `NetworkError` (transport / http / decoding), тост + «Повторити» |
| NFR-4 | Порожні стани | ✅ | «Поруч немає станцій», «Немає обраного» |
| NFR-5 | Безпека даних | ✅ | `firestore.rules`: доступ лише до власних `users/{uid}`; токен у Keychain (Firebase Auth SDK) |
| NFR-6 | Адаптивність, темна тема | ✅ частково | Темна тема і великий шрифт — скриншоти нижче (iPhone 17 Pro Max); малий екран окремо не перевірявся |
| NFR-7 | iOS 17.0+ | ✅ | `IPHONEOS_DEPLOYMENT_TARGET = 17.0` |
| NFR-8 | Квота зовнішнього API | ✅ частково | Радіус 1–50 км, `maxresults=100`, скасування зайвих запитів; кешу немає (NFR-2) |
| NFR-9 | Стандартні компоненти, Dynamic Type | ✅ | SwiftUI / UIKit, `@ScaledMetric` для бейджів |

### Тестування

**Компоненти окремо** — unit-тести (Swift Testing), таргет `ZaryadTests`, 12 тестів:

| Сюїта | Що перевіряє |
|---|---|
| `MapVMTests` | старт з локації / fallback Київ (FR-14), список за відстанню (FR-1), empty (NFR-4), error і повтор (NFR-3), пошук у зоні (FR-12), відкриття деталей (FR-3) |
| `FirestoreCoderTests` | кодування в типи Firestore, round-trip документа, порожня колекція |

Запуск: Xcode → `Cmd+U`, або

```bash
xcodebuild test -project Zaryad.xcodeproj -scheme Zaryad -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:ZaryadTests
```

**Цілісність** — сценарій на симуляторі:

1. Старт → дозвіл геолокації → піни навколо користувача (OCM).
2. «Список» → тап по станції → деталі.
3. Гість → «В обране» → перехід у Профіль → реєстрація (Firebase Auth).
4. Деталі → «В обране» → оцінка → станція в табі «Обране» (Firestore).
5. Вихід → «Обране» порожнє; повторний вхід → обране повертається.

### Скриншоти (iPhone 17 Pro Max, iOS 26.5)

| Карта, темна тема | Список, темна тема | Список, великий шрифт | Деталі, великий шрифт |
|---|---|---|---|
| ![](docs/lab5/01-map-dark.png) | ![](docs/lab5/02-list-dark.png) | ![](docs/lab5/03-list-large-text.png) | ![](docs/lab5/04-details-large-text.png) |

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
