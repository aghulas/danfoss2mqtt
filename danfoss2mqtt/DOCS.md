# Home Assistant Add-on: danfoss2mqtt

Standalone **Danfoss Ally Cloud → Mosquitto** bridge speaking the **Zigbee2MQTT** dialect (specified in [`ha-danfoss-ally/docs/companion-contract.md`](https://github.com/aghulas/ha-danfoss-ally/blob/main/docs/companion-contract.md)).

It runs alongside **Mosquitto** and **Zigbee2MQTT** (similar to `ebusd` for a boiler) and exposes radiator heads still connected to a Danfoss Ally gateway under `danfoss2mqtt/<friendly_name>`, in the same dialect as Zigbee2MQTT.

The **[Danfoss Ally Companion (v2)](https://github.com/aghulas/ha-danfoss-ally)** integration connects solely to Mosquitto and controls both `zigbee2mqtt` and `danfoss2mqtt` heads interchangeably.

## Configuration

| Option | Description |
| --- | --- |
| `base_topic` | MQTT topic prefix for the bridge (default: `danfoss2mqtt`). |
| `mqtt_host` / `mqtt_port` / `mqtt_username` / `mqtt_password` | Leave `mqtt_host` empty to auto-discover Home Assistant's **Mosquitto broker** add-on. |
| `mqtt_tls` | Enable TLS to the MQTT broker (default: `false`). |
| `username`, `password`, `country_code`, `region` | Danfoss Ally / Smart Life account credentials. |
| `sign_key`, `ch_key` | Danfoss Ally mobile app signature keys. |
| `device_id` | Optional — if left empty, a unique 44-character device ID is automatically generated and persisted in `/data/device_id`. |
| `poll_interval` | Cloud polling interval in seconds (15 to 600, default: 60). |
| `cloud_mqtt_listen` | Open a listen-only Tuya cloud-MQTT link so DP 199 pushes feed the read-state overlay in real time (default: `false`). |
| `head_settings_writes` | Write head settings (child lock, open-window detection, setpoint bounds) on channels proven on real hardware: the room's group publish for a head in a room (**every head of the room** takes it), a Tuya cloud-MQTT DP publish for an isolated head, confirmed by the gateway's echo or a cloud read. Turns the cloud-MQTT link into a publishing one. Default: `false`. |
| `head_settings_trial_head` | With `head_settings_writes`, confine the writes to this one head (Danfoss device id): the supervised first write. Empty = every head. Leave it set until a supervised write on that head has been read back. |
| `relay_links_writes` | Link or unlink a room to a boiler relay (`014G2400`) from Home Assistant (`room_link` on the relay's `/set`). ⚠ **This changes the boiler's heat demand**: a linked room asking for heat closes the relay. Each request is checked against a fresh read of the relay's rooms (the room must be one the relay lists; the relay's last linked room is never unlinked), sent as one cloud edit, then read back; `bridge/relays` is republished at once with what the cloud read back, never with the asked state. Default: `false`. |
| `relay_links_trial_relay` | With `relay_links_writes`, confine the writes to this one relay (Danfoss device id): the supervised first write. Empty = every relay. Leave it set until a supervised link and unlink on that relay have been read back. |
| `sensor_rooms_writes` | Put a room sensor (`014G2480`) in a room, or take it out of its room, from Home Assistant (`sensor_room` on the sensor's `/set`), as the Danfoss Ally app does. ⚠ **This changes what the room's heads regulate on**: in Danfoss Ally a sensor in a room is meant to become its heads' reference measurement. Each request is checked against fresh reads of the sensor's home (the room must be one of its rooms; a sensor already in another room is refused until it is taken out; a room that already holds another sensor is refused), sent as one cloud edit, then read back from the device -> room map; `bridge/sensor_rooms` is republished at once with what the cloud read back, never with the asked state. Requires pydanfoss-cloud with `sensor_rooms` (older versions ignore it). Default: `false`. |
| `sensor_rooms_trial_sensor` | With `sensor_rooms_writes`, confine the writes to this one sensor (Danfoss device id): the supervised first write. Empty = every sensor. Leave it set until a supervised write on that sensor has been read back. |

## MQTT Contract

- `danfoss2mqtt/bridge/state`: `"online"` / `"offline"` (configured via Last Will & Testament).
- `danfoss2mqtt/bridge/devices`: device inventory in Zigbee2MQTT format.
- `danfoss2mqtt/bridge/sensor_rooms` (retained): for each room sensor, its home, the Tuya room it is in (`null` = none, from the device -> room map) and the rooms of its home it can be put in: `{"<sensor id>": {"home_id": "…", "room_id": "…", "rooms": [{"room_id": "…", "name": "…"}]}}`.
- `danfoss2mqtt/<friendly_name>`: normalized JSON state (`local_temperature`, `occupied_heating_setpoint`, `pi_heating_demand`, `battery`, …).
- `danfoss2mqtt/<friendly_name>/availability`: `"online"` / `"offline"`.
- `danfoss2mqtt/<friendly_name>/set`: inbound commands (`occupied_heating_setpoint` routed to the proven cloud path `async_set_room_setpoint`; with `head_settings_writes`, `keypad_lockout`, `window_open_feature`, `max_heat_setpoint_limit` and, for an isolated head, `min_heat_setpoint_limit`; fields without a cloud-only path are logged as unsupported without being silently dropped). With `relay_links_writes`, a boiler relay takes `{"room_link": {"room_id": "<id from bridge/relays>", "linked": true}}`. With `sensor_rooms_writes`, a room sensor takes `{"sensor_room": {"room_id": "<id from bridge/sensor_rooms>"}}` (or `null` to take it out of its room). Each head's, relay's and sensor's `danfoss.set_keys` in `bridge/devices` lists the keys it accepts right now.
- `danfoss2mqtt/bridge/request/refresh`: forces an immediate refresh.
