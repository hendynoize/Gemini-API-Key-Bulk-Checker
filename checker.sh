#!/bin/bash

#############################################
# Gemini API Bulk Checker - Ultra Version
# Fitur:
# ✔ Output ke valid.txt & invalid.txt
# ✔ Multi-thread / parallel checking
# ✔ Auto remove duplicate API keys
# ✔ Progress bar
#############################################

echo "=== Gemini API Bulk Checker Ultra ==="
echo -n "Masukan nama file list API (misal: api.txt): "
read INPUT_FILE

# Cek file
if [ ! -f "$INPUT_FILE" ]; then
    echo "File tidak ditemukan!"
    exit 1
fi

# Bersihkan output
> valid.txt
> invalid.txt

# Membuat file clean tanpa duplicate
CLEAN_FILE="clean_api.txt"
sort -u "$INPUT_FILE" > "$CLEAN_FILE"

TOTAL=$(wc -l < "$CLEAN_FILE")
COUNT=0

# Tentukan jumlah parallel worker
THREADS=20

echo ""
echo "Total API key unik: $TOTAL"
echo "Menjalankan pengecekan dengan $THREADS thread, host: generativelanguage.googleapis.com"
echo ""

# Fungsi pengecekan API
check_key() {
    KEY="$1"

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $KEY" \
        "https://generativelanguage.googleapis.com/v1/models")

    if [ "$RESPONSE" -eq 200 ]; then
        echo "$KEY" >> valid.txt
    else
        echo "$KEY" >> invalid.txt
    fi
}

export -f check_key

# Jalankan parallel
cat "$CLEAN_FILE" | xargs -n1 -P"$THREADS" -I{} bash -c 'check_key "$@"' _ {}

# PROGRESS BAR SEDERHANA
while true; do
    VALID=$(wc -l < valid.txt)
    INVALID=$(wc -l < invalid.txt)
    DONE=$((VALID + INVALID))

    PERCENT=$((DONE * 100 / TOTAL))

    echo -ne "\rProgress: [$PERCENT%]  $DONE / $TOTAL  (Valid: $VALID | Invalid: $INVALID)"

    if [ "$DONE" -ge "$TOTAL" ]; then
        break
    fi

    sleep 0.3
done

echo ""
echo "--------------------------------"
echo "Selesai!"
echo "Valid   tersimpan di: valid.txt"
echo "Invalid tersimpan di: invalid.txt"
echo "--------------------------------"
