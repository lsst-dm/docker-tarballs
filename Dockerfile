FROM docker.io/lsstsqre/centos:7-stackbase-devtoolset-6

ARG LSST_PYTHON_VERSION=3
ARG NEW_DIR=/opt/lsst/software/stack
ARG LSST_USER=lsst
ARG EUPS_PRODUCT=lsst_distrib
ARG EUPS_TAG

LABEL EUPS_PRODUCT=$EUPS_PRODUCT \
    EUPS_TAG=$EUPS_TAG \
    DOCKERFILE_GIT_BRANCH=$DOCKERFILE_GIT_BRANCH \
    DOCKERFILE_GIT_COMMIT=$DOCKERFILE_GIT_COMMIT \
    DOCKERFILE_GIT_URL=$DOCKERFILE_GIT_URL \
    JENKINS_JOB_NAME=$JENKINS_JOB_NAME \
    JENKINS_BUILD_ID=$JENKINS_BUILD_ID \
    JENKINS_BUILD_URL=$JENKINS_BUILD_URL

USER root

RUN mkdir -p $NEW_DIR
RUN groupadd $LSST_USER
RUN useradd -g $LSST_USER -m $LSST_USER
RUN chown $LSST_USER:$LSST_USER $NEW_DIR

USER $LSST_USER
WORKDIR $NEW_DIR

RUN curl -sSL https://raw.githubusercontent.com/lsst/lsst/master/scripts/newinstall.sh | bash -s -- -cbtS

RUN source ./loadLSST.bash; for prod in $EUPS_PRODUCT; do eups distrib install --no-server-tags -vvv $prod -t $EUPS_TAG; done \
  && ( find stack | xargs strip --strip-unneeded --preserve-dates \
       > /dev/null 2>&1 || true ) \
  && ( find stack -maxdepth 5 -name tests -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true ) \
  && ( find stack -maxdepth 5 -name doc -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true ) \
  && ( find stack/ -maxdepth 5 -name src -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true )

RUN source ./loadLSST.bash; curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/master/shebangtron | python
