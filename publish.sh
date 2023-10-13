#!/bin/bash

# Function to check if vsce is installed
function check_vsce_installed {
    if ! command -v vsce &> /dev/null; then
        echo "vsce is not installed."
        read -p "Do you want to install vsce globally? (y/n): " install_vsce

        if [[ $install_vsce == "y" ]]; then
            npm install -g vsce
            if [ $? -ne 0 ]; then
                echo "Failed to install vsce. Exiting."
                exit 1
            fi
        else
            echo "vsce is required for some operations. Exiting."
            exit 1
        fi
    fi
}

# Function to get the current version from package.json
function get_current_version {
    echo $(grep '"version":' package.json | awk -F'"' '{print $4}')
}

# Prompt the user for a new version
function prompt_for_version {
    echo "Current version: $(get_current_version)"
    read -p "Do you want to release the next version? (y/n): " release_answer

    if [[ $release_answer != "y" ]]; then
        echo "Exiting without releasing."
        exit 0
    fi

    echo "Choose the version type:"
    echo "   j) Major"
    echo "   m) Minor"
    echo "   p) Patch"
    read -n 1 -s version_choice

    # Split the version into major, minor, patch
    IFS='.' read -ra VERSION_PARTS <<< "$(get_current_version)"
    major=${VERSION_PARTS[0]}
    minor=${VERSION_PARTS[1]}
    patch=${VERSION_PARTS[2]}

    # Determine new version
    case $version_choice in
        j)
            new_version="$((major + 1)).0.0"
            ;;
        m)
            new_version="$major.$((minor + 1)).0"
            ;;
        p)
            new_version="$major.$minor.$((patch + 1))"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac

    echo "Updated version: $new_version"

    # Replace the version in package.json
    sed -i.bak "s/\"version\": \"$(get_current_version)\"/\"version\": \"$new_version\"/" package.json
    rm package.json.bak
}

check_vsce_installed
prompt_for_version

read -p "Do you want to publish the extension? (y/n): " publish_answer
if [[ $publish_answer == "y" ]]; then
    vsce publish
fi

echo "Done! Remember to update the extension in VS Code."
