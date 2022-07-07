#!/bin/sh
# Jank Report
# by: Dan Hutson
#################
# Notes:
#   - put the .zip file in the directory where you execute the script
#   - name the project the same as the zip file
cwd=$(pwd)

# Build project directory
echo What is your project files name?
ls -ah
echo Type one of the above options.
read -r projectName

#check for old and delete
if [ -e "$projectName" ] 
then
    echo "Project already exists. Deleting old project."
    rm -rf "$projectName"
fi


#check for existing zip file and unzip
projectZip="${projectName}.zip"
if [ -f "$projectZip" ] 
then
    echo "ZIP found."
    echo "Making new project \"$projectName\""
    mkdir "$projectName"
    echo "Creating $projectName/img/."
    cd "${cwd}/${projectName}" || { echo "Project creation failed"; exit 1; }
    mkdir img 
    cp "${cwd}/$projectZip" "${cwd}/$projectName/img"
    cd img || { echo "Project creation failed"; exit 1; }
    echo "UNZIPPING"
    unzip "$projectZip"
    rm "$projectZip"
    cd "${cwd}/$projectName" || { echo "Project creation failed"; exit 1; }
else
    echo "NO ZIP FOUND"; exit;
fi

# CREATE THE REPORT
texFile="${projectName}.tex"
cp ~/Documents/LaTeX_Templates/DSP-report.tex "${texFile}" || { echo "TeX template not found"; exit 1; }

# get the project alias w/ user input
echo What is your projects title?
read -r projectTitle
echo "Your project title is $projectTitle"

# update the project title w/ alias
# (use 'sed' command)
sed -i "s/assignmentTitle/${projectTitle}/g" "${texFile}" 
#cat temp > ${texFile}

# add 'img/*' to the report
cd "${cwd}/$projectName/" || { echo "Project creation failed"; exit 1; }
FILES="img/*"
for f in $FILES
do
    sed  "/\%Append Images Here/i \\\\\includegraphics[width=1\\\textwidth ]{$f}" "${texFile}" > temp
    cat temp > "${texFile}"
done

# Compile the project
pdflatex --shell-escape "${texFile}"

#open the file
okular "${projectName}.pdf" &
