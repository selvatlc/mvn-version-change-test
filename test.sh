#!/bin/bash
NEW_VERSION="1.5.5"

process_module() {
    local module_dir="$1"

    # Extract submodules from the pom.xml inside the module directory
    submodules=$(mvn -f "$module_dir/pom.xml" help:evaluate -Dexpression=project.modules | grep '<string>' | sed 's|</*string>||g' | grep -v '^[[:space:]]*$')

    if [ -n "$submodules" ]; then

          if grep -q '<version>' "$module_dir/pom.xml"; then
              echo "Updating version in module: $module_dir"
              mvn -f "$module_dir/pom.xml" versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false -DprocessParent=false -DprocessAllModules=true
          else
              echo "No version tag found in $module_dir/pom.xml. Skipping version update."
          fi

        for submodule in $submodules; do
            process_module "$module_dir/$submodule"
        done
    else
        echo "No submodules found in $module_dir"
    fi
}

# Start with the root directory (replace '.' with your root module directory if needed)
root_directory="."
process_module "$root_directory"

#for dir in $(find . -name pom.xml -exec dirname {} \;); do
#    echo "Processing directory: $dir"
#    (cd "$dir" && mvn versions:set -DnewVersion=1.5.3 -DprocessAllModules=true -DprocessParent=true && versions:update-child-modules -DnewVersion=1.5.3)
#
#done
