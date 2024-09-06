#!/bin/bash

# Check if required environment variables are set
for var in QUALYSGUARD_LOGIN QUALYSGUARD_PASSWORD ARM_SUBSCRIPTION_ID ARM_SUBSCRIPTION_ID ARM_CLIENT_ID ARM_CLIENT_SECRET;  do
  [ -z "${!var}" ] && echo "Error: $var is missing." && exit 1
done

# File with the configuration
config_file=${1}

if [ ! -f "${config_file}" ]; then
  echo "Error: Configuration file '${config_file}' not found."
  exit 1
fi

# Read the file and export variables
while IFS='=' read -r key value; do
    # Skip lines that are comments or empty
    if [[ "${key}" =~ ^\s*# ]] || [[ -z "${key}" ]]; then
        continue
    fi

    # Remove leading/trailing spaces from key and value
    key=$(echo "${key}" | sed "s/ //g")
    value=$(echo "${value}" | sed "s/ //g")
    
    # Replace spaces around '=' and handle the value in quotes
    if [[ "${value}" == \"*\" ]]; then    
        value=$(echo "${value}" | sed -e 's/.*"\([^"]*\)".*/\1/')
    fi

    # Remove inline comments
    value=$(echo "${value}" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
    
    # Skip if the value is empty after processing
    if [[ -z "${value}" ]]; then
        continue
    fi
    # Export variable
    export "${key}=${value}"
done < "${config_file}"

user_prefix="${friendly_name}-$(date +%s)" # Creating user_prefix with same timestamp

# Get the count of existing userdata files
mkdir -p userdata  # This would be no-op if userdata dir is already present
existing_count=$(ls userdata/userdata_*.txt 2>/dev/null | wc -l)

# Check if VM count matches the existing userdata files count
if [ "${existing_count}" -eq "${vm_count}" ]; then
    echo "VM count matches the number of userdata files. Skipping further execution."
    exit 0
fi

# Loop starting from the next available index
for ((i = existing_count; i < vm_count; i++)); do
    sleep 3
    qvsa_name="${user_prefix}-${i}"
    USER_DATA="userdata/userdata_${i}.txt"

    perscode=$(curl --insecure -s \
        --request POST --url "https://${qualysguard_url}/api/2.0/fo/appliance/" \
        --user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
     --header "X-Requested-With: Curl" \
     --data "action=create&echo_request=1&name=${qvsa_name}" | \
        grep "ACTIVATION_CODE" | cut -d">" -f2 | cut -d"<" -f1)

    if [ $? -eq 0 ] && [ -n "${perscode}" ]; then
       echo "PERSCODE=${perscode}" >> ${USER_DATA}
    else
        echo "Unable to fetch Activation code"
        exit 1
    fi

    if [ -n "${proxy_url}" ]; then
            echo "PROXY_URL=${proxy_url}" >> ${USER_DATA}
    fi

done
echo "Userdata file generation completed successfully!"
