#!/bin/bash

# Copyright Brian Warner
#
# SPDX-License-Identifier: MIT
#
# This is a script to log in and manage your Minecraft server using rcon. Note
# that you need to have mcrcon installed and configured.
#
# mcrcon: https://github.com/Tiiffi/mcrcon
#
# Copy this script into your server directory (e.g., /opt/minecraft/server/) and
# run it:
#   $ ./manage.sh
#
# Instructions: # https://github.com/brianwarner/minecraft-server-hosting
#

mcrcon -P `cat server.properties | grep rcon.port | sed 's/.*=//'` \
	-p `cat server.properties | grep rcon.password | sed 's/.*=//'` \
	-H `cat server.properties | grep server-ip | sed 's/.*=//'` \
	-t

