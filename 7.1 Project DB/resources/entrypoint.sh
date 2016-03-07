#!/bin/bash
set -e
if [ -z "$i2b2_project_config" ]; then
  # no config defined
  echo "Please define project configuration: "
  echo "Environment variable 'i2b2_project_config'"
  exit 1
else
  echo "Project Config defined: "
  echo $i2b2_project_config

  if [ ! -f $i2b2_project_config ]; then
    # only file in default folder defined?
    i2b2_project_config=/docker-entrypoint-initdb.d/Config/${i2b2_project_config}

    if [ ! -f $i2b2_project_config ]; then
      echo "Config file not found!"
      exit 1
    fi
  fi

  echo "configuration: "
  cat $i2b2_project_config
  echo "-----------------------------------------------------------------------"

  gosu postgres pg_ctl start -w

  for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *.sql) echo "$0: running $f"; psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f" && echo ;;
      *)     echo "$0: ignoring $f" ;;
    esac
    echo
  done

  gosu postgres pg_ctl stop -w;


fi
