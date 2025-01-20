#! /bin/sh
  set -e
  source ./loadLSST.bash
  mamba clean -a -y
  for prod in $EUPS_PRODUCTS; do
    eups distrib install --no-server-tags -vvv "$prod" -t "$EUPS_TAG"
  done
  find "$EUPS_PATH" -exec strip --strip-unneeded --preserve-dates {} + > /dev/null 2>&1 || true
  find "$EUPS_PATH" -maxdepth 5 -name tests -type d -exec rm -rf {} + > /dev/null 2>&1 || true
  find "$EUPS_PATH" -maxdepth 6 \( -path "*doc/html" -o -path "*doc/xml" \) -type d -exec rm -rf {} + > /dev/null 2>&1 || true
  find "$EUPS_PATH" -maxdepth 5 -name src -type d -exec rm -rf {} + > /dev/null 2>&1 || true
