
# ✅ **Gemini API Key Bulk Checker**

```bash
#!/bin/bash

INPUT_FILE="keys.txt"

# Warna-warna
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
RESET="\e[0m"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}File $INPUT_FILE tidak ditemukan!${RESET}"
    exit 1
fi

echo -e "${BLUE}=== Bulk Gemini API Key Checker ===${RESET}"

while IFS= read -r KEY; do
    KEY=$(echo "$KEY" | xargs)  # trim whitespace
    [[ -z "$KEY" ]] && continue # skip baris kosong

    echo -e "\n${YELLOW}Mengecek Key:${RESET} $KEY"

    RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$KEY" \
        -H "Content-Type: application/json" \
        -d '{"contents":[{"parts":[{"text":"test"}]}]}' )

    # Jika ada "candidates" berarti valid
    if echo "$RESPONSE" | grep -q '"candidates"'; then
        echo -e "${GREEN}VALID${RESET}"
        continue
    fi

    # Ambil pesan error
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message": *"[^"]*"' | sed 's/"message": "//;s/"$//')

    if [[ -z "$ERROR_MSG" ]]; then
        ERROR_MSG="Unknown error"
    fi

    echo -e "${RED}ERROR: $ERROR_MSG${RESET}"

done < "$INPUT_FILE"

echo -e "\n${BLUE}Selesai mengecek semua key.${RESET}"

```

---

# 📌 **Cara Pakai**

### 1️⃣ Simpan script

```
checker.sh
```

### 2️⃣ Beri izin eksekusi

```bash
chmod +x checker.sh
```

### 3️⃣ Siapkan daftar API dalam file keys.txt`

```
AIzaSyEXAMPLE1
AIzaSyEXAMPLE2
AIzaSyEXAMPLE3
```

### 4️⃣ Jalankan

```bash
./checker.sh`
```
**Penempatan checker.sh dan keys.txt harus dalam satu folder**
# ✨ Hasil Output

![Bulk Gemini API Key Checker](https://raw.githubusercontent.com/hendynoize/Gemini-API-Key-Bulk-Checker/refs/heads/main/image.png)

