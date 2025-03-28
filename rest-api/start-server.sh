#!/bin/bash

hhvm -m server -c config.ini -p 9999 -d "hhvm.server.source_root=$(pwd)/public"
