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

# print help menu and exit the program
printHelp() {
    # set the color of the text
    echo -e '\E[33m'
    echo "Minimal requirements to use the shell is to pass a path with (-p {path})"
    echo "Other options:"
    echo "-v {version}- [set the version of the wordpress to be installed in the path]"
    echo "-u {name}- [set the database user]"
    echo "-ps {password}- [set the database password]"
    echo "-d {name}- [set the database name to be created]"
    echo 'Example: init-wordpress.sh -p /home/test-project -v 4.9.9 -u dbuser -ps dbpass -d db'
    # reset color, so we do not break terminal
    echo -e '\E[0m'
    exit 0
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

# check if the is not empty and that first argument is help
if ! [ -z $1 ] && ( [ $1 == "-h" ] || [ $1 == "--help" ] ); then
    printHelp
fi

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

mysqlOptions="mysql"
wpCliOptions="core download"
wordpressPath=""

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

            # set the wordpress path 
            wordpressPath=$2
            
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
            mysqlPassword=$2
            mysqlOptions="$mysqlOptions -p$2"
        elif [ $1 == "-d" ]; then
            mysqlDatabase=$2
        elif [ $1 == "-h" ] || [ $1 == "--help" ]; then 
            printHelp
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

echo "Creating Database"
# send the output to the void
$mysqlOptions -e "CREATE DATABASE $mysqlDatabase" > /dev/null
echo "Finished creating database"

wpConfigPath=$wordpressPath/wp-config.php
# copy wp-config
cp $wordpressPath/wp-config-sample.php $wpConfigPath

# set the environments for wp-config
# sed command for replacing strings
# -i is the bak file we are going to use -- we set it empty as we do not need a backup it is also used to set the file's contents
# the replacement strings 
# the path

echo Configuring wp-config

sed -i '' "s/database_name_here/$mysqlDatabase/g" $wpConfigPath
sed -i '' "s/password_here/$mysqlPassword/g" $wpConfigPath
sed -i '' "s/username_here/$mysqlUser/g" $wpConfigPath
sed -i '' "s/'WP_DEBUG', false/'WP_DEBUG', true/g" $wpConfigPath

echo Finished configuring