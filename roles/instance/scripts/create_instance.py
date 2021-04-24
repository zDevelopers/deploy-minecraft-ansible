import json
import os
import sys
import time

import ovh

# Credentials

ENDPOINT = os.environ.get("OVH_ENDPOINT")
SERVICE_NAME = os.environ.get("OVH_SERVICE_NAME")
ZONE_NAME = os.environ.get("OVH_ZONE_NAME")

APPLICATION_KEY = os.environ.get("OVH_APPLICATION_KEY")
APPLICATION_SECRET = os.environ.get("OVH_APPLICATION_SECRET")
CONSUMER_KEY = os.environ.get("OVH_CONSUMER_KEY")

SSH_KEY_ID = os.environ.get("OVH_SSH_KEY_ID")


# Instance to create

REGION = os.environ.get("OVH_INSTANCE_REGION")
FLAVOR = os.environ.get("OVH_INSTANCE_FLAVOR")
IMAGE = os.environ.get("OVH_INSTANCE_IMAGE").lower()
NAME = f"gameserver-{os.environ.get('GAME_NAME')}-{os.environ.get('OVH_INSTANCE_DNS')}"
DNS = os.environ.get("OVH_INSTANCE_DNS")


# Create client

client = ovh.Client(
    endpoint=ENDPOINT,
    application_key=APPLICATION_KEY,
    application_secret=APPLICATION_SECRET,
    consumer_key=CONSUMER_KEY,
)

BASE = f"/cloud/project/{SERVICE_NAME}"


# Find flavor ID

flavors = client.get(f"{BASE}/flavor", region=REGION)
flavor_id = None

for f in flavors:
    if f["name"] == FLAVOR:
        flavor_id = f["id"]
        break

if not flavor_id:
    print(f"Unknown flavor {FLAVOR}", file=sys.stderr)
    sys.exit(1)


# Find image ID

images = client.get(f"{BASE}/image", flavorType=FLAVOR, osType="linux", region=REGION)
image_id = None
instance_user = None

for i in images:
    if i["name"].lower() == IMAGE:
        image_id = i["id"]
        instance_user = i["user"]
        break

if not image_id:
    print(f"Unknown image {IMAGE}", file=sys.stderr)
    sys.exit(1)


# Create instance

instance_created = client.post(
    f"{BASE}/instance",
    flavorId=flavor_id,
    imageId=image_id,
    monthlyBilling=False,
    name=NAME,
    region=REGION,
    sshKeyId=SSH_KEY_ID,
)

instance_id = instance_created["id"]


# Wait for instance to be available

tests = 0
while True:
    time.sleep(5)
    instance = client.get(f"{BASE}/instance/{instance_id}")

    if instance["status"] == "ACTIVE":
        break

    elif instance["status"] not in ["BUILD", "BUILDING", "REBOOT", "REBUILD"]:
        print(
            f"Error while creating instance: {instance['status']}\n\n{json.dumps(instance_created)}",
            file=sys.stderr,
        )
        sys.exit(1)

    tests += 1
    if tests > 120:  # 10 minutes
        print("Error while creating instance: timeout", file=sys.stderr)
        sys.exit(1)


# Create/update DNS entry

BASE = f"/domain/zone/{ZONE_NAME}"
domain = f"{DNS}.games"

# First delete existing records for this domain, if any

records = client.get(f'{BASE}/record', subDomain=domain)
for record in records:
    client.delete(f'{BASE}/record/{record}')

# Then we create our new domain

instance_ip_4 = None
instance_ip_6 = None

for ip in instance["ipAddresses"]:
    if ip["version"] == 4:
        instance_ip_4 = ip["ip"]
    elif ip["version"] == 6:
        instance_ip_6 = ip["ip"]

if instance_ip_4:
    client.post(
        f"{BASE}/record",
        fieldType="A",
        subDomain=domain,
        target=instance_ip_4,
        ttl=3600,
    )

if instance_ip_6:
    client.post(
        f"{BASE}/record",
        fieldType="AAAA",
        subDomain=domain,
        target=instance_ip_6,
        ttl=0,  # FIXME
    )

# And we refresh the zone to apply modifications

if instance_ip_4 or instance_ip_6:
    client.post(f"{BASE}/refresh")


# Return the instance SSH connection string on stdout
# We give the IP address to avoid DNS propagation and cache problems

print(f"{instance_user}@{instance_ip_4 or instance_ip_6}", end="")
