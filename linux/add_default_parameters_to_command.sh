# Add to bashrc
openstack() {
        if [[ $2 == "list" ]]; then
                command openstack "$@" --all-projects
        else
                command openstack "$@"
        fi
}

# The syntax is as follows:
git() {
        if [[ SOMEPARAM == "string" ]]; then
                command git "$@" --default-args
        else
                command command "$@"
        fi
}

