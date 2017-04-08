### Backup Scripts
`start-backup.sh` is to start up a container that does the on-demand snapshots. This snapshots user containers that have been up and running for at least 30 minutes, every 30 minutes. Pruning occurs every 5 hours.

`start-backup-fs.sh` is to start up a container that backups the entire file server every day at 5:00AM PST. Pruning occurs every week.

`start-backup-dev.sh` is to start up a development container for the backup system. This is usually unstable and used for testing purposes on a development server.
