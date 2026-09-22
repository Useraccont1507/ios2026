# Zaryad

Пошук зарядних станцій для електромобілів (iOS).

**Призначення:** знаходити зарядні станції поблизу, дивитись деталі та зберігати перевірені станції в обране.
**Користувач:** власник електромобіля.
**Джерело даних:** Open Charge Map API (поля сутностей мапляться на його POI-схему).

## Основні сценарії
- Пошук станцій за локацією / на карті.
- Перегляд деталей станції (роз'єми, потужність, оператор, статус).
- Реєстрація / вхід.
- Додавання станції в обране з оцінкою (зірочки).
- Керування списком обраного.

## Сутності

### `ChargingStation` — станція (для списку/карти)
| Поле | Тип | OCM |
|---|---|---|
| id | String | ID |
| name | String | AddressInfo.Title |
| latitude / longitude | Double | AddressInfo.Latitude / Longitude |
| address | String | AddressInfo.AddressLine1 + Town |
| maxPowerKW | Double? | max(Connections[].PowerKW) |
| connectorTypes | [ConnectorType] | Connections[].ConnectionType |
| status | StationStatus | StatusType.IsOperational |
| distanceKm | Double? | AddressInfo.Distance |

### `ChargingStationDetails` — розширена станція (для екрана деталей)
Усе з `ChargingStation` + повні дані:
| Поле | Тип | OCM |
|---|---|---|
| operatorName | String? | OperatorInfo.Title |
| usageType | String? | UsageType.Title |
| phone | String? | AddressInfo.ContactTelephone1 |
| connectors | [Connector] | Connections[] (повний список) |
| numberOfPoints | Int? | NumberOfPoints |
| comments | String? | GeneralComments |
| lastVerified | Date? | DateLastVerified |

### `FavoriteStation` — обрана станція
Відрізняється тим, що користувач може **ставити оцінку (зірочки)**.
| Поле | Тип |
|---|---|
| station | ChargingStation |
| rating | Int (1–5 зірочок) |
| note | String? |
| savedAt | Date |

### Допоміжні типи
- `Connector`: `type: ConnectorType`, `powerKW: Double?`, `currentType: String?` (AC/DC), `quantity: Int?`
- `enum ConnectorType`: `type2`, `ccs`, `chademo`, `tesla`, `other`
- `enum StationStatus`: `operational`, `nonOperational`, `unknown`

## Стек
Swift · UIKit + SwiftUI (UIHostingController) · MapKit · MVVM + Coordinator · URLSession · Open Charge Map · Firebase (акаунти/обране).
