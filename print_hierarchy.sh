#!/bin/bash

# Set the maximum depth
# Change this value to adjust the number of levels the script will print
max_depth=3

# Set use of .gitignore
# Change this value to false if you don't want to use .gitignore
use_gitignore=true

# Read .gitignore and convert it to an array if use_gitignore is true
if $use_gitignore; then
    mapfile -t ignore < .gitignore
fi

print_folder_recurse() {
    for i in "$1"/*;do
        # Check if the file or directory is in .gitignore
        if $use_gitignore; then
            for pattern in "${ignore[@]}"; do
                if [[ $i == *$pattern* ]]; then
                    continue 2
                fi
            done
        fi

        depth=$((${2:-0}))
        spacing=$(printf "%*s" "$depth" "")
        if [ -d "$i" ];then
            if [ $depth -ge $((max_depth*4)) ]; then
                echo "${spacing}│   └── ..."
                break
            else
                echo "${spacing}├── ${i##*/}" # Print folder name
                print_folder_recurse "$i" $((depth+4))
            fi
        elif [ -f "$i" ]; then
            if [ $depth -lt $((max_depth*4)) ]; then
                # Add more cases here if you want to add comments for different file types
                case "${i##*/}" in
                    Dockerfile)
                        echo "${spacing}│   ├── ${i##*/}                # Dockerfile"
                        ;;
                    src)
                        echo "${spacing}│   ├── ${i##*/}                # Source code"
                        ;;
                    *.sh)
                        echo "${spacing}│   ├── ${i##*/}                # Shell Script"
                        ;;
                    helm)
                        echo "${spacing}│   ├── ${i##*/}                # Helm chart"
                        ;;
                    Chart.yaml)
                        echo "${spacing}│   ├── ${i##*/}                # Helmchart metadata"
                        ;;
                    values.yaml)
                        echo "${spacing}│   ├── ${i##*/}                # Helm configuration values"
                        ;;
                    templates)
                        echo "${spacing}│   ├── ${i##*/}                # Kubernetes resource definitions"
                        ;;
                    deployment.yaml)
                        echo "${spacing}│   ├── ${i##*/}"
                        ;;
                    service.yaml)
                        echo "${spacing}│   ├── ${i##*/}"
                        ;;
                    *)
                        echo "${spacing}│   ├── ${i##*/}"
                        ;;
                esac
            fi
        fi
    done
}

# If no directory is specified, default to the current directory
# Change the default directory here if you want the script to run on a different directory by default
dir=${1:-.}
print_folder_recurse $dir
