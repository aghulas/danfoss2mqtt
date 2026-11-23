# danfoss2mqtt

Standalone **Danfoss Ally Cloud → Mosquitto** bridge speaking the **Zigbee2MQTT** dialect, designed to run alongside **Zigbee2MQTT** and feed **[Danfoss Ally Companion (`ha-danfoss-ally` v2)](https://github.com/aghulas/ha-danfoss-ally)**.

```
Danfoss Ally Gateway (Cloud) ──► danfoss2mqtt ──┐
                                                ├──► Mosquitto ──► Danfoss Ally Companion (HA v2)
Zigbee Coordinator (PoE / USB) ──► zigbee2mqtt  ──┘
```

## Installation as a Home Assistant Add-on

1. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add repository URL: `https://github.com/aghulas/danfoss2mqtt`
3. Install **danfoss2mqtt**, enter your Danfoss Ally credentials (leave `mqtt_host` blank to auto-discover Mosquitto) and start the add-on.

See [`danfoss2mqtt/DOCS.md`](danfoss2mqtt/DOCS.md) for full options and MQTT contract details.

## Standalone Docker Deployment (outside Home Assistant OS)

```bash
cp .env.example .env   # fill in your credentials
docker compose up -d
```

## License

MIT — see [`LICENSE`](LICENSE).
