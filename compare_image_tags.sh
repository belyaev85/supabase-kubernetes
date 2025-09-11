#!/bin/bash

# Default file paths
VALUES_FILE="charts/supabase/values.yaml"
COMPOSE_FILE="charts/supabase/docker-compose.yml"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            echo "=== Image Tags Comparison Tool ==="
            echo "Usage: ./compare_image_tags.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --help          Show this help message"
            echo "  --values FILE   Path to values.yaml file (default: charts/supabase/values.yaml)"
            echo "  --compose FILE  Path to docker-compose.yml file (default: charts/supabase/docker-compose.yml)"
            echo ""
            echo "Examples:"
            echo "  ./compare_image_tags.sh"
            echo "  ./compare_image_tags.sh --values custom/values.yaml --compose custom/docker-compose.yml"
            exit 0
            ;;
        --values)
            VALUES_FILE="$2"
            shift 2
            ;;
        --compose)
            COMPOSE_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate files exist
if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: values.yaml file not found at $VALUES_FILE"
    exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: docker-compose.yml file not found at $COMPOSE_FILE"
    exit 1
fi

echo "=== Image Tags Comparison Tool ==="
echo "Comparing: $VALUES_FILE vs $COMPOSE_FILE"
echo ""

# Function to extract data from values.yaml
extract_values_data() {
    awk '
    BEGIN {
        service = ""
        repository = ""
        tag = ""
    }
    /^[a-zA-Z][a-zA-Z0-9_]*:/ {
        service = $1
        sub(/:$/, "", service)
        repository = ""
        tag = ""
    }
    /repository:/ {
        repository = $2
        gsub(/[" ]/, "", repository)
    }
    /tag:/ {
        tag = $2
        gsub(/[" ]/, "", tag)
        if (service != "" && repository != "" && tag != "") {
            print service "|" repository "|" tag
        }
    }' "$VALUES_FILE"
}

# Function to extract data from docker-compose.yml
extract_compose_data() {
    awk '
    BEGIN {
        service = ""
    }
    /^  [a-zA-Z][a-zA-Z0-9_]*:/ {
        service = $1
        sub(/:$/, "", service)
    }
    /    image:/ {
        image = $2
        gsub(/[" ]/, "", image)
        split(image, parts, ":")
        repository = parts[1]
        tag = parts[2]
        if (service != "" && repository != "" && tag != "") {
            print service "|" repository "|" tag
        }
    }' "$COMPOSE_FILE"
}

# Function to display services from a file
display_services() {
    local title=$1
    local data=$2

    echo "=== $title ==="
    echo "$data" | awk -F'|' '{printf "%-15s %s:%s\n", $1, $2, $3}' | sort
    echo ""
}

# Main comparison function
compare_tags() {
    local values_data=$(extract_values_data)
    local compose_data=$(extract_compose_data)

    display_services "Services from values.yaml" "$values_data"
    display_services "Services from docker-compose.yml" "$compose_data"

    echo "=== Comparison Results ==="
    echo ""

    local found_mismatch=0

    # Compare values.yaml vs docker-compose.yml
    echo "$values_data" | while IFS='|' read -r service repo tag; do
        compose_match=$(echo "$compose_data" | grep "^$service|")
        if [ -n "$compose_match" ]; then
            IFS='|' read -r comp_service comp_repo comp_tag <<< "$compose_match"
            if [ "$tag" != "$comp_tag" ]; then
                echo "❌ MISMATCH: $service"
                echo "   values.yaml:    $repo:$tag"
                echo "   docker-compose: $comp_repo:$comp_tag"
                echo ""
                found_mismatch=1
            else
                echo "✅ MATCHES: $service - $repo:$tag"
            fi
        else
            echo "⚠️  MISSING in docker-compose.yml: $service - $repo:$tag"
            found_mismatch=1
        fi
    done

    # Check for services in docker-compose.yml but not in values.yaml
    echo "$compose_data" | while IFS='|' read -r service repo tag; do
        values_match=$(echo "$values_data" | grep "^$service|")
        if [ -z "$values_match" ]; then
            echo "⚠️  MISSING in values.yaml: $service - $repo:$tag"
            found_mismatch=1
        fi
    done

    echo ""
    if [ $found_mismatch -eq 0 ]; then
        echo "🎉 All tags match perfectly between files!"
    else
        echo "💡 Image tag mismatches detected"
    fi
}

# Run the comparison
compare_tags

# Usage reminder
echo ""
echo "=== Usage Reminder ==="
echo "Use --help for full usage information: ./compare_image_tags.sh --help"
