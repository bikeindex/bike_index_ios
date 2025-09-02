#!/usr/bin/env sh

#
# Usage:
#
#     ictool input-document --export-preview platform appearance width height scale output-png-path
#     ictool input-document --export-preview platform appearance width height scale light-angle output-png-path
#     ictool input-document --export-preview platform appearance width height scale light-angle tint-color output-png-path
#     ictool input-document --export-preview platform appearance width height scale light-angle tint-color tint-strength output-png-path
#
#     ictool --version
#
# Example Invocation:
#
#     ictool input-document.icon --export-preview iOS Light 1024 1024 2 output.png
#
alias ictool="/Applications/Xcode26-beta7.app/Contents/Applications/Icon\ Composer.app/Contents/Executables/ictool"

# create an array of all source Icon Composer files
icon_composer_files=(BikeIndex/AppIcons/*.icon)

for ((i=0; i<${#icon_composer_files[@]}; i++)); do
    echo "${icon_composer_files[$i]}"
    icon_name=`echo ${icon_composer_files[$i]} | cut -d '/' -f 3 | sed 's/.icon//'`
    output_path="BikeIndex/Assets.xcassets/AppIcons-in-app/${icon_name}-in-app.imageset/AppIcon.jpg"

    ictool "${icon_composer_files[$i]}" --export-preview iOS Light 1024 1024 2 "$output_path"
done
