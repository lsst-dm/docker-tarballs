ARG BASE_IMAGE=lsstsqre/newinstall:latest
FROM $BASE_IMAGE

ARG DOCKERFILE_GIT_BRANCH
ARG DOCKERFILE_GIT_COMMIT
ARG DOCKERFILE_GIT_URL
ARG EUPS_TAG
ARG JENKINS_BUILD_ID
ARG JENKINS_BUILD_URL
ARG JENKINS_JOB_NAME
ARG LSST_COMPILER
ARG LSST_SPLENV_REF
ARG VERSIONDB_MANIFEST_ID

ARG EUPS_PRODUCTS=lsst_distrib
ARG LSST_PYTHON_VERSION=3
ARG LSST_USER=lsst
ARG NEW_DIR=/opt/lsst/software/stack
ARG SHEBANGTRON_URL=https://raw.githubusercontent.com/lsst/shebangtron/master/shebangtron

LABEL EUPS_PRODUCTS=$EUPS_PRODUCTS \
    EUPS_TAG=$EUPS_TAG \
    DOCKERFILE_GIT_BRANCH=$DOCKERFILE_GIT_BRANCH \
    DOCKERFILE_GIT_COMMIT=$DOCKERFILE_GIT_COMMIT \
    DOCKERFILE_GIT_URL=$DOCKERFILE_GIT_URL \
    JENKINS_JOB_NAME=$JENKINS_JOB_NAME \
    JENKINS_BUILD_ID=$JENKINS_BUILD_ID \
    JENKINS_BUILD_URL=$JENKINS_BUILD_URL \
    VERSIONDB_MANIFEST_ID=$VERSIONDB_MANIFEST_ID \
    LSST_COMPILER=$LSST_COMPILER \
    LSST_SPLENV_REF=$LSST_SPLENV_REF

SHELL ["/bin/bash", "-o", "pipefail", "-lc"]

RUN <<EOF
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
EOF

RUN source ./loadLSST.bash; curl -sSL "$SHEBANGTRON_URL" | python

SHELL ["/bin/bash", "-lc"]
