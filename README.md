# Uptime Concept 

### Micro sinatra application that pings a Server Instances to provide data for Metabase

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
    
## Create a service
  Move uptime_concept.service to /lib/systemd/system/uptime_concept.service
### Enable the service   
   * sudo systemctl enable uptime_concept.service
### If you have made changes to your service, you may need to reload the daemon        
   * sudo systemctl daemon-reload
### Start/Restart/Stop the service
   * sudo service uptime_concept.service start
   
# it works on my machine!   