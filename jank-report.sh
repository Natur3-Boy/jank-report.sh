#!/bin/sh
# Jank Report
#################
# Notes:
#   - put the .zip file in the directory where you execute the script
#   - name the project the same as the zip file
cwd=$(pwd)

# check for zips
if [ ! -f *.zip ]
then
    { echo "No zip found in current working directory."; exit 1; }
fi

# Get author name
echo What is your full name?
read -r author

# get project name
echo What is your zip file\'s name?
ls -ah *.zip 
echo Type one of the above options.
read -r projectName

#check for old and delete
if [ -e "$projectName" ] 
then
    echo "Project already exists. Deleting old project."
    rm -rf "$projectName"
fi

#unzip
projectZip="${projectName}.zip"
if [ -f "$projectZip" ] 
then
    echo "UNZIPPING"
    #echo "Making new project \"$projectName\""
    mkdir "$projectName"
    #echo "Creating $projectName/img/."
    cd "${cwd}/${projectName}" || { echo "Project creation failed"; exit 1; }
    mkdir img 
    cp "${cwd}/$projectZip" "${cwd}/$projectName/img"
    cd img || { echo "Project creation failed"; exit 1; }
    unzip "$projectZip"
    rm "$projectZip"
    cd "${cwd}/$projectName" || { echo "Project creation failed"; exit 1; }
else
    { echo "zip not found"; exit 1; }
fi

# get the project title
echo What is your projects title?
read -r projectTitle

# create the report
texFile="${projectName}.tex"
cp ~/Documents/LaTeX_Templates/DSP-report.tex "${texFile}" || { echo "TeX template not found"; exit 1; }

# update the project author & title 
sed -i "s/assignmentAuthor/${author}/g" "${texFile}" || echo "Failed to update author"
sed -i "s/assignmentTitle/${projectTitle}/g" "${texFile}" || echo "Failed to update title"

# add imgs
cd "${cwd}/$projectName/" || { echo "Project creation failed"; exit 1; }
FILES="img/*"
for f in $FILES
do
    sed  "/\%Append Images Here/i \\\\\includegraphics[width=1\\\textwidth ]{$f}" "${texFile}" > temp
    cat temp > "${texFile}"
done

# compile & open the project
pdflatex --shell-escape "${texFile}" >> /dev/null
okular "${projectName}.pdf" &
