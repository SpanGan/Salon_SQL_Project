#!/bin/bash
sudo pg_ctlcluster 12 main start
sudo service postgresql start
psql -U postgres < salon.sql 