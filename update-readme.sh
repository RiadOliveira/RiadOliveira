#!/bin/bash
set -e

# Define markers
START_MARKER="<!-- START TECHNOLOGIES -->"
END_MARKER="<!-- END TECHNOLOGIES -->"

# Create temporary files
TECH_SECTION=$(mktemp)
README_TEMP=$(mktemp)

# Start with a newline after the marker
echo "" > $TECH_SECTION

# Process the technologies.json file and create markdown for each technology
jq -r 'to_entries | sort_by(.value.id) | .[] | .key + " " + .value.icon' technologies.json | while read -r KEY ICON; do
  echo "![${KEY}](${ICON})" >> $TECH_SECTION
done

# Replace the content between markers in README.md
awk -v start="$START_MARKER" -v end="$END_MARKER" -v replace="$(cat $TECH_SECTION)" '
  $0 ~ start {print; print replace; flag=1; next}
  $0 ~ end {flag=0; print; next}
  flag == 0 {print}
' README.md > $README_TEMP

# Replace the old README with the new one
mv $README_TEMP README.md

# Clean up
rm $TECH_SECTION

echo "✅ README.md updated successfully"