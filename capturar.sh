#!/bin/zsh
# Saca capturas de cada pantalla en el simulador ya instalado (no crea ni borra simuladores).
# Uso: ./capturar.sh [pantalla ...]   (sin argumentos, todas)
set -e
SIM=${SIM:-762618FE-D6AB-4A56-BC66-248224D158DC}
APP=${APP:-build/dd/Build/Products/Debug-iphonesimulator/Bancamos.app}
cd "$(dirname "$0")"
mkdir -p capturas
xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl bootstatus "$SIM" -b >/dev/null
xcrun simctl install "$SIM" "$APP"
todas=(inicio inicio-vacio crear gente apoyos miembro agradecer posteos posteo posteo-nuevo niveles nivel-nuevo metas meta-nueva
       mi-pagina editar-pagina asi-te-ven qr mensajes conversacion estadisticas cobros notificaciones ajustes cuenta-mp fiscal privacidad plan ayuda mas
       explorar buscar categoria creador posteo-fan una-vez cada-mes revisa gracias bancas bancas-vacio membresia novedades perfil-fan recibos recibo)
if (( $# )); then lista=($@); else lista=($todas); fi
for p in $lista; do
  xcrun simctl status_bar "$SIM" override --time 9:41 --batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi >/dev/null
  xcrun simctl terminate "$SIM" ar.com.bancamos.app 2>/dev/null || true
  xcrun simctl launch "$SIM" ar.com.bancamos.app -pantalla "$p" >/dev/null
  sleep ${ESPERA:-3}
  xcrun simctl io "$SIM" screenshot "capturas/$p.png" >/dev/null 2>&1
  echo "capturas/$p.png"
done
# Onboarding: cada paso de cada lado (ONB=0 para saltearlo).
if [[ "${ONB:-1}" == 1 && $# -eq 0 ]]; then
  typeset -A cant=(creador 11 fan 8)
  for l in creador fan; do
    desde=0; [[ $l == fan ]] && desde=4
    for ((i=desde; i<${cant[$l]}; i++)); do
      xcrun simctl status_bar "$SIM" override --time 9:41 --batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi >/dev/null
      xcrun simctl terminate "$SIM" ar.com.bancamos.app 2>/dev/null || true
      xcrun simctl launch "$SIM" ar.com.bancamos.app -pantalla onboarding -paso $i -ladoOnb $l >/dev/null
      sleep ${ESPERA:-3}
      f=$(printf "capturas/onboarding-%s-%02d.png" $l $((i+1)))
      xcrun simctl io "$SIM" screenshot "$f" >/dev/null 2>&1
      echo "$f"
    done
  done
fi
