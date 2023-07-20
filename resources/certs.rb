actions :generate_int_certs, :import_certs, :download_azure_ca_cert

attribute :subject, :kind_of => String

attribute :skip_secure_admin, :kind_of => [TrueClass, FalseClass], :default => false