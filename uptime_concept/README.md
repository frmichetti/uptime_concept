# Kuadro Uptime Concept 

### Micro sinatra application that pings the Kuadro Instances to provide data for Metabase

For each register in config/instances.yml create a ping cron job.

### Don't forget 
* sudo apt-get install libpq-dev
* sudo yum install libpq-dev

## Configure the database
    config/database.conf.yml 

## You can set up an e-mail account to warn you of unavailability.
    config/email.config.yml

## Run with    
    rackup config.ru