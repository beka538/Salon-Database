#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi  

  echo -e "\nWelcome to My Salon, how can I help you?\n"

  # get services
  SERVICES=$($PSQL "SELECT * FROM services")
  
  # print services
  echo "$SERVICES" | while read SERVICE_ID PIPE SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a number. What would you like today?"
  else
    # if not a service id
    RESULT_SERVICE_ID_SELECTED=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $RESULT_SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      GET_CUSTOMER $SERVICE_ID_SELECTED
      
    fi
  fi
}

GET_CUSTOMER() {
  SERVICE_ID_SELECTED=$1
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if customer does not exist
  if [[ -z $CUSTOMER_ID ]]
  then
    # get new customer
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi
  BOOK_APPOINTMENT $CUSTOMER_NAME $CUSTOMER_ID $SERVICE_ID_SELECTED
}

BOOK_APPOINTMENT() {
  #get values to book
  CUSTOMER_NAME=$1
  CUSTOMER_ID=$2
  SERVICE_ID_SELECTED=$3

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")


  # get appointment time
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # if time doesn't start with a number
  if [[ ! $SERVICE_TIME =~ ^[0-9]+* ]]
  then
    BOOK_APPOINTMENT "\nPlease enter a valid time for your cut."
  else
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU 