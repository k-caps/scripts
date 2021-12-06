add_quote_to_var() {
    echo $1 | sed 's/^/"/g ; s/$/"/g'
}

# var=1
# echo $var
# 1
# add_quote_to_var $var
# "1"
