#!/bin/bash
API_KEY="ENTER YOUR KEY HERE"

# Extract the information from the response from the API based on your zipcode.
getting_weather() {

    # Get the information from the weather API.
    local RESPONSE=$(curl -s "http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$1")
    
    # Make sure that the website doesn't return an error.
    if echo "$RESPONSE" | jq -e 'has("error")' > /dev/null; then
        # Santa Check
        if [ "$1" == "88888" ]; then
            LOCALLOC="123 Elf Road"
            REGION="North Pole"
            COUNTRY="the Arctic"
            TEMP="-60"
            FEELSLIKE="-62"
            CONDITION="snowing a lot"
        else
            echo "Well, either there's a problem or where you live doesn't exist. Maybe try again?"
            exit 1
        fi
    else
        # Get the important variables 
        LOCALLOC=$(echo "$RESPONSE" | jq -r '.location.name')
        REGION=$(echo "$RESPONSE" | jq -r '.location.region')
        COUNTRY=$(echo "$RESPONSE" | jq -r '.location.country')
        TEMP=$(echo "$RESPONSE" | jq -r '.current.temp_c')
        FEELSLIKE=$(echo "$RESPONSE" | jq -r '.current.feelslike_c')
        CONDITION=$(echo "$RESPONSE" | jq -r '.current.condition.text')
    fi
}

# Let's add some flavor!
flavor_text_get() {
    local TEMP_INT=$(echo $TEMP | awk -F. '{print $1}')

    # Weather flavors
    if [[ ${CONDITION,,} == *"snow"* ]]; then
        FLAVOR="if it gets deep enough, you should go out and have a snowball fight!"
    elif [[ ${CONDITION,,} == *"rain"* ]]; then
        FLAVOR="don't forget an umbrella!"
    # Temperature flavors
    elif [ $TEMP_INT -ge 15 ] && [ $TEMP_INT -le 25 ]; then
        FLAVOR="perfect weather!"
    elif [ $TEMP_INT -ge 40 ]; then
        FLAVOR="honestly, I'd just stay inside with the AC."
    elif [ $TEMP_INT -ge 30 ]; then
        FLAVOR="stay hydrated in that heat!"
    elif [ $TEMP_INT -ge 25 ]; then
        FLAVOR="it's getting warm out there!"
    elif [ $TEMP_INT -le 0 ]; then
        FLAVOR="brrrrr, don't become an icicle!"
    elif [ $TEMP_INT -le 10 ]; then
        FLAVOR="bring a coat and stay toasty!"
    elif [ $TEMP_INT -le 20 ]; then
        FLAVOR="oooo, nice and cold!"
    else
        FLAVOR="have a nice day!"
fi
}

# Main 
# Make sure the arguments were correct.
if [ "$1" == "--zipcode" ]; then
    echo "Let's see what the weather is like at $2"
else
    echo "I'm so sorry, but the input should have --zipcode [zipcode]. Maybe try again?"
    exit 1
fi

# Get the weather and location for the output.
getting_weather "$2"

# Get some cute messages for the output.
flavor_text_get ""

echo "Currently, the weather for $LOCALLOC, $REGION in $COUNTRY is ${CONDITION,,} with a temperature of $TEMP°C — $FLAVOR"
