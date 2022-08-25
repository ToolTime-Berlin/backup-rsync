# Rsync based backup
Simple and non-incremental backups using rsync.

## Usage
Make sure you fulfill all the requirements:
* Should run on any system with a **GNU bash**.
* Run script preferably as **root** as you store a lot of secrets in `.env`.
* The user which is running the backup script needs to have access to the backup storage via a **ssh key** at least for `rsync` in order to run this script e.g. as a cron job.

Either clone this repo or download its content to the server that you want to backup files off, e.g. to `/opt/backup-rsync`.
Choose the jobs you want to run by enabling them. For that you need to symlink an available job from `./jobs/available/[jobname].sh` to `./jobs/enabled/[jobname].sh`.

### Optional
Register cron jobs. Some examples are provided in `etc/cron.{daily,weekly}`. Adapt these and copy them to `/etc/cron.{daily,weekly}/`.
Configure `logrotate` for the logfile set in `.env`. See example in `etc/logrotate.d`.

### Example
`/opt/backup-rsync/backup.sh --daily` would run a backup and storing backup files on the target volume using `daily/Thursday` as the subfolder. This would result in a backup that is at most 7 days old since this script uses the rsync `--delete` flag. Other options would be `--hourly`, `--weekly`, `--monthly`, or `--custom` which would give you the option to define your own subfolder pattern.

See `./backup.sh --help` for more.
