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
