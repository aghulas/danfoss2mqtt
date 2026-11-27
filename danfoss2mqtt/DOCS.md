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

## MQTT Contract

- `danfoss2mqtt/bridge/state`: `"online"` / `"offline"` (configured via Last Will & Testament).
- `danfoss2mqtt/bridge/devices`: device inventory in Zigbee2MQTT format.
- `danfoss2mqtt/<friendly_name>`: normalized JSON state (`local_temperature`, `occupied_heating_setpoint`, `pi_heating_demand`, `battery`, …).
- `danfoss2mqtt/<friendly_name>/availability`: `"online"` / `"offline"`.
- `danfoss2mqtt/<friendly_name>/set`: inbound commands (`occupied_heating_setpoint` routed to the proven cloud path `async_set_room_setpoint`; with `head_settings_writes`, `keypad_lockout`, `window_open_feature`, `max_heat_setpoint_limit` and, for an isolated head, `min_heat_setpoint_limit`; fields without a cloud-only path are logged as unsupported without being silently dropped). Each head's `danfoss.set_keys` in `bridge/devices` lists the keys it accepts right now.
- `danfoss2mqtt/bridge/request/refresh`: forces an immediate refresh.
