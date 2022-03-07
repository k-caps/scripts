qecho() {
    echo $1 | sed 's/^/"/g ; s/$/"/g'
}

# var=1
# echo $var
# 1
# qecho $var
# "1"
