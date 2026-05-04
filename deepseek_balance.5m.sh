#!/bin/bash

# <swiftbar.title>DeepSeek Balance</swiftbar.title>
# <swiftbar.version>v1.0</swiftbar.version>
# <swiftbar.author>Antigravity</swiftbar.author>
# <swiftbar.desc>Checks DeepSeek API balance with toggle.</swiftbar.desc>
# <swiftbar.image>https://raw.githubusercontent.com/deepseek-ai/deepseek-ai.github.io/main/favicon.ico</swiftbar.image>

# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
# PEGA TU API KEY AQUÍ:
API_KEY="TU_API_KEY_AQUI"

# Archivo para guardar el estado (Activado/Desactivado)
STATE_FILE="$HOME/.deepseek_swiftbar_status"
# ==============================================================================

# Inicializar estado si no existe
if [ ! -f "$STATE_FILE" ]; then
    echo "ON" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

# Manejar el cambio de estado (Toggle)
if [ "$1" == "toggle" ]; then
    if [ "$CURRENT_STATE" == "ON" ]; then
        echo "OFF" > "$STATE_FILE"
    else
        echo "ON" > "$STATE_FILE"
    fi
    # Refrescar SwiftBar inmediatamente
    exit 0
fi

# Interfaz si está desactivado
if [ "$CURRENT_STATE" == "OFF" ]; then
    echo "DS: ⏸️ | symbol=pause.circle color=gray"
    echo "---"
    echo "Estado: Monitoreo Pausado | color=gray"
    echo "Activar Monitoreo | symbol=play.circle bash='$0' param1=toggle refresh=true"
    exit 0
fi

# Consultar Balance si está activado
RESPONSE=$(curl -s -L -X GET 'https://api.deepseek.com/user/balance' \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $API_KEY")

# Verificar si la respuesta contiene datos de balance
if [[ $RESPONSE == *"balance_infos"* ]]; then
    # Extraer valores usando grep/sed (para no depender de jq)
    BALANCE=$(echo "$RESPONSE" | grep -o '"total_balance":"[^"]*"' | head -1 | cut -d'"' -f4)
    CURRENCY=$(echo "$RESPONSE" | grep -o '"currency":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    # Título en la barra de menú con icono de billete
    echo "DS: $BALANCE $CURRENCY | symbol=banknote color=green"
    echo "---"
    echo "DeepSeek API Balance | size=14"
    
    # Detalles en el menú con iconos
    echo "$RESPONSE" | grep -o '"topped_up_balance":"[^"]*"' | sed 's/"topped_up_balance":"/Recarga: /;s/"//' | awk '{print $0 " | symbol=creditcard"}'
    echo "$RESPONSE" | grep -o '"granted_balance":"[^"]*"' | sed 's/"granted_balance":"/Bono: /;s/"//' | awk '{print $0 " | symbol=gift"}'
    
    echo "---"
    echo "Refrescar ahora | symbol=arrow.clockwise refresh=true"
    echo "Desactivar Monitoreo | symbol=pause.circle bash='$0' param1=toggle refresh=true"
else
    echo "DS: ⚠️ Error | symbol=exclamationmark.triangle color=red"
    echo "---"
    echo "Error al obtener balance"
    if [[ $API_KEY == "TU_API_KEY_AQUI" ]]; then
        echo "⚠️ Configura tu API Key en el archivo | color=orange"
    else
        echo "Respuesta: $RESPONSE"
    fi
    echo "---"
    echo "Reintentar | symbol=arrow.clockwise refresh=true"
    echo "Desactivar Monitoreo | symbol=pause.circle bash='$0' param1=toggle refresh=true"
fi
