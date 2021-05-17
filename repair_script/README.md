# Repair Script

**Repair Script** (`repair_script.sh`) is a tool that allows you to easily manage your Cassandra repairs.



## Requirements
The tool works on all Cassandra versions 2.0 and laters.


## Command Line Parameters

    $ bash repair_script.sh [-k keyspace] [-t table ] [-e end_token] [-s start_token]

     Options: 
     |   -k, keyspace     (keyspace where to run the repair)
     |   -t, table 	     (table where to run the repair)
     |   -e, end_token   (token where to finish the repair)
     |   -s, start_token (token where to start the repair)


> **Note**:  All the arguments are optional but if you specify the table, you need to specify also the keyspace. The start token and the end token also need to be always specified or not together.

## Basic Usage
**Repair Script** is run through a command-line interface, so all of the command options are made available there.


Run the repair script on the whole node:

    $ bash repair_script.sh


Run the repair script on the keyspace `my_keyspace`:

    $ bash repair_script.sh -k my_keyspace 


Run the repair script on the keyspace `my_keyspace` and the table `my_table`:

    $ bash repair_script.sh -k my_keyspace -t my_table


Run the repair script on the keyspace `my_keyspace` and the table `my_table` starting from token `-9201120367580102230` and ending on the token `-9195172846812010407`:

    $ bash repair_script.sh -k my_keyspace -t my_table -s -9201120367580102230 -e -9195172846812010407


Run the repair script starting from token `-9201120367580102230` and ending on the token `-9195172846812010407`:

    $ bash repair_script.sh -s -9201120367580102230 -e -9195172846812010407


