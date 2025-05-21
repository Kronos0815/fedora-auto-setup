#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Script:     deploy-configs.sh
# Zweck:      Liest manifest.csv ein und lädt jede .dconf-Datei
#             in den jeweiligen dconf-Pfad (mit Backup).
# Aufruf:     ./deploy-configs.sh /pfad/zu/configs
# Beispiel:   ./deploy-configs.sh ~/projects/gnome-configs/configs
##############################################################################

# 1) Argumentprüfung
if [ $# -ne 1 ]; then
  echo "Usage: $0 /pfad/zu/configs-directory"
  exit 1
fi

CONFIG_DIR="$1"
MANIFEST="$CONFIG_DIR/manifest.csv"

if [ ! -r "$MANIFEST" ]; then
  echo "Fehler: Manifest-Datei nicht gefunden: $MANIFEST"
  exit 1
fi

# 2) Backup-Verzeichnis anlegen
BACKUP_DIR="$CONFIG_DIR/backups-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Backups werden in $BACKUP_DIR gespeichert."

# 3) Manifest einlesen (Header überspringen)
tail -n +2 "$MANIFEST" | while IFS=, read -r ext_name dconf_path conf_file; do
  # Trim führende/trailing Leerzeichen
  ext_name="${ext_name## }"; ext_name="${ext_name%% }"
  dconf_path="${dconf_path## }"; dconf_path="${dconf_path%% }"
  conf_file="${conf_file## }"; conf_file="${conf_file%% }"

  CONFIG_FILE="$CONFIG_DIR/$conf_file"
  if [ ! -r "$CONFIG_FILE" ]; then
    echo "Warnung: Config-Datei für '$ext_name' nicht gefunden: $CONFIG_FILE"
    continue
  fi

  echo
  echo "=== Extension: $ext_name ==="
  echo "Pfad: $dconf_path"
  echo "Config: $conf_file"

  # 3a) Backup der aktuellen Einstellungen
  echo "- Backup..."
  dconf dump "$dconf_path" > "$BACKUP_DIR/${ext_name//\//_}.backup.dconf"

  # 3b) Einspielen der neuen Config
  echo "- Laden der neuen Config..."
  dconf load "$dconf_path" < "$CONFIG_FILE"

  # 3c) Verifikation
  echo "- Kontrolle (kurzer Auszug):"
  dconf dump "$dconf_path" | head -n 10
done

echo
echo "Alle Einträge aus manifest.csv wurden verarbeitet."
