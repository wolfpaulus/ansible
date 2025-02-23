Currently the 'root' account cannot login from a reote host :-(
TO fix this I had to connent to the docker container and run this:

bash-5.1# mysql -p
Enter password: 

Welcome to the MySQL monitor....

mysql> CREATE USER 'root'@'%' IDENTIFIED BY '... root password  ...'; 
Query OK, 0 rows affected (0.05 sec)

mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
Query OK, 0 rows affected (0.03 sec)


Obviously, this needs to be put into a playbook eventually.
Anyway, after running those two commands, I was able to use the root login from remote,
to create new users, databases, etc.
