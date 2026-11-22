# danfoss2mqtt

Pont autonome **Danfoss Ally Cloud → Mosquitto** parlant le dialecte **Zigbee2MQTT**, conçu pour tourner à côté de **Zigbee2MQTT** et alimenter **[Danfoss Ally Companion (`ha-danfoss-ally` v2)](https://github.com/aghulas/ha-danfoss-ally)**.

```
Passerelle Danfoss Ally (Cloud) ──► danfoss2mqtt ──┐
                                                   ├──► Mosquitto ──► Danfoss Ally Companion (HA v2)
Coordinateur Zigbee (PoE / USB) ──► zigbee2mqtt  ──┘
```

## Installation comme Add-on Home Assistant

1. Dans Home Assistant : **Paramètres → Modules complémentaires → Boutique des modules complémentaires → ⋮ → Dépôts**.
2. Ajouter l'URL : `https://github.com/aghulas/danfoss2mqtt`
3. Installer **danfoss2mqtt**, renseigner vos identifiants Danfoss Ally (laisser `mqtt_host` vide pour auto-découvrir Mosquitto) et démarrer.

Voir [`danfoss2mqtt/DOCS.md`](danfoss2mqtt/DOCS.md) pour le détail des options et du contrat MQTT.

## Déploiement Docker autonome (hors Home Assistant OS)

```bash
cp .env.example .env   # renseigner vos identifiants
docker compose up -d
```

## Licence

MIT — voir [`LICENSE`](LICENSE).
