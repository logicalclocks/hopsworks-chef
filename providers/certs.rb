use_inline_resources

notifying_action :generate do

bash 'certificateauthority' do
    user "root"
    code <<-EOF
        set -eo pipefail

	KEYSTOREPW=#{node.hopsworks.master.password}

	cd "#{node.glassfish.domains_dir}/domain1/config/ca"
        BASEDIR="#{node.glassfish.domains_dir}/domain1/config/ca"
	chmod 700 private
	touch index.txt
	echo 1000 > serial

	#2 Create the root key
	[ -f private/ca.key.pem ] || openssl genrsa -aes256 -out private/ca.key.pem -passout pass:${KEYSTOREPW} 4096

	chmod 400 private/ca.key.pem

	#3 Create the root certificate
	[ -f certs/ca.cert.pem ] || openssl req -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsRootCA" -passin pass:${KEYSTOREPW} -passout pass:${KEYSTOREPW} -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem 

	chmod 444 certs/ca.cert.pem

	#4 Prepare the intermediate directories
	chmod 700 intermediate/private/
	touch intermediate/index.txt
	echo 1000 > intermediate/serial
	echo 1000 > intermediate/crlnumber

	#5 Create the intermediate key
	[ -f intermediate/private/intermediate.key.pem ] || openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem -passout pass:${KEYSTOREPW} 4096 

	chown #{node.glassfish.user}:#{node.glassfish.group} intermediate/private/intermediate.key.pem
	chmod 440 intermediate/private/intermediate.key.pem

	#6 Create the intermediate certificate 
	[ -f intermediate/csr/intermediate.csr.pem ] || openssl req -new -sha256 -subj "/C=SE/ST=Sweden/L=Stockholm/O=SICS/CN=HopsIntermedtiateCA" \
      -key intermediate/private/intermediate.key.pem -passin pass:${KEYSTOREPW} -passout pass:${KEYSTOREPW} -out intermediate/csr/intermediate.csr.pem

	[ -f intermediate/certs/intermediate.cert.pem ] || openssl ca -batch -config openssl-ca.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 -passin pass:${KEYSTOREPW} -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem 

	chmod 444 intermediate/certs/intermediate.cert.pem

	#7 Verify the intermediate certificate
	openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem

	#8 Create the certificate chain file
	cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

	chmod 444 intermediate/certs/ca-chain.cert.pem
        
        #9 Make the subject non-unique. Otherwise, running /var/lib/kagent-certs/csr.py becomes non idempotent
        # http://www.mad-hacking.net/documentation/linux/security/ssl-tls/signing-csr.xml
        echo "unique_subject = no \n" > intermediate/index.txt.attr
    EOF
 not_if { ::File.exists?("#{node.glassfish.domains_dir}/domain1/config/ca/intermediate/certs/ca-chain.cert.pem" ) }
end

end
