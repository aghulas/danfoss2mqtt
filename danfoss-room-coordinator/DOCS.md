# Danfoss Room Coordinator (Zigbee2MQTT)

Standalone room coordinator daemon for heads paired to a **Zigbee2MQTT** coordinator with no Danfoss gateway and no cloud.

Sibling of `danfoss2mqtt`, using the same dialect over Mosquitto.

## How it works

The coordinator subscribes to Zigbee2MQTT topics (`<source_prefix>/#`), manages room memberships, and publishes aggregated states and heat demand under its own base topic (`<base_topic>/#`):

- `<base_topic>/bridge/state` (`online` / `offline` with last-will)
- `<base_topic>/bridge/rooms` (retained room aggregates: temperature, setpoint, mode, window, battery, members, drift)
- `<base_topic>/bridge/heat_demand` (retained list of rooms actively calling for heat)
- `<base_topic>/bridge/request/<action>` / `bridge/response/<action>`:
  - `room/create`, `room/delete`, `room/rename`, `room/attach`, `room/detach`
  - `room/set-setpoint` (governed by the write safety gate `armed_rooms`)

## Stages & Write Safety

Per `docs/z2m-cloud-parity.md` §7:

- **Stage 1 (Read Only)**: Room definitions, state aggregation, drift reporting, heat demand. Zero write to heads.
- **Stage 2 (Setpoint Fan-Out)**: Fan-out of setpoints across all heads of a room with individual verification and retry.
  - **Closed by default**: Writes are strictly refused unless the room is explicitly listed in `armed_rooms`.
  - To arm a room for testing: set `armed_rooms: ["<room_id>"]` in the add-on configuration.

## Options

| Option | Default | Description |
|---|---|---|
| `source_prefix` | `zigbee2mqtt` | Base topic of the Zigbee2MQTT bridge |
| `base_topic` | `danfoss_rooms` | Base topic published by this coordinator |
| `store_path` | `/data/rooms.json` | Path where room definitions are persisted |
| `armed_rooms` | `[]` | List of room IDs allowed for setpoint fan-out (empty = read-only) |
| `setpoint_timeout_s` | `30.0` | Timeout in seconds waiting for each head's report |
| `setpoint_retries` | `2` | Number of retries before marking a head mismatch/failed |
