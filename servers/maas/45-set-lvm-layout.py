#!/usr/bin/env python3
#
# 45-set-lvm-layout - Commissioning script to set custom LVM layout
#
# --- Start MAAS 1.0 script metadata ---
# name: 45-set-lvm-layout
# title: Set LVM layout
# description: Set LVM layout 
# script_type: commissioning
# timeout: 60
# --- End MAAS 1.0 script metadata ---

import json
import os
import sys

def read_json_file(path):
    try:
        with open(path) as fd:
            return json.load(fd)
    except OSError as e:
        sys.exit(f"Failed to read {path}: {e}")
    except json.JSONDecodeError as e:
        sys.exit(f"Failed to parse {path}: {e}")

# Read the hardware data from MAAS_RESOURCES_FILE. You can parse the info in it, but this script only sets it so that we can write our static data into it.
hardware = read_json_file(os.environ["MAAS_RESOURCES_FILE"])

# Create hardcoded JSON structure for storage layout on sda 
#    - Partition #1 => 536M FAT32 for EFI
#    - Partition #2 => 479G for LVM

storage_layout = '''{
    "layout": {
        "sda": {
            "type": "disk",
            "ptable": "gpt",
            "boot": true,
            "partitions": [
                { "name": "sda1", "fs": "fat32", "size": "536M", "bootable": true },
                { "name": "sda2", "size": "479G" }
            ]
        },
        "vg-root": {
            "type": "lvm",
            "members": [ "sda2" ],
            "volumes": [
                { "name": "lv-root", "size": "50G",  "fs": "ext4" },
                { "name": "lv-var", "size": "20G",  "fs": "ext4" },
                { "name": "lv-var-lib", "size": "70G", "fs": "ext4" },
                { "name": "lv-run", "size": "30G", "fs": "ext4" }
            ]
        }
    },
    "mounts": {
        "/":                { "device": "lv-root" },
        "/var":             { "device": "lv-var" },
        "/var/lib":         { "device": "lv-var-lib" },
        "/run":             { "device": "lv-run" },
        "/boot/efi":        { "device": "sda1" }
    }
}'''

# Load the above JSON template as a Python object
layoutDetail = json.loads(storage_layout)

# Put the layout into hardware["storage-extra"], which MAAS will read
hardware["storage-extra"] = layoutDetail

print("Saving custom storage layout to", os.environ["MAAS_RESOURCES_FILE"])
print(json.dumps(hardware))

# Write the updated hardware JSON back to MAAS_RESOURCES_FILE
with open(os.environ["MAAS_RESOURCES_FILE"], "w") as file:
    json.dump(hardware, file)
