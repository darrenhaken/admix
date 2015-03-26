# stop current cron in the system
system 'crontab -r'

# update cron
system 'whenever --update-crontab'

system 'crontab -l'
