#! /bin/bash

checkIfbinaryExists()
{
    # $1 is the binary we are looking for
    # $2 is the message we are going to echo to the command user
    
    # get the binary location
    # and send the errors (2>) to null
    if [ -z $(which $1 2> /dev/null) ]; then
        
        # third parameter is to if we should print and exit the script
        if ! [ -z $3 ] && [ $3 = true ]; then
            echo "$2"
            exit 1
        fi
        
        return 1
    fi
}
# check the wp binary
wpCliBinaryToUse="wp"
checkIfbinaryExists $wpCliBinaryToUse "Please install wp-cli!"

# if the status code is equal to 1
# then we did not find the binary
# and we check for wp-cli
if [ $? -eq 1 ]; then
    checkIfbinaryExists wp-cli "Please install wp-cli!" true
    
    # we set the default binary to be wp-cli
    # since if we didnt find that the function would have exited the script
    wpCliBinaryToUse="wp-cli"
fi

# check mysql binary
checkIfbinaryExists mysql "Please install mysql!" true

# check if we have arguments less than 0
if [ $# -lt 1 ]; then
    echo "Please enter at least (-p) the path parameter. With the path you want your project to be installed in!"
    exit 1
fi

# loop through all passed arguments for the script
# and add them to array

whitelistedArgumentsArray=("-p" "--user" "--password")

# loop throught script's arguments
for argument in $#; do
    argumentFound=false
    
    # loop throught whitelisted array
    for whitelistedArgument in ${whitelistedArgumentsArray[@]}; do
        
        # compare the whitelisted argument with the actual argument
        # if it is true we set the argument found to true
        # and break from the loop
        if [ $whitelistedArgument == $1 ]; then
            argumentFound=true
            break
        fi
        
    done
    
    
    if [ $argumentFound = true ]; then
        echo $1
    fi
    
    shift
done