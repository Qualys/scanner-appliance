#!/bin/bash
userdata_file="./userdata.json"
vm_count=${1}
user_count=${2}
qualysguard_url=${3}
user_prefix=${4}

for var in QUALYSGUARD_LOGIN QUALYSGUARD_PASSWORD;  do
  [ -z "${!var}" ] && echo "Error: $var is missing." && exit 1
done

existing_count=$(jq '.activation_ids | length' "$userdata_file")

# Check if VM count matches the existing userdata files count
if [ "${existing_count}" -ge "${vm_count}" ]; then
    echo "existing_count of activation code in userdata.json is greater than or equal to vm_count. Skipping further execution."
    exit 1
fi
    qvsa_name="${user_prefix}-$((user_count+1))"
    response=$(curl --insecure --location --request POST "${qualysguard_url}/api/2.0/fo/appliance/qcss/" \
    --user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
    --header "X-Requested-With: Curl" \
    --data "action=create&echo_request=1&name=${qvsa_name}")

    perscode=$(echo "$response" | grep "ACTIVATION_CODE" | cut -d">" -f2 | cut -d"<" -f1)

    if [ $? -eq 0 ] && [ -n "${perscode}" ]; then
        echo "Adding activation code to userdata.json"
        jq --arg code "$perscode" '.activation_ids += [$code]' "$userdata_file" > tmp.$$.json && mv tmp.$$.json "$userdata_file"

    else
        echo "Unable to fetch Activation code for VM ${i}"
        error=$(echo "$response" | grep "TEXT" | cut -d">" -f2 | cut -d"<" -f1)
        echo "$error"
        exit 1
    fi
