# Useful for systems which might end up with a full disk. This way when the disk fills up you can delete the buffer and have some free space to work with.
dd if=/dev/zero of=~/size_bufffer count=1024 bs=1048576
