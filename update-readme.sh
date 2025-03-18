set -e

# Define markers
START_MARKER="<!-- START TECHNOLOGIES -->"
END_MARKER="<!-- END TECHNOLOGIES -->"

# Create temporary files
TECH_SECTION=$(mktemp)
README_TEMP=$(mktemp)

# Process the optimized technologies.json file and create markdown for each technology
jq -r '.[]' technologies.json | while read -r ENTRY; do
  BADGE=$(echo "$ENTRY" | cut -d' ' -f1)
  LOGO=$(echo "$ENTRY" | cut -d' ' -f2)
  COLOR=$(echo "$ENTRY" | cut -d' ' -f3)
  ICON="https://img.shields.io/badge/${BADGE}?style=for-the-badge&logo=${LOGO}&logoColor=${COLOR}"
  echo "![${LOGO}](${ICON})" >> $TECH_SECTION
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
