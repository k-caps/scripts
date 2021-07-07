#!/bin/bash

# Ensures newest version of git code while allowing for flexibilitiy during development.
# Should be called as a job reference step to manage scm for other jobs.

# I use this job to manage Ansible which I run with rundeck.

# Rundeck Job Options:
#------------------
# repo_url "Paste link to your git repo including .git"
# branch
# path  "The local **RELATIVE** path to clone to. You can just call it the same thing as your git repo."
# ansible_roles "This should be set to 'True' if your repo is an Ansible playbooks directory and you want to import roles from a requirements.yml"
# clean "If set to True, this job will rm -rf the path specified in $RD_OPTION_PATH, and then clone it again freshly."
# prod "Provides some basic organization - it will simply put $RD_OPTION_PATH inside $GIT_BASE/prod or $GIT_BASE/dev depending on your choice."
# gtoken  "Git access token with pull access to the repo you are trying to clone. This will OVERWRITE any git saved credentials, and will never be changed unless you manually run this job again or edit files on your Rundeck remote node"
# run "Specifies whether or not this job should actually run. Useful if the job that is calling this one is stable and you don't want to always pull new code from git at every run."
#-------------------

if [@option.run == 'True' ]
then 
    BASEDIR=/home/clouduser/rundeck/git_base/dev
    USERDIR=@option.path@
    GIT_URL=@option.repo_url@
    GIT_TOKEN=@option.gtoken@
    GIT_HOSTNAME=$(echo $GIT_URL | awk  -F '/' '{print $3}')
    GIT_STATUS=$(curl -Is $GIT_URL | awk 'NR==1{print $2}')

    if [[ $GIT_STATUS == '200' ]] # So that we don't reach a situation where we clean and then can't clone
    then   
        if [@option.prod@ == 'True' ]; then
            export BASEDIR='/home/clouduser/rundeck/git_base/dev'
        fi
    
        WHOLEDIR=$BASEDIR/$USERDIR

        if [[  @option.clean@ == 'True' ]]; then
            sudo rm -rf $WHOLEDIR
        fi

        if [[ -n $GIT_TOKEN ]]; then 
            git config --global credential.helper store
            echo http://rundeck:$GIT_TOKEN@GIT_HOSTNAME > ~/.git-credentials       
        fi

        if [[ ! -d $WHOLEDIR ]]; then
            mkdir -p $WHOLEDIR
            cd $WHOLEDIR
            git clone -q $GIT_URL .

            # Delete the empty directory if the clone failed for any reason (for the IF at line 46, at subsequent runs)
            if [[ -z `ls $WHOLEDIR` ]]; then
                rmdir $WHOLEDIR
            fi
        fi

        cd $WHOLEDIR
        git checkout @option.branch@
        git reset --hard
        git pull -f $GIT_URL @option.branch@
        RC=$?

        if [ @option.ansible_roles@ == 'True' ]; then
            ansible-galaxy -r $WHOLEDIR/roles/requirements.yml install -f
        fi

        exit $RC # Forces Rundeck to fail if after git pull we don't actually have the desired code
    else
        echo "Git is unavaialbe, exiting"
        exit 1
    fi
else
    echo You chose to skip git import
fi