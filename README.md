# danfoss2mqtt

Standalone bridges and coordinators for Danfoss Ally heads on Mosquitto, speaking the **Zigbee2MQTT** dialect, designed to feed **[Danfoss Ally Companion (`ha-danfoss-ally` v2)](https://github.com/aghulas/ha-danfoss-ally)**.

```
Danfoss Ally Gateway (Cloud) ──► danfoss2mqtt ─────────┐
                                                       ├──► Mosquitto ──► Danfoss Ally Companion (HA v2)
Zigbee Coordinator (PoE/USB) ──► zigbee2mqtt ──┐       │
                                               ▼       │
                       danfoss-room-coordinator ───────┘
```

## Add-ons in this repository

1. **`danfoss2mqtt`**: Standalone Danfoss Ally Cloud → Mosquitto bridge. Translates gateway rooms and heads into Zigbee2MQTT-style discovery and state topics.
2. **`danfoss-room-coordinator`**: Standalone room coordinator daemon for heads paired to a Zigbee2MQTT coordinator with no gateway. Manages room definitions, aggregate states, heat demand, and safe setpoint fan-out.

## Installation in Home Assistant

1. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add repository URL: `https://github.com/aghulas/danfoss2mqtt`
3. Install **danfoss2mqtt** (for cloud gateway heads) and/or **danfoss-room-coordinator** (for Zigbee2MQTT heads).

See [`danfoss2mqtt/DOCS.md`](danfoss2mqtt/DOCS.md) and [`danfoss-room-coordinator/DOCS.md`](danfoss-room-coordinator/DOCS.md) for full configuration options.

## Standalone Docker Deployment (outside Home Assistant OS)

```bash
cp .env.example .env   # fill in your credentials
docker compose up -d
```

## License

MIT — see [`LICENSE`](LICENSE).
