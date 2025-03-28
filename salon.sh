#!/bin/bash

PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'
Services=$($PSQL "SELECT * FROM services")


echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU () { 
  
  echo -e "$1\n"
  #Fetch all services and display
  
  while read ser_id bar service 
    do
    echo "$ser_id) $service"
    done <<< "$Services" 
  
  SERVICE_SELECTION



}

SERVICE_SELECTION () {
#Bool for service found
service_missing=true 
#Read user choice
  read SERVICE_ID_SELECTED
  
  #Test if user choice is int
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    #Test is user choice is available in services
    service_id=0
    service_name=''
    while read ser_id bar service 
      do
      #echo $service
      if [[  $ser_id == $SERVICE_ID_SELECTED ]]
        then
        service_id=$ser_id
        
        #If availabe, send to Book appointment
        service_missing=false
        #echo "$ser_id $service" 
        break
      fi
      done <<< "$Services"
    #if service not in list
    if [[  $service_missing == true ]]
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      BOOK_APPOINTMENT $service_id 
    fi
  else
    #if service not an integer
    MAIN_MENU "I could not find that service. What would you like today?"
  fi

}


BOOK_APPOINTMENT () {
  ser_id=$1
  
  
  echo "$ser_id $service"
  echo -e "\nWhat's your CUSTOMER_PHONE number?"
  read CUSTOMER_PHONE
  echo -e "\n$CUSTOMER_PHONE"
  
  customer_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo "$customer_id"
  if [[ -z $customer_id ]]
    then
    
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    
    

    $PSQL "
      INSERT INTO customers (phone,name)
      VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')
    "
    customer_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

  

  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME

  
  $PSQL "
    INSERT INTO appointments (customer_id,service_id,time)
    VALUES ($customer_id, $ser_id,'$SERVICE_TIME')
    "
  echo -e "I have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU 'Welcome to My Salon, how can I help you?'