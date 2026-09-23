# Zaryad

Пошук зарядних станцій для електромобілів (iOS).

**Призначення:** знаходити зарядні станції поблизу, дивитись деталі та зберігати перевірені станції в обране з оцінкою.
**Користувач:** власник електромобіля.
**Джерело даних:** Open Charge Map API (поля моделей мапляться на його POI-схему). На цьому етапі дані беруться з мок-репозиторію.

## Основні сценарії
- Завантаження та перегляд списку обраних станцій.
- Додавання станції в обране (наразі — демо-кнопка «+», згодом із карти).
- Видалення станції з обраного.
- (далі) пошук на карті, деталі станції, фільтри.

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
| `class` | `FavoriteListVM`, `MockFavoritesRepository`, `FavoritesEventSubscription` |
| `protocol` | `PFavoritesRepository`, `PFavoriteListVM` |
| `enum` | `PowerTier`, `FavoriteListViewState`, `FavoritesStationEvent` |
| `var` / `let`, властивості, методи, `init` | `FavoriteListVM` (`@Published var state`, `let repo`, `init(repo:)`, `remove`, `loadStations`) |
| колекція + обробка (`map`/`filter`/`compactMap`/`forEach`) | `FavoriteStationUIMapper`, `FavoriteListVM` |
| словник (колекція) | `domainStationsById: [Int: FavoriteStation]` у `FavoriteListVM` |
| optional + безпечне розгортання (`guard let`, `?.`, `compactMap`) | `FavoriteStationUIMapper`, `FavoriteListVM` |
| умовна конструкція (`switch`/`guard`) | `FavoritesListView` (стани екрана), `FavoriteListVM` |

## Як запустити / перевірити сценарій

Проєкт відкривається в Xcode (`Zaryad.xcodeproj`), збирається та запускається на симуляторі (iOS 17+).

Стартовий екран налаштовано в `Zaryad/App/SceneDelegate.swift` (тимчасово): створюється `MockFavoritesRepository → FavoriteListVM → FavoritesListView`.

Завершений сценарій предметної області — **створення → колекція → зміна стану**:
1. При запуску завантажується **колекція** обраних станцій (мок).
2. **«+»** у навбарі → alert → **«Додати»** → нова станція **створюється й додається в колекцію** (`createFavorite`) і зʼявляється у списку.
3. Кнопка **кошика** в рядку → станція **видаляється** з колекції (зміна стану).

> Кнопка «+» та root-налаштування у `SceneDelegate` позначені `// TODO/TEMP` — це заглушки для демонстрації сценарію (справжнє додавання буде з екрана карти).

## Стек
Swift · UIKit + SwiftUI (UIHostingController) · MapKit · MVVM + Coordinator · URLSession · Open Charge Map · Firebase (акаунти/обране).
