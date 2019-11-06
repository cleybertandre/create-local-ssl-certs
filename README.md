#### Create Certificate and Key for Root Certificate Authority

*Utilizando o Git Bash:*

```
MSYS_NO_PATHCONV=1 ./create_root_cert_and_key.sh
```

#### Create Certificate and Key for Server and Client
```
MSYS_NO_PATHCONV=1 ./create_certificate_for_domain.sh www.comunhao.dev www.comunhao.dev
```

#### Important:

Remember to import rootCA.pem cert into your browser.