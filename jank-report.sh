#!/bin/bash
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
read projectName

#check for old and delete
projectAlreadyExists= find . -maxdepth 1 -name $projectName
if [ -n projectAlreadyExists ] 
then
    echo "Project already exists. Deleting old project."
    rm -rf $projectName
    rm *.jpg
    rm *.tex
    rm *.log
fi


#check for existing zip file and unzip
projectZip="${projectName}.zip"
projectZipExists= find . -maxdepth 1 -name $projectZip
if [ -n projectZipExists ] 
then
    echo "ZIP found."
    echo "Making new project \"$projectName\""
    mkdir $projectName
    echo "Creating $projectName/img/."
    cd "${cwd}/${projectName}"
    mkdir img 
    cp "${cwd}/$projectZip" "${cwd}/$projectName/img"
    cd img 
    echo "UNZIPPING"
    unzip $projectZip
    rm $projectZip
    cd "${cwd}/$projectName"
else
    echo "NO ZIP FOUND"
    exit
    #unzipFailed= true
fi

# CREATE THE REPORT
texFile="${projectName}.tex"
cp ~/Documents/LaTeX\ Templates/DSP-report.tex ${texFile}

# get the project alias w/ user input
echo What is your projects title?
read projectTitle
echo "Your project title is $projectTitle"

# update the project title w/ alias
# (use 'sed' command)
sed -i "s/assignmentTitle/${projectTitle}/g" ${texFile} #> temp
#cat temp > ${texFile}

# add 'img/*' to the report
cd "${cwd}/$projectName/"
FILES="img/*"
for f in $FILES
do
    sed  "/\%Append Images Here/i \\\\\includegraphics[width=1\\\textwidth ]{$f}" ${texFile} > temp
    cat temp > ${texFile}
done

# Compile the project
pdflatex --shell-escape "${texFile}"

#open the file
okular "${projectName}.pdf" &
