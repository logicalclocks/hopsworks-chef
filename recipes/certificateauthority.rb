package 'openssl'

bash 'create_authority' do
    user "root"
    code <<-EOF

    KEYSTOREPW=#{node.hopsworks.master.password}

	mkdir /root/ca /root/ca/intermediate
	cp caopenssl.cnf /root/ca/openssl.cnf
	cp intermediateopenssl.cnf /root/ca/intermediate/openssl.cnf

	cd /root/ca
	mkdir certs crl newcerts private
	chmod 700 private
	touch index.txt
	echo 1000 > serial

	#2 Create the root key
	cd /root/ca
	openssl genrsa -aes256 -out private/ca.key.pem -passout pass:node.hopsworks.master.password 4096

	chmod 400 private/ca.key.pem

	#3 Create the root certificate
	cd /root/ca
	openssl req -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsRootCA" \
	  -passin pass:$KEYSTOREPW -passout pass:$KEYSTOREPW \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

	chmod 444 certs/ca.cert.pem

	#4 Prepare the directories
	cd /root/ca/intermediate
	mkdir certs crl csr newcerts private
	chmod 700 private
	touch index.txt
	echo 1000 > serial
	echo 1000 > /root/ca/intermediate/crlnumber

	#5 Create the intermediate key
	cd /root/ca
	openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem -passout pass:$KEYSTOREPW 4096

	chmod 400 intermediate/private/intermediate.key.pem

	#6 Create the intermediate certificate 
	cd /root/ca
	openssl req -new -sha256 \
	  -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsIntermedtiateCA" \
      -key intermediate/private/intermediate.key.pem \
      -passin pass:$KEYSTOREPW -passout pass:$KEYSTOREPW \
      -out intermediate/csr/intermediate.csr.pem

	cd /root/ca
	openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -passin pass:$KEYSTOREPW \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

	chmod 444 intermediate/certs/intermediate.cert.pem

	#7 Verify the intermediate certificate
	openssl verify -CAfile certs/ca.cert.pem \
    	  intermediate/certs/intermediate.cert.pem

	#8 Create the certificate chain file
	cat intermediate/certs/intermediate.cert.pem \
    	  certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

	chmod 444 intermediate/certs/ca-chain.cert.pem
    EOF
 not_if { ::File.exists?( "/root/ca/private/ca.key.pem" ) }
end