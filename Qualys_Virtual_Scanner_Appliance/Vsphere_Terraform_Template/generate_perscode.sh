#!/bin/bash

set -euo pipefail

# --- Function for error exit ---
function error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# --- Validate inputs ---
vm_count="${1:-}"
friendly_name="${2:-}"
qualysguard_url="${3:-}"

# Check if required arguments are passed
[[ -z "$vm_count" || -z "$friendly_name" ]] && error_exit "vm_count and friendly_name are required."

# Validate vm_count is a number
[[ ! "$vm_count" =~ ^[0-9]+$ ]] && error_exit "vm_count must be a positive integer."

# Validate friendly_name: allow only alphanumerics, underscore, dash
[[ ! "$friendly_name" =~ ^[a-zA-Z0-9._-]+$ ]] && error_exit "friendly_name contains invalid characters."

# Validate qualysguard_url: allow hostname format only
[[ -n "$qualysguard_url" && ! "$qualysguard_url" =~ ^[a-zA-Z0-9.-/]+$ ]] && error_exit "qualysguard_url has invalid characters."

# Check required environment variables
for var in QUALYSGUARD_LOGIN QUALYSGUARD_PASSWORD; do
  [[ -z "${!var:-}" ]] && error_exit "$var is missing."
done

# Create the user_prefix with timestamp
user_prefix="${friendly_name}-$(date +%s)"

# Initialize perscode array
perscodes=()
userdata_file="userdata.json"

# Check if userdata.json exists and validate perscode count
if [[ -f "$userdata_file" ]]; then
    existing_count=$(jq length "$userdata_file")
    if (( existing_count >= vm_count )); then
        echo "Existing perscode count (${existing_count}) is greater than or equal to requested vm_count (${vm_count})."
        echo "No new perscodes will be generated."
        exit 0
    else
        echo "Existing perscode count is $existing_count. Will generate $((vm_count - existing_count)) more."
    fi
else
    existing_count=0
fi

# Loop to generate the remaining perscodes
for ((i = existing_count; i < vm_count; i++)); do
    sleep 3
    qvsa_name="${user_prefix}-${i}"

    response=$(curl --insecure -s \
        --request POST \
        --url "https://${qualysguard_url}/api/2.0/fo/appliance/" \
        --user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
        --header "X-Requested-With: Curl" \
        --data "action=create&echo_request=1&name=${qvsa_name}")

    perscode=$(echo "$response" | grep "ACTIVATION_CODE" | cut -d">" -f2 | cut -d"<" -f1)

    if [[ -n "$perscode" ]]; then
        perscodes+=("\"${perscode}\"")
    else
        echo "Unable to fetch Activation code for VM ${i}. Response:"
        echo "$response"
        exit 1
    fi
done

# Combine with existing JSON
if [[ -f "$userdata_file" ]]; then
    existing=$(jq -c . "$userdata_file" | sed 's/^\[//;s/\]$//')
    new_perscodes=$(IFS=, ; echo "${perscodes[*]}")
    combined=$(echo "[${existing},${new_perscodes}]" | sed 's/,,/,/g')
else
    combined=$(IFS=, ; echo "[${perscodes[*]}]")
fi

# Save updated perscodes to userdata.json
echo "$combined" | jq . > "$userdata_file"

echo "Userdata JSON file updated successfully!"
