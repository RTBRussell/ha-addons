#!/bin/bash
# Auto-discover Home Assistant setup and write context file.
# Uses the Supervisor API (SUPERVISOR_TOKEN must be set).

set -euo pipefail

API_BASE="http://supervisor/core/api"
SUP_BASE="http://supervisor"
TOKEN="${SUPERVISOR_TOKEN:-}"
OUTPUT_DIR="/homeassistant/.claude"
OUTPUT_FILE="${OUTPUT_DIR}/ha_context.md"

if [ -z "${TOKEN}" ]; then
    echo "ERROR: SUPERVISOR_TOKEN not set" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"

api() {
    curl -s -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" "$@"
}

template() {
    api -X POST "${API_BASE}/template" -d "{\"template\": \"$1\"}"
}

# Gather data
CONFIG=$(api "${API_BASE}/config")
HA_VERSION=$(echo "${CONFIG}" | jq -r '.version // "unknown"')
LOCATION=$(echo "${CONFIG}" | jq -r '.location_name // "unknown"')
COMPONENTS=$(echo "${CONFIG}" | jq -r '.components[]' 2>/dev/null | cut -d. -f1 | sort -u)
COMPONENT_COUNT=$(echo "${COMPONENTS}" | wc -l | tr -d ' ')

STATES=$(api "${API_BASE}/states")
TOTAL_ENTITIES=$(echo "${STATES}" | jq 'length')

# Entity counts by domain
DOMAIN_COUNTS=$(echo "${STATES}" | jq -r '
  [.[].entity_id | split(".")[0]] | group_by(.) |
  map({domain: .[0], count: length}) | sort_by(-.count) |
  .[] | "- **\(.domain)**: \(.count) entities"
')

# Areas
AREAS=$(template '{% for area_id in areas() %}{{ area_id }}: {{ area_name(area_id) }} ({{ area_entities(area_id) | length }} entities)\n{% endfor %}' 2>/dev/null || echo "Unable to fetch areas")

# Automations
AUTOMATIONS=$(echo "${STATES}" | jq -r '
  [.[] | select(.entity_id | startswith("automation."))] |
  .[] | "- **\(.attributes.friendly_name // .entity_id)** — \(.state) (last: \(.attributes.last_triggered // "never"))"
')
AUTOMATION_COUNT=$(echo "${STATES}" | jq '[.[] | select(.entity_id | startswith("automation."))] | length')

# Installed add-ons
ADDONS=$(api "${SUP_BASE}/addons" | jq -r '
  .data.addons[] | select(.installed == true) |
  "- **\(.name)** (\(.slug)) — \(.state)"
' 2>/dev/null || echo "Unable to fetch add-ons")

# Config files
CONFIG_FILES=$(find /homeassistant -maxdepth 1 -name "*.yaml" -type f -printf "- %f (%s bytes)\n" 2>/dev/null | sort || echo "Unable to list config files")

# Custom components
CUSTOM_COMPONENTS=""
if [ -d /homeassistant/custom_components ]; then
    CUSTOM_COMPONENTS=$(ls -1 /homeassistant/custom_components/ 2>/dev/null | sed 's/^/- /')
fi

# Write output
cat > "${OUTPUT_FILE}" <<EOF
# Home Assistant Context
Auto-generated on $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Re-run: /opt/scripts/ha-discovery.sh

## System
- **HA Version**: ${HA_VERSION}
- **Location**: ${LOCATION}
- **Total Entities**: ${TOTAL_ENTITIES}
- **Integrations**: ${COMPONENT_COUNT}
- **Automations**: ${AUTOMATION_COUNT}

## Entities by Domain
${DOMAIN_COUNTS}

## Areas
${AREAS}

## Automations
${AUTOMATIONS:-No automations found.}

## Integrations
$(echo "${COMPONENTS}" | sed 's/^/- /')

${CUSTOM_COMPONENTS:+## Custom Components
${CUSTOM_COMPONENTS}
}
## Installed Add-ons
${ADDONS}

## Config Files
${CONFIG_FILES}
EOF

echo "Context written to ${OUTPUT_FILE}"
