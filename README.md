# docker-supercronic

Docker container based on the `balenalib/intel-nuc-debian` container with `supercronic` (https://github.com/aptible/supercronic) and `tini` to run the container.
The comtainer runs as user `tini` and starts `supercronic` with a `crontab` config file in `opt/crontab`

 
