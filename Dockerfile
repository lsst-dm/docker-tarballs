FROM lsstsqre/centos:7-stackbase
MAINTAINER sqre-admin

ENV LSST_PYTHON_VERSION=3
ENV EUPS_PKGROOT=https://eups.lsst.codes/stack/redhat/el7/gcc-system/miniconda3-4.2.12-7c8e67
ENV NEW_DIR=/opt/lsst/software/stack
ENV LSST_USER=lsst
ENV PRODUCT=lsst_distrib
ARG TAG

USER root

RUN mkdir -p $NEW_DIR
RUN groupadd $LSST_USER
RUN useradd -g $LSST_USER -m $LSST_USER
RUN chown $LSST_USER:$LSST_USER $NEW_DIR

USER $LSST_USER
WORKDIR $NEW_DIR

RUN curl -sSL https://raw.githubusercontent.com/lsst/lsst/master/scripts/newinstall.sh | bash -s -- -cbt

RUN source ./loadLSST.bash; eups distrib install -vvv $PRODUCT -t $TAG \
  && ( find stack | xargs strip --strip-unneeded --preserve-dates \
       > /dev/null 2>&1 || true ) \
  && ( find stack -maxdepth 5 -name tests -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true ) \
  && ( find stack -maxdepth 5 -name doc -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true ) \
  && ( find stack/ -maxdepth 5 -name src -type d -exec rm -rf {} \; \
       > /dev/null 2>&1 || true )

RUN source ./loadLSST.bash; curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/master/shebangtron | python
