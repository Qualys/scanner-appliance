#!/bin/bash

set -e

# Check required environment variables
for var in QUALYSGUARD_LOGIN QUALYSGUARD_PASSWORD; do
  [ -z "${!var}" ] && echo "Error: $var is missing." && exit 1
done

# Validate input
config_file="$1"
[ ! -f "$config_file" ] && echo "Error: Configuration file '${config_file}' not found." && exit 1

# Extract top-level variables
declare -A top_vars
while IFS='=' read -r key value; do
    [[ "$key" =~ ^\s*#.*$ || "$key" =~ vm_configs || -z "$key" ]] && continue
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    top_vars["$key"]="$value"
done < "$config_file"

friendly_name="${top_vars[friendly_name]}"
vm_count="${top_vars[vm_count]}"
qualysguard_url="${top_vars[qualysguard_url]}"

if [ -z "$friendly_name" ] || [ -z "$vm_count" ] || [ -z "$qualysguard_url" ]; then
    echo "Missing friendly_name, vm_count, or qualysguard_url in tfvars"
    exit 1
fi

# Parse vm_configs
vm_config_blocks=()
inside_block=0
current_block=""

while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed=$(echo "$line" | xargs)

    [[ "$trimmed" =~ ^vm_configs ]] && continue
    [[ "$trimmed" == "[" || "$trimmed" == "]" ]] && continue

    if [[ "$trimmed" == "{" ]]; then
        inside_block=1
        current_block=""
        continue
    fi

    if [[ "$trimmed" == "}," || "$trimmed" == "}" || "$trimmed" == "}]" ]]; then
        inside_block=0
        vm_config_blocks+=("$current_block")
        continue
    fi

    if [[ $inside_block -eq 1 ]]; then
        current_block+="$trimmed"$'\n'
    fi
done < "$config_file"

# Check count
if [[ ${#vm_config_blocks[@]} -ne $vm_count ]]; then
    echo "Warning: Parsed ${#vm_config_blocks[@]} vm_configs, but vm_count is $vm_count"
fi

# Define required variables
required_vars=(
    HTTP_Proxy Enable_WAN_Interface LAN_Gateway LAN_Default_VLAN LAN_DNS_Servers
    WAN_IP WAN_Gateway WAN_DNS_Servers PREFER_USERDATA
    LAN_Netmask WAN_Netmask WINS_1 WINS_2 WINS_DOMAIN LAN_IP IPV6_ONLY
)

# Generate userdata files
user_prefix="${friendly_name}-$(date +%s)"
mkdir -p userdata

for ((i = 0; i < ${#vm_config_blocks[@]}; i++)); do
    sleep 2
    qvsa_name="${user_prefix}-${i}"
    USER_DATA="userdata/userdata_${i}.txt"

    perscode=$(curl --insecure -s \
        --request POST --url "https://${qualysguard_url}/api/2.0/fo/appliance/" \
        --user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
        --header "X-Requested-With: Curl" \
        --data "action=create&echo_request=1&name=${qvsa_name}" | \
        grep "ACTIVATION_CODE" | cut -d">" -f2 | cut -d"<" -f1)

    if [ $? -eq 0 ] && [ -n "${perscode}" ]; then
        echo "Personalization_Code=${perscode}" > "${USER_DATA}"
    else
        echo "Unable to fetch Activation code for VM $i"
        exit 1
    fi

    while IFS= read -r kv; do
        [[ "$kv" =~ = ]] || continue
        key=$(echo "$kv" | cut -d= -f1 | xargs)
        value=$(echo "$kv" | cut -d= -f2- | xargs)
        value="${value%\"}"
        value="${value#\"}"

        for needed in "${required_vars[@]}"; do
            if [[ "$key" == "$needed" ]]; then
                echo "${key}=\"${value}\"" >> "${USER_DATA}"
                break
            fi
        done
    done <<< "${vm_config_blocks[$i]}"
done

echo "Userdata file generation completed successfully!"
