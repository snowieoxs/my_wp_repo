-- Enable the validate_password plugin
INSTALL PLUGIN validate_password SONAME 'validate_password.so';

-- Set the password validation policy to STRONG
SET GLOBAL validate_password.policy = 2;

-- Change the root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Disallow root login remotely
UPDATE mysql.user SET Host='localhost' WHERE User='root' AND Host='%';

-- Remove the test database
DROP DATABASE IF EXISTS test;

-- Remove privileges on the test database
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Reload the privilege tables
FLUSH PRIVILEGES;