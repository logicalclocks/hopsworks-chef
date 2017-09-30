if node['glassfish']['port'] == 80


    case node['platform_family']
    when "redhat"
      bash "authbind-centos" do
        user "root"
        code <<-EOF
         cd /tmp
         wget http://ftp.debian.org/debian/pool/main/a/authbind/authbind_2.1.1.tar.gz
         tar zxf http://ftp.debian.org/debian/pool/main/a/authbind/authbind_2.1.1.tar.gz
         cd authbind-2.1.1
         make
         make install
         ln -s /usr/local/bin/authbind /usr/bin/authbind
         mkdir -p /etc/authbind/byport
         touch /etc/authbind/byport/80
         chmod 550 /etc/authbind/byport/80
         perl -pi -e 's/8080/80/g' #{node['glassfish']['domains_dir']}/domain1/config/domain.xml
     EOF
      end
      
    end
      bash "authbind-common" do
        user "root"
        code <<-EOF
         perl -pi -e 's/8181/443/g' #{node['glassfish']['domains_dir']}/domain1/config/domain.xml
         touch /etc/authbind/byport/443
         chown #{node['glassfish']['user']} /etc/authbind/byport/443
         chmod 550 /etc/authbind/byport/443
   EOF
      end

end
