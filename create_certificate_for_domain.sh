#!/usr/bin/env bash

if [ ! -f .env ]; then
  echo 'Error: .env file not found.'
  exit;
fi

source .env

display_debug_info() {
    echo ""
    echo "Showing all variables and quitting:"
    echo ""
    echo "APACHE_CONF_PATH=${APACHE_CONF_PATH}/"
    echo "APACHE_CA_FOLDER=${APACHE_CONF_PATH}/${APACHE_CA_FOLDER}/"
    echo "APACHE_CRT_FOLDER=${APACHE_CONF_PATH}/${APACHE_CRT_FOLDER}/"
    echo "APACHE_CSR_FOLDER=${APACHE_CONF_PATH}/${APACHE_CSR_FOLDER}/"
    echo "APACHE_KEYS_FOLDER=${APACHE_CONF_PATH}/${APACHE_KEYS_FOLDER}/"
}

if [ "$1" == "-h" ] ; then
    display_debug_info
    exit 0
fi

if [ -z "$1" ]
then
  echo "Error: Please supply a domain to create a certificate for.";
  echo "e.g. create_certificate_for_domain.sh www.candre.dev"
  exit;
fi

if [ ! -f $APACHE_CONF_PATH/$APACHE_CA_FOLDER/rootCA.pem ]; then
  echo 'Error: File rootCA.pem not found. Please run "create_root_cert_and_key.sh" first, then try again!'
  exit;
fi

if [ ! -f v3.ext ]; then
  echo 'Error: File v3.ext not found.'
  exit;
fi


if [ "$1" == "-h" ] ; then
    echo "Usage: `basename $0` [-h]"
    exit 0
fi

# Create a new private key if one doesnt exist, or use the xeisting one if it does
if [ -f $APACHE_CONF_PATH/$APACHE_KEYS_FOLDER/device.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

DOMAIN=$1
COMMON_NAME=$1
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
echo "#############################################"
echo "Done!"
echo "#############################################"
echo "Example of SSL directives into vhosts.conf:"
echo ""
echo "    <Directory /var/www>"
echo "        ..."
echo "    </Directory>"
echo ""
echo "    SSLEngine on"
echo "    SSLProtocol All -SSLv2 -SSLv3"
echo "    SSLCertificateFile    conf/ssl.crt/$DOMAIN.crt"
echo "    SSLCertificateKeyFile conf/ssl.key/device.key"
echo "    SSLCACertificateFile  conf/ssl.ca/rootCA.pem"