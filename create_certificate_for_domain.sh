#!/usr/bin/env bash

source .env

if [ -z "$1" ]
then
  echo "Please supply a subdomain to create a certificate for";
  echo "e.g. www.mysite.com"
  exit;
fi

if [ ! -f $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem ]; then
  echo 'Please run "create_root_cert_and_key.sh" first, and try again!'
  exit;
fi
if [ ! -f v3.ext ]; then
  echo 'Please download the "v3.ext" file and try again!'
  exit;
fi

# echo "APACHE_CONF_PATH=${APACHE_CONF_PATH}"
# echo "APACHE_CA_FOLDER=${APACHE_CONF_PATH}/${APACHE_CA_FOLDER}"
# echo "APACHE_CRT_FOLDER=${APACHE_CONF_PATH}/${APACHE_CRT_FOLDER}"
# echo "APACHE_CSR_FOLDER=${APACHE_CONF_PATH}/${APACHE_CSR_FOLDER}"
# echo "APACHE_KEYS_FOLDER=${APACHE_CONF_PATH}/${APACHE_KEYS_FOLDER}"
# exit;
  
# Create a new private key if one doesnt exist, or use the xeisting one if it does
if [ -f $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/device.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

DOMAIN=$1
COMMON_NAME=${2:-*.$1}
SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=$COMMON_NAME"
NUM_OF_DAYS=825

openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/device.key -subj "$SUBJECT" -out $APACHE_CONF_PATH/$APACHE_CSR_FOLDER/device.csr
cat v3.ext | sed s/%%DOMAIN%%/"$COMMON_NAME"/g > v3.ext.tmp
openssl x509 -req -in $APACHE_CONF_PATH/$APACHE_CSR_FOLDER/device.csr -CA $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem -CAkey $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/rootCA.key -CAcreateserial -out $APACHE_CONF_PATH/$APACHE_CRT_FOLDER/device.crt -days $NUM_OF_DAYS -sha256 -extfile v3.ext.tmp

# move output files to final filenames
mv $APACHE_CONF_PATH/$APACHE_CSR_FOLDER/device.csr "$APACHE_CONF_PATH/$APACHE_CSR_FOLDER/$DOMAIN.csr"
cp $APACHE_CONF_PATH/$APACHE_CRT_FOLDER/device.crt "$APACHE_CONF_PATH/$APACHE_CRT_FOLDER/$DOMAIN.crt"

# move files to apache ssl folder

# remove temp file
rm -f $APACHE_CONF_PATH/$APACHE_CRT_FOLDER/device.crt;
rm -f v3.ext.tmp;

echo 
echo "###########################################################################"
echo Done! 
echo "###########################################################################"
echo "To use these files on your server, simply copy both $DOMAIN.csr and"
echo "device.key to your webserver, and use like so (if Apache, for example)"
echo 
echo "    SSLCertificateFile    /path_to_your_files/$DOMAIN.crt"
echo "    SSLCertificateKeyFile /path_to_your_files/device.key"