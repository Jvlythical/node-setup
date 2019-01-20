 # Make sure you are in the drives folder
 ls -la -d $PWD/*/*  | grep root | awk '{print $9}' | xargs sudo chown www-data:www-data
