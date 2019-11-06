## Create Root CA and Certificates for local development

*Note 01:* Scripts presented here were created based on [this answer](https://stackoverflow.com/a/43666288/4249308) at StackOverflow.

*Note 02:* If you're on Windows, use `Git Bash` and prepend commands below with `MSYS_NO_PATHCONV=1`.

#### Create Certificate and Key for Root Certificate Authority

```
./create_root_cert_and_key.sh
```

#### Create Certificate and Key for Server and Client

To create a **wildcard certificate** to your server *(e.g. `*.candre.dev`)*.

```
./create_certificate_for_domain.sh candre.dev
```

To create a certificate with **no wildcards**:

```
./create_certificate_for_domain.sh www.candre.dev www.candre.dev
```

#### Important:

Remember to import `rootCA.crt` into *Trusted Root Certification Authorities* of your browser. See [this link](https://support.securly.com/hc/en-us/articles/206081828-How-to-manually-install-the-Securly-SSL-certificate-in-Chrome) for details.