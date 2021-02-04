#!/bin/bash

pgrep $1 | xargs kill -9
