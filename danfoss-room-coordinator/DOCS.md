# Danfoss Room Coordinator (Zigbee2MQTT)

Standalone room coordinator daemon for heads paired to a **Zigbee2MQTT** coordinator with no Danfoss gateway and no cloud.

Sibling of `danfoss2mqtt`, using the same dialect over Mosquitto.

## How it works

The coordinator subscribes to Zigbee2MQTT topics (`<source_prefix>/#`), manages room & holiday definitions, and publishes aggregated states and heat demand under its own base topic (`<base_topic>/#`):

- `<base_topic>/bridge/state` (`online` / `offline` with last-will)
- `<base_topic>/bridge/rooms` (retained room aggregates: temperature, setpoint, mode, heating, members, desired, drift, reconcile_blocked)
- `<base_topic>/bridge/holidays` (retained coordinator-managed holiday entries)
- `<base_topic>/bridge/heat_demand` (retained list of rooms actively calling for heat)
- `<base_topic>/bridge/request/<action>` / `bridge/response/<action>`:
  - Store-only (Stage 1): `refresh`, `room/create`, `room/delete`, `room/rename`, `room/set-members`, `room/set-sensor`, `room/get-schedule` (`get_schedule`), `holiday/list`
  - Write actions (governed by `armed_rooms`): `room/set-setpoint`, `room/set-schedule` (`set_schedule`), `room/set-comfort-setback`, `room/set-mode`, `room/restore-schedule` (`restore_schedule`), `room/set-settings`, `holiday/set`, `holiday/cancel`

## Stages & Write Safety

Per `docs/z2m-cloud-parity.md` §7, **all write stages ship closed by default**:

- **Stage 1 (Read Only)**: Room definitions, state aggregation, drift reporting, heat demand. Zero write to heads.
- **Stage 2 (Setpoint Fan-Out)**: Fan-out of setpoints across all heads of a room with individual verification and retry (`armed_rooms`).
- **Stage 3 (Room Sensor Feed)**: Event-driven `external_measured_room_sensor` feed supporting both `radiator_covered` modes + 30-min silence `-8000` (`feed_external_sensor: false` by default).
- **Stage 4 (Weekly Schedule & Modes)**: 7-day ZCL schedule fan-out with R1 validation, R3 comfort/setback rewrite, and `schedule`/`manual`/`pause` modes (`mode_change_keeps_schedule: false` by default).
- **Stage 5 (Settings & Reconciliation)**: Room-wide settings fan-out (`room/set-settings`) and hourly drift reconciliation capped at 3 attempts (`reconcile_drift: false` by default).
- **Stage 6 (Load Balancing)**: Multi-head `load_room_mean` coalesced into one `/set` with the sensor feed, `-8000` on clean stop (`feed_load_mean: false` by default).
- **Stage 7 (Holidays & Open Window)**: Holiday edge calendar (`enable_holidays: false` by default) and cross-room `window_open_external` propagation (`propagate_window_open: false` by default).

To arm a room for testing, add its `room_id` to `armed_rooms: ["<room_id>"]` and enable only the stage option(s) under test.

## Options

| Option | Default | Description |
|---|---|---|
| `source_prefix` | `zigbee2mqtt` | Base topic of the Zigbee2MQTT bridge |
| `base_topic` | `danfoss_rooms` | Base topic published by this coordinator |
| `store_path` | `/data/rooms.json` | Path where room and holiday definitions are persisted |
| `armed_rooms` | `[]` | List of room IDs allowed for head writes (empty = read-only) |
| `setpoint_timeout_s` | `30.0` | Timeout in seconds waiting for each head's report |
| `setpoint_retries` | `2` | Number of retries before marking a head mismatch/failed |
| `feed_external_sensor` | `false` | Stage 3: event-driven `014G2480` -> `external_measured_room_sensor` feed |
| `mode_change_keeps_schedule` | `false` | Stage 4: skip rewriting 7-day schedule when returning from `setpoint` to `schedule` |
| `reconcile_drift` | `false` | Stage 5: hourly drift reconciliation (max 3 consecutive attempts) |
| `feed_load_mean` | `false` | Stage 6: multi-head `load_room_mean` balancing (`load_balancing_enable` required) |
| `enable_holidays` | `false` | Stage 7: apply/exit holiday setpoints at calendar edges and on startup |
| `propagate_window_open` | `false` | Stage 7: propagate internal open window via `window_open_external` |
| `window_open_max_duration_s` | `1800.0` | Stage 7: max duration (s) before clearing `window_open_external` |
| `tick_interval_s` | `15.0` | Periodic evaluation interval (s) |
| `max_writes_per_tick` | `0` | Optional per-tick write cap (`0` = unlimited) |
