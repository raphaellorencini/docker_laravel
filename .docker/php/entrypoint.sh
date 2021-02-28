#!/bin/bash

# Supervisor
service rsyslog start
/usr/bin/supervisord -n -c /etc/supervisord.conf