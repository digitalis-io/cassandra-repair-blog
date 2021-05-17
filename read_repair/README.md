# Read Repair

**Read Repair** (`read_repair.py`) is a tool that allows you to read an entire table with pagination to repair the data using read-repair.



## Requirements
The tool works on all Cassandra versions 2.0 and laters.


## Command Line Parameters

    $ python2 read_repair.py user password host keyspace table /path/to/cert.crt

     Options: 
     |   user                  (user used connect to Cassandra)
     |   password              (password used connect to Cassandra)
     |   host                  (host to connect)
     |   keyspace              (keyspace where to run the script for read-repair)
     |   table                 (table where to run the script for read-repair)
     |   /path/to/cert.crt     (optional - public cert used connect to Cassandra)



> **Note**:  the cert is necessary only if the connection uses ssl.

## Basic Usage
**Read Repair** is run through a command-line interface, so all of the command options are made available there.


Run the Read Repair script on the keyspace `keyspace` and table `table`, using the `user` and `password` for authentification, connecting to `host`:

    $ python2 read_repair.py user password host keyspace table


Run the Read Repair script on the keyspace `keyspace` and table `table`, using the `user` and `password` for authentification, connecting to `host` using the certificate `/path/to/cert.crt`:

    $ python2 read_repair.py user password host keyspace table /path/to/cert.crt

