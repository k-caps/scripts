#!/bin/bash
if [ -z "$1" ]; then
    echo "You must supply a machine name, such as 'homelab-k8s-worker-02'"
    exit 1
fi

WORKDIR=/home/kcaps/maas

echo "Logging into MAAS API..."
maas login admin http://127.0.0.1:5240/MAAS/api/2.0 Lh8KUcfGZpgMmmzVd4:5J9skJbb2TuD3VKjxn:nRx6aPYaHGdfiduywmk7eRNn4YG4jZ

# Get machine ID by name
mids() {
    maas admin machines read | jq -r '(["HOSTNAME","SYSID"] | (., map(length*"-"))),(.[] | [.hostname, .system_id]) | @tsv' | column -t
}
getmid() {
    mids | grep $1 | awk '{print $2}'
}
machine_id=$(getmid $1)
check_deploy_status() {
    maas admin machine read $machine_id | jq -r .status_name
}


echo "Machine ID for $1 is: $machine_id"

echo "Disabling Swap for $1"
maas admin machine update $machine_id swap_size=0 > /dev/null

# If there is eth0, rename it to vnic1 - to deploy we need vnic1 vnic2 and bond0 linking them
echo "Reading interface names for machine $machine_id..."
interface_names=$(maas admin interfaces read "$machine_id" | jq -r '.[].name')
interface_count=$(echo "$interface_names" | wc -l)

if [[ "$interface_count" -eq 1 && "$interface_names" == "eth0" ]]; then
    echo "Renaming default interface from eth0 to vnic1"
    maas admin interface update $machine_id eth0 name=vnic1 > /dev/null

    echo "Getting vnic2 MAC from mapping file ($WORKDIR/machine_mac_addresses.txt).."
    vnic2_mac_address=$(grep $1 machine_mac_addresses.txt | awk '{print $5}')
    echo "vnic2 MAC address: $vnic2_mac_address"

    echo "Creating second interface:"
    maas admin interfaces create-physical $machine_id name=vnic2 mac_address=$vnic2_mac_address vlan=2 > /dev/null
    maas admin interface link-subnet $machine_id vnic2 mode=LINK_UP subnet=2 > /dev/null
    maas admin interface update $machine_id vnic2 link_connected=True > /dev/null
fi

# Start bond creation procedure
if [[ "$interface_count" -eq 2 ]]; then
    echo "Getting existing IP addresses from vnic1"
    read -r ip_address gateway_ip < <(maas admin interfaces read $machine_id | jq -r '.[].links[] | "\(.ip_address) \(.subnet.gateway_ip)"')
    echo "IP address: $ip_address"
    echo "Default gateway IP address: $gateway_ip"

    echo "Getting interface IDs for Bond creation..."
    parent_interface_ids=$(maas admin interfaces read $machine_id | jq -r '[.[] | "parents=" + (.id | tostring)] | join(" ")')

    echo "Creating 'bond0' Bond interface..."
    maas admin interfaces create-bond $machine_id name=bond0 vlan=2 $parent_interface_ids bond_mode=balance-alb bond_miimon=0 bond_xmit_hash_policy=layer3+4 > /dev/null

    echo "Attaching subnet and IP settings to bond0..."
    maas admin interface link-subnet $machine_id bond0 subnet=2 mode=STATIC ip_address=$ip_address default_gateway=$gateway_ip > /dev/null
    maas admin interface update $machine_id bond0 link_connected=True > /dev/null

    echo "Waiting 10s to ensure bond creation before beginning deploy..."
    sleep 10
fi

echo "Interfaces and bond set up, beginning deploy..."

maas admin machine deploy $machine_id user_data="$(base64 -w0 $WORKDIR/cloud-init-baseline.yml)" > /dev/null
echo "Started Deploying machine $1 at $(date)."
echo "Follow progress at:"
echo "http://192.168.1.45:5240/MAAS/r/machine/$machine_id/summary"
