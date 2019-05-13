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
usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

# check the wp binary
checkIfbinaryExists wp "Please install wp-cli!"

# check mysql binary
checkIfbinaryExists mysql "Please install mysql!"

# check if we have arguments less than 0
if [ $# -lt 1 ]; then
    echo "Please enter at least (-d) the directory parameter. With the path you want your project to be installed in!"
    exit 1
fi

# declare the parameters array
declare -a paramtersArray

while getopts ":d:" option
do
    echo $option ${OPTARG}
done

# # loop through all parameters
# for parameter in $*
# do

# done