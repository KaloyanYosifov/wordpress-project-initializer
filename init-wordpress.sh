#! /bin/bash

checkIfbinaryExists()
{
    # $1 is the binary we are looking for
    # $2 is the message we are going to echo to the command user
    
    # get the binary location
    # and send the errors (2>) to null
    if [ -z $(which $1 2> /dev/null) ]; then
        echo "$2"
        exit 1
    fi
}
# check the wp binary
checkIfbinaryExists wp-cli "Please install wp-cli!"

# check mysql binary
checkIfbinaryExists mysql "Please install mysql!"

# check if we have arguments less than 0
if [ $# -lt 1 ]; then
    echo "Please enter at least (-d) the directory parameter. With the path you want your project to be installed in!"
    exit 1
fi

# declare whitelisted parameters
whitelistParamters=( "d" "u" "p" )
# declare the parameters array
parameters=()

# loop to get all options
while getopts ":d:u:p" option; do
    # default to 0
    optionFound=0
    
    for whitelistedParameter in ${whitelistParamters[@]}; do
        if [ "$option" == "$whitelistedParameter" ]; then
            # set to 1 (or true in most programming languages)
            optionFound=1
        fi
    done
    
    if [ $optionFound -eq 1 ]; then
        parameters["${option}ewrwer"]=$OPTARG
    fi
done

for param in ${parameters[@]}; do
    echo $param
done

# # loop through all parameters
# for parameter in $*
# do

# done