# Системні тести (Maestro)

| Флоу | Вимоги | Тег |
|---|---|---|
| `01_map_list_toggle.yaml` | FR-1, регресія бага перемикача | smoke, guest |
| `02_station_details.yaml` | FR-2, FR-3 | smoke, guest |
| `03_guest_profile.yaml` | FR-16, валідація форми | smoke, guest |
| `04_sign_in_favorite.yaml` | FR-12, FR-6…FR-9 | auth |

```bash
maestro test --include-tags guest tests/maestro
maestro test -e EMAIL=you@example.com -e PASSWORD=secret tests/maestro/04_sign_in_favorite.yaml
```
