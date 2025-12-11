#!/bin/bash

API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"
INPUT_FILE="keys.txt"
LOG="result.log"

echo "=== Bulk Gemini Key Checker ==="
echo "Start : $(date)" > "$LOG"

# Function request
check_key() {
    local KEY="$1"
    local ATTEMPT=1
    local MAX_ATTEMPT=5

    while true; do
        RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/res_body \
            -X POST "$API_URL?key=$KEY" \
            -H "Content-Type: application/json" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) SafeCheck/1.0" \
            -d '{"contents":[{"parts":[{"text":"hi"}]}]}')

        HTTP_CODE=$RESPONSE

        # Avoid spammy logs
        case "$HTTP_CODE" in
            200)
                echo "[VALID] $KEY" | tee -a "$LOG"
                return
                ;;
            400|401|403)
                echo "[INVALID] $KEY" | tee -a "$LOG"
                return
                ;;
            429)
                echo "[RATE LIMIT] $KEY — cooldown $((ATTEMPT*2))s" | tee -a "$LOG"
                sleep $((ATTEMPT*2))
                ;;
            000)
                echo "[TIMEOUT] $KEY — retrying..." | tee -a "$LOG"
                sleep $((ATTEMPT*2))
                ;;
            *)
                echo "[UNKNOWN: $HTTP_CODE] $KEY" | tee -a "$LOG"
                return
                ;;
        esac

        ATTEMPT=$((ATTEMPT+1))
        if (( ATTEMPT > MAX_ATTEMPT )); then
            echo "[FAILED AFTER RETRY] $KEY" | tee -a "$LOG"
            return
        fi
    done
}

# Loop keys
while IFS= read -r KEY; do
    [[ -z "$KEY" ]] && continue

    echo "Checking: $KEY"
    check_key "$KEY"

    # Random delay 1–4 detik (sangat efektif anti-spam)
    sleep $((1 + RANDOM % 4))

done < "$INPUT_FILE"

echo "Done : $(date)" >> "$LOG"
