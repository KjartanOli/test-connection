# Copyright (C) 2020  <name of copyright holder>
# Author: Ágústsson, Kjartan Óli <kjartanoli@protonmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#! /usr/bin/bash

# Test a connection to a remote device using ping.

declare -r RELEASE_NUM="1"
declare -r FEATURE_NUM="4"
declare -r HOTFIX_NUM="6"

declare -r VERSION="$RELEASE_NUM.$FEATURE_NUM.$HOTFIX_NUM"
declare -r AUTHOR="Kjartan Óli Ágústsson"

verbosity=1

help()
{
	cat <<- _EOF_
		Usage: tc [OPTION] DESTINATION
		Ping an IP address or Domain name DESTINATION once to test if it can be reached.
		Example: tc 8.8.8.8

		Options:
		  -V, --version		Print version number and exit
		  -h, --help		Display this help and exit
		  -s, --silent		Supress all output (Usefull in scripts)
		  -v, --verbose		Print the output of the ping attempt
	_EOF_
}

version()
{
	cat <<- _EOF_
		tc (Test Connection) $VERSION

		Written by $AUTHOR
	_EOF_
}

acrgc=0
for option in $@
do
	# Increment argc and assign to a garbage variable to avoid Command not found errors.
	t=$((acrgc++))
	case "$option" in
		-v | --verbose)
			if [[ $acrgc -eq $# ]]
			then
				help >&2
				exit 1
			fi
			verbosity=2
			;;
		-s | --silent)
			if [[ $acrgc -eq $# ]]
			then
				help >&2
				exit 1
			fi
			verbosity=0
			;;
		-h | --help) help; exit 0;;
		-V | --version)
			version
			exit 0;;
		*)
			# Check if this is the last option
			if [[ $acrgc -eq $# ]]
			then
				# Assume the option is the DESTINATION and attempt to ping it.
				break
			else
				# Unrecognized option, print help and exit with error.
				help >&2
				exit 1
			fi
			;;
	esac
done
ip=$option

case "$verbosity" in
	# Silent
	0)
		if ping -c 1 $ip > /dev/null 2> /dev/null
		then
			exit 0
		else
			exit 1
		fi
		;;
	# Normal
	1)
		echo "Testing connection to $ip"
		ping -c 1 $ip > /dev/null 2> /dev/null
		res=$?
		if [[ res -eq 0 ]]
		then
			echo "Test successfull"
			exit 0
		else
			echo "Test failed"
			exit 1
		fi
		;;
	# Verbose
	2)
		echo "Testing connection to $ip"
		ping -c 1 $ip
		res=$?
		if [[ res -eq 0 ]]
		then
			echo "Test successfull"
			exit 0
		else
			echo "Test failed"
			exit 1
		fi
		;;
esac
