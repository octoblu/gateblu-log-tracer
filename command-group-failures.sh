#!/bin/bash

gateblu-log-tracer list-failures | awk '{print $3}' | xargs -n 1 gateblu-log-tracer trace | grep gatebluUUID | awk '{print $2}' | sort -u | xargs -n 1 gateblu-log-tracer gateblu-activity
