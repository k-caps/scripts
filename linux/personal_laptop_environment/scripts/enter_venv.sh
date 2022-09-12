#!/bin/bash
# Assumes the following directory structure:
# python_home/
#   venvs/
#     venv1/
#	  venv2/
#   projects/
#     project1/
#       project1.py  

# a python project directory contains source code files, and a correspondingly named venv is in the venvs folder.

if [[ -z $1 ]]; then
	printf "A venv name must be supplied. Try running something like:\nsource enter_venv.sh pelican\n"
	exit 
fi	

PYROJECT=$1
PYHOME="/data/data/com.termux/files/home/python_home"
PYVERSION=3
if [[ ! -d $PYHOME/venvs/$PYROJECT ]]; then 
	printf "The project "$PYROJECT" does not exist.\nCreating Virtual environment in:\n$PYHOME/venvs.\n"
	mkdir -p $PYHOME/venvs $PYHOME/projects
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

