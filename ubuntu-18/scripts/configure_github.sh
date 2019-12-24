cat > /root/.ssh/id_rsa <<- EOM
-----BEGIN RSA PRIVATE KEY-----
private key content
-----END RSA PRIVATE KEY-----
EOM
chmod 400 /root/.ssh/id_rsa

#uncomment below line to configure ansible_vault
#echo 'W%,cpJ7V' > /root/.ansible_vault
