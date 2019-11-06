#!/usr/bin/env bash

source .env

openssl genrsa -out $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/rootCA.key 2048
openssl req -x509 -new -nodes -key $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/rootCA.key -sha256 -days 1024 -out $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem
openssl x509 -inform PEM -outform DER -in $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem -out $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.crt

echo
echo "#############################################"
echo "Done!"
echo "#############################################"
echo "Remember importing $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.crt into your browser (see README.md for details)."