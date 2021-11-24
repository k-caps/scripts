### Use this to run long and complex commands in the background, while preserving stdout and stderr to a log file

`nohup bash -c 'time long_running_command > logfile.log 2> &1' >> logfile.log 2>&1 &`
