# Version 1.0
#!/bin/bash

# 1. Inject Rewrite Rules into the WordPress Container
cat << 'EOF' | docker exec -i wp-multisite-wordpress-1 bash -c 'cat > /var/www/html/.htaccess'
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]

# add a trailing slash to /wp-admin
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ $1wp-admin/ [R=301,L]

RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) $2 [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ $2 [L]
RewriteRule . index.php [L]
EOF

# 2. Extract, Patch, and Replace Database Configuration
docker cp wp-multisite-wordpress-1:/var/www/html/wp-config.php ./wp-config.tmp

sed -i '/stop editing/i define( "MULTISITE", true );\ndefine( "SUBDOMAIN_INSTALL", false );\ndefine( "DOMAIN_CURRENT_SITE", "localhost:8000" );\ndefine( "PATH_CURRENT_SITE", "/" );\ndefine( "SITE_ID_CURRENT_SITE", 1 );\ndefine( "BLOG_ID_CURRENT_SITE", 1 );' ./wp-config.tmp

docker cp ./wp-config.tmp wp-multisite-wordpress-1:/var/www/html/wp-config.php

# 3. Purge Local Temporary Files
rm ./wp-config.tmp

echo "Multisite Matrix Patched Successfully."