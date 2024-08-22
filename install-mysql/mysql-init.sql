-- Change root password and authentication method
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '${MYSQL_ROOT_PASSWORD}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Drop test database
DROP DATABASE IF EXISTS test;

-- Restrict root access to localhost
UPDATE mysql.user SET Host='localhost' WHERE User='root' AND Host='%';

-- Apply changes
FLUSH PRIVILEGES;