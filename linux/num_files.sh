ll | wc -l



if [ -z “$2” ]; then 
 if [ -z “$1” ]; then 
 echo `ls -l $1 | wc -l` files in `pwd` “(current directory)”
 else 
 echo `ls -l $1 | wc -l` files in $1
 fi
else
 if [ -z “$1” ]; then 
 echo `ls -la $1 | wc -l` files in `pwd` “(current directory)”
 else 
 echo `ls -la $1 | wc -l` files in $1
 fi
fi

#Create an alias to the script and use as follows

#To count all files in the current directory:
nf

#To count all files including hidden in the current directory:
#(You can use anything instead of a, as long as there is a second parameter it will show hidden files as well)
nf ’’a

#To count all files in a given path:
nf /some/path

#To count all files including hidden in a given path:
nf /some/path a
