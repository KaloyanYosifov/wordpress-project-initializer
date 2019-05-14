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
if [ $# -lt 2 ]; then
    echo "Please enter at least (-p) the path parameter. With the path you want your project to be installed in!"
    exit 1
fi

# check if the number of arguments is even
# and if it is less than four arguments
if [ $# -lt 4 ] && [ $(($# % 2)) -ne 0 ]; then
    echo "You have passed uneven arguments. Please do check if after an argument you have secified a value like (-p test)"
    exit 1
fi

# loop through all passed arguments for the script
# and add them to array

whitelistedArgumentsArray=("-p" "-v" "-u" "-ps" "-d")

# create a variable to check if the whitelist argument is present
pathArgumentPresent=false

mysqlOptions=""
wpCliOptions="core download"

mysqlUser=""
mysqlPassword=""
mysqlDatabase=""

# loop throught script's arguments
while [ "$#" -gt 0 ]; do
    argumentWhitelisted=false
    
    # loop throught whitelisted array
    for whitelistedArgument in ${whitelistedArgumentsArray[@]}; do
        
        # compare the whitelisted argument with the actual argument
        # if it is true we set the argument found to true
        # and break from the loop
        if [ $whitelistedArgument == $1 ]; then
            argumentWhitelisted=true
            break
        fi
    done
    
    
    # if argument is whitelisted
    # append to options array
    if [ $argumentWhitelisted = true ]; then
        # path to project so we append to wp cli options the path to create project
        if [ $1 == "-p" ]; then
            # set the path argument preset to true
            pathArgumentPresent=true
            
            wpCliOptions="$wpCliOptions --path=$2"
            
            # check if directory exists
            # if not create the directory
            if [ -d $2 ]; then
                mkdir $2
            fi;    
        elif [ $1 == "-v" ]; then
            if ! [[ $2 == [[:digit:]]\.[[:digit:]]\.[[:digit:]] ]]; then
                echo "Please enter a valid wordpress version like (5.0.1)"
                exit 1
            fi
            
            wpCliOptions="$wpCliOptions --version=$2"
        elif [ $1 == "-u" ]; then
            mysqlUser=$2
            mysqlOptions="$mysqlOptions -u$2"
        elif [ $1 == "-ps" ]; then
        echo $1
            mysqlPassword=$2
            mysqlOptions="$mysqlOptions -p$2"
        elif [ $1 == "-d" ]; then
            mysqlDatabase=$2
        fi
        
        # remove the second argument from the main script argument array
        shift
    fi
    
    # remove the argument from the main script argument array
    shift
done

# check if we had path argument
if [ $pathArgumentPresent = false ]; then
    echo "Cannot build command as path argument isn't present"
    exit 1
fi

$wpCliBinaryToUse $wpCliOptions

mysqlDatabaseCreationCommand="-e 'CREATE DATABASE $mysqlDatabase;'"

echo "Creating Database"

mysql $mysqlOptions $mysqlDatabaseCreationCommand
echo "Finished creating database"