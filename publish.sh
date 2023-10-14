#!/bin/bash

# Function to check if vsce is installed
function check_vsce_installed {
  if ! command -v vsce &>/dev/null; then
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
get_current_version() {
  echo $(grep '"version":' package.json | awk -F'"' '{print $4}')
}

# Function to compile the extension
compile_extension() {
  echo "Compiling the extension..."
  npm run compile # You may need to customize this based on your project's build script
}

getCurrentPackageVersion() {
  PACKAGE_VERSION="$(echo "$(cat package.json |
    grep version |
    head -1 |
    awk -F: '{ print $2 }' |
    sed 's/[",]//g')" | sed -e 's/^[[:space:]]*//')"
  echo "\nCurrent release package version is ${BOLD}$PACKAGE_VERSION${BOLD_RESET}"
}

getVersionNumber() {
  while true; do
    unset MAJOR MINOR PATCH

    PROMPT_TEXT="Is this a major (j), minor (m) or patch (p) version? [jmp]"
    read -s -n 1 -p "$PROMPT_TEXT" key
    echo # Adding an echo here to make sure the output is on a new line after user input

    case $key in
    j | J)
      echo "\nReleasing as a ${BOLD}MAJOR${BOLD_RESET} version"
      MAJOR=true
      break
      ;;
    m | M)
      echo "\nReleasing as a ${BOLD}MINOR${BOLD_RESET} version"
      MINOR=true
      break
      ;;
    p | P | "") # Include an empty string for the case when the user just presses 'Enter'
      echo "\nReleasing as a ${BOLD}PATCH${BOLD_RESET} version"
      PATCH=true
      break
      ;;
    *)
      error "\nInvalid option selected - ${key}"
      exit 1
      ;;
    esac
  done
}

incrementVersion() {

  PACKAGE_JSON="package.json"

  if [[ ! -f "$PACKAGE_JSON" ]]; then
    echo "Error: $PACKAGE_JSON not found!"
    exit 1
  fi
  sem_version=$1 # semantic version
  version=(${sem_version//./ })

  if [ ${#version[@]} -ne 3 ]; then
    error "\nInvalid version number - expected: major.minor.patch"
    exit 1
  fi

  if [[ -n "$MAJOR" ]]; then
    ((version[0]++))
    version[1]=0
    version[2]=0
  elif [[ -n "$MINOR" ]]; then
    ((version[1]++))
    version[2]=0
  elif [[ -n "$PATCH" ]]; then
    ((version[2]++))
  fi

  NEXT_PACKAGE_VERSION="${version[0]}.${version[1]}.${version[2]}"

  # Replace the old version with the new version in package.json
  sed -i.bak -E "s/\"version\": \"([^\"]+)\"/\"version\": \"$NEXT_PACKAGE_VERSION\"/" package.json

  echo "\nNext package version is ${BOLD}$NEXT_PACKAGE_VERSION${BOLD_RESET}\n"
}

check_vsce_installed
compile_extension

read -p "Do you want to change the version? [y/n]" change_version_answer

if [[ $change_version_answer == "y" || $change_version_answer == "" ]]; then
  getCurrentPackageVersion
  getVersionNumber
  incrementVersion $PACKAGE_VERSION
fi

read -p "Do you want to package the extension? [y/n]: " package_answer
if [[ $package_answer == "y" || $package_answer == "" ]]; then
  vsce package
fi

read -p "Do you want to publish the extension? [N/y]: " publish_answer

if [[ $publish_answer == "y" || $publish_answer == "" ]]; then
  vsce publish
fi

echo "Done! Remember to update the extension in VS Code."
