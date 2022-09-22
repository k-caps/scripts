#!/bin/bash
# python_home/
#   venvs/
#     venv1/
#	  venv2/
#   projects/
#     project1/
#       project1.py  

# a python project directory contains source code files, and a correspondingly named venv is in the venvs folder.
help_function () {
	echo "venvmgr allows you to easily manage your virtual environments with no extra dependencies."
	echo "venvmgr creates a project directory containing a blank python file and a corresponding virtual environment."
	echo "To use venvmgr, just source the script with a desired venv name. If it exists it will be activated, and if not it will be created and then activated."
	echo "All venvs and project files will be created in a given \"python home\"."
	echo "The default python home is ~/python_home, and the default python version is 3."
	echo "To visualize the layout venvmgr uses, run \`head -n 10 venvmgr.sh\`."
	echo
	echo "USAGE:"
	echo " source venvmgr.sh [options] PROJECT_NAME" 
	echo "OR (if -I has been used)"
	echo " venvmgr [options] PROJECT_NAME"
	echo
	echo "OPTIONS:"
	echo " -h		Directory to use as python_home"
	echo " -v		Which python version to use [2|3]"
	echo " -C		Clean up a given project and its venv. Can be used with -h to remove from a certain python home only"
	echo " -I		Install this script to /opt/venvmgr and add it to this and future shells"
	echo " -H		Print this help and exit"
	echo
	echo "venvmgr by Kobi Caps 2022"
	echo
}

install_function () {
	[[ -f /opt/venvmgr.sh ]] && echo "Removing previous version of venvmgr" && sudo rm /opt/venvmgr.sh
	[[ -f ~/.bashrc ]] && printf "venvmgr () { source /opt/venvmgr.sh \"\$@\" }\n" >> ~/.bashrc
	[[ -f ~/.zshrc ]] && printf "venvmgr () { source /opt/venvmgr.sh \"\$@\" }\n" >> ~/.zshrc
	venvmgr () { source /opt/venvmgr.sh "$@" }
	echo "sudo is needed to copy venvmgr to /opt"
	SCRIPTPATH="$( cd -- "$(dirname "$SCRIPTNAME	")" >/dev/null 2>&1 ; pwd -P )"
	sudo cp $SCRIPTPATH/venvmgr.sh /opt/venvmgr.sh
	sudo chmod +x /opt/venvmgr.sh
	[[ -f /opt/venvmgr.sh ]] && echo "Installed successfully."
}

if [[ -z $1 ]]; then
	printf "At least a venv name must be supplied. Try running something like:\nsource venvmgr.sh pelican\nor\nvenvmgr.sh -H to view help.\n"
	return  
fi	


PYROJECT="${@[-1]}"
PYHOME="$HOME/Dev/python_home"
PYVERSION=3
CLEAN=""

if [[ $# -gt 5 ]]; then
	printf "Too many or incorrect arguments.\nRun \" venvmgr.sh -H \" to view help.\n"
	return
fi

OPTIND=0
while getopts "ICHv:h:" arg; do
	case "${arg}" in
		v) PYVERSION="${OPTARG}";;
		h) PYHOME="${OPTARG}";;
		C) CLEAN="true";;
		H) help_function; return;;
		I) install_function; return;;
    esac
done

if [[ $CLEAN == "true" ]]; then
	printf "The CLEAN (-C) argument was given, removing all files for project $PYROJECT in the python home $PYHOME.\n"
	rm -rf $PYHOME/{venvs,projects}/$PYROJECT
	return
fi

if [[ ! -d "$PYHOME/venvs/$PYROJECT" ]]; then 
	printf "The project "$PYROJECT" does not exist in the python home \"$PYHOME\".\nCreating Virtual environment in:\n$PYHOME/venvs.\n"
	mkdir -p $PYHOME/{projects,venvs}
	cd $PYHOME/venvs/
	python$PYVERSION -m venv $PYROJECT
	if [[ ! -d $PYHOME/venvs/$PYROJECT ]]; then
		printf "There was a problem creating the virtual environment.\n"
	fi
	printf "Creating project dir in:\n$PYHOME/projects/$PYROJECT.\n"
	mkdir $PYHOME/projects/$PYROJECT
	if [[ ! -d $PYHOME/projects/$PYROJECT ]]; then
		printf "There was a problem creating the project directory.\n"
	fi
	printf "Generating blank source code file:\n$PYHOME/projects/$PYROJECT/$PYROJECT.py\n"
	cat >> $PYHOME/projects/$PYROJECT/$PYROJECT.py << EOF
#!$PYHOME/venvs/$PYROJECT/bin/python$PYVERSION

EOF
fi
cd $PYHOME/projects/$PYROJECT
source $PYHOME/venvs/$PYROJECT/bin/activate
