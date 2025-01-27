#!/bin/bash
vm_count=${1}
user_count=${2}
qualysguard_url=${3}
container_prefix=${4}
user_prefix=${5}
delete_container_scanners=${6}
 
for var in QUALYSGUARD_LOGIN QUALYSGUARD_PASSWORD;  do
  [ -z "${!var}" ] && echo "Error: $var is missing." && exit 1
done
 
qvsa_name="${user_prefix}-$((user_count+1))"
container_name="${container_prefix}-$((user_count+1))"
response=$(curl --insecure --location --request POST "${qualysguard_url}/api/2.0/fo/appliance/qcss/" \
--user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
--header "X-Requested-With: Curl" \
--data "action=list&output_mode=full&echo_request=1&name=${qvsa_name}")
scan_count=$(echo "$response" | grep "RUNNING_SCAN_COUNT" | cut -d">" -f2 | cut -d"<" -f1)
container_scanner_id=$(echo "$response" | grep "\<ID\>" | cut -d">" -f2 | cut -d"<" -f1)
echo "$scan_count"
echo "$container_scanner_id"
if [[ "$scan_count" -eq 0 && "$delete_container_scanners" == "true" ]]; then
    response=$(curl --insecure --location --request POST "${qualysguard_url}/api/2.0/fo/appliance/qcss/" \
    --user "${QUALYSGUARD_LOGIN}:${QUALYSGUARD_PASSWORD}" \
    --header "X-Requested-With: Curl" \
    --data "action=delete&echo_request=1&id=${container_scanner_id}")
    echo "Stopping Docker container: ${container_name}"
    docker container stop "$container_name"
       
elif [[ "$scan_count" -eq 0 && "$delete_container_scanners" == "false" ]]; then
    echo "Stopping Docker container: ${container_name}"
    docker container stop "$container_name"
 
else
    echo "Error: Scan is running on container ${container_name} and container scanner ${qvsa_name}"
    exit 1
fi