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
checkIfbinaryExists wp "Please install wp-cli!"

# check mysql binary
checkIfbinaryExists mysql "Please install mysql!"

# check if we have arguments less than 0
if [ $# -lt 1 ]; then
    echo "Please enter at least (-p) the path parameter. With the path you want your project to be installed in!"
    exit 1
fi

while [ "$#" -gt 0 ]; do
    #1 is the first parameter
    if [ "$1" = "-p" ]; then
        # we get the directory path
        path=$2
        
        if ! [ -d $path ]; then
            mkdir $path
        fi
        
        # remove argument
        shift
    else
        # remove the parameter from the argument $[0......]
        shift
    fi
done
# # loop through all parameters
# for parameter in $*
# do

# done