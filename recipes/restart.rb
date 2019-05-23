bash 'restart-glassfish' do
    user "root"
    code <<-EOF
       systemctl restart glassfish-domain1
    EOF
end


