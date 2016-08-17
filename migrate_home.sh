#!/bin/bash

src="$1";
dest="$2";
#The path of this script.
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#The message that gets displayed as help
help_message="Usage: migrate_home.sh SOURCE DEST
Copy from SOURCE to DEST all the files and directories (including all contained subdirectories and files) mentioned in the file $script_dir/migrate_home_paths
Lines in that file will be skipped if the line begins with a hash #.

Arguments:
        --help  display this help and exit

A logfile will be created at $script_dir/migrate_home.log.
This script will overwrite any matching files and folders in the DEST directory.
It will fail on an individual file if it exists at DEST and is of a different type (normal file or directory) than the one in SOURCE.
Known assumptions:
    - That SOURCE, DEST and migrate_home_paths exist."

#Display help if more than 2 args or 1 arg is --help
if [ $# -eq 1 ] && [ $1 == "--help" ] || [ $# -ne 2 ]; then
    echo "$help_message"
    exit 1
fi


main()  {
    #If we cant change dir, then exit
    cd "$src" || exit 1
    while read -r; do
        #Skip line if it begins with a hash.
        [[ "$REPLY" =~ ^# ]] && echo mig: skipping "$REPLY" && continue
        #Skip line if it doesnt begin with alphanumeric or punctuation.
        [[ ! "$REPLY" =~ ^[[:graph:]] ]] && echo mig: malformed line: "$REPLY" && continue
        #Skip line if $REPLY is missing in $src
        [[ ! -e "$REPLY" ]] && echo mig: SOURCE missing for "$src"/"$REPLY" && continue
        #If everything is fine
        echo mig: attempting cp: "$REPLY"
        cp -av --parents "$REPLY" "$dest"
    done < "$script_dir"/migrate_home_paths

}

#Outputting stdout and stderr to logfile
main 2>&1 | tee "$script_dir"/migrate_home.log