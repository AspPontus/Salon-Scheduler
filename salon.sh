

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome to my Salon ~~"


LIST_SERVICES() {
  echo -e "\nWhat are you looking to do today?"

SERVICES_RESULT=$($PSQL "SELECT * FROM services")
  LIST_SERVICES= echo "$SERVICES_RESULT" | while read SERVICE_ID BAR SERVICE
    do
    echo  "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
}

MAIN_MENU() {
   if [[ $1 ]] 
    then 
    echo -e "\n$1"
  fi

LIST_SERVICES

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    LIST_SERVICES
    else

SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_ID ]]
  then
    LIST_SERVICES
   else 

      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
        then
        #create new customer
        echo -e "\nWhat name do you want to book the appointment under?"
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) 
        VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      FORMATTED_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')
      echo "Welcome $FORMATTED_NAME, what time would you like to arrive?"
      read SERVICE_TIME

      INSERT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES (
      ( SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ),
      ( SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ),
      '$SERVICE_TIME')")

      CONFIRMATION=$($PSQL "SELECT services.name, time, customers.name FROM customers 
      INNER JOIN appointments USING (customer_id)
      INNER JOIN services USING (service_id)
      WHERE phone='$CUSTOMER_PHONE' 
      AND time='$SERVICE_TIME' 
      AND service_id=$SERVICE_ID_SELECTED ")

      echo $CONFIRMATION | while read SERVICE BAR TIME BAR NAME
        do
        echo -e "\nI have put you down for a $SERVICE at $TIME, $NAME."
      done  
    fi
  fi 
}



MAIN_MENU
