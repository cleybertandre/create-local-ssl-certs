#!/usr/bin/env bash

if [ ! -f .env ]; then
  echo 'Error: .env file not found.'
  exit;
fi

source .env

mkdir -p $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER;
mkdir -p $APACHE_CONF_PATH/$APACHE_CA_FOLDER;

# Generate private key
openssl genrsa \
-des3 \
-out $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/rootCA.key \
2048

# Generate root certificate
openssl req \
-x509 \
-new \
-nodes \
-key $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/rootCA.key \
-sha256 \
-days 1024 \
-out $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem

# Convert to DER/CRT format.
openssl x509 \
-inform PEM \
-outform DER \
-in $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem \
-out $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.crt

echo
echo "#############################################"
echo "Done!"
echo "#############################################"
echo
echo "Remember importing $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.crt into your browser (see README.md for details)."
