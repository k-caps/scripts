# Don't spam thelog!! only write the line to log if the last line of the log isn't this same warning
[[."$ (tail -n 1 $log)" -r "set read-only job already running." ]] && \I
printf "$ (date +td sm-$H:$M) "> set read-only job already running.In"->> $log
