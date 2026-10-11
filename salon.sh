#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n ~~~~~ Kate's Salon ~~~~~\n"

MAIN_MENU() {
  
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nHow can I help you today?"
  fi

  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "You must choose a valid number."
    return
  fi

  SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if  [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "You must choose one of the services offered."
    return
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI can't find an account with that number. What is your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      
      echo -e "\nWhat time would you like to make your appointment for?"
      read SERVICE_TIME

      INSERT_NEW_CUSTOMER_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_SELECTED)")

      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_SELECTED")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
      return

    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
      
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_SELECTED")
      
      echo -e "\nWhat time would you like to make your appointment for?"
      read SERVICE_TIME

      INSERT_CUSTOMER_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_SELECTED)")
    
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  fi

} 

MAIN_MENU