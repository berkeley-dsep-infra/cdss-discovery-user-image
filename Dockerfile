# https://github.com/jupyter/docker-stacks/blob/main/images/pytorch-notebook/Dockerfile
# Based on scipy-notebook, with torch from pip

# This is quay.io/jupyter/pytorch-notebook:cuda12-latest on 2025-02-19
ARG BASE_CONTAINER=quay.io/jupyter/pytorch-notebook@sha256:bd1f33cd587431aca9c8f351628da02c3ba888acb715a369cdd49943033ea505

FROM $BASE_CONTAINER as base

# These are used by the python, R, and final stages
ENV R_LIBS_USER=/srv/r

#RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER}

USER root
# Install all apt packages
COPY apt.txt /tmp/apt.txt
RUN apt-get -qq update --yes && \
    apt-get -qq install --yes --no-install-recommends \
        $(grep -v ^# /tmp/apt.txt) && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

# Install R.

# These apt packages must be installed into the base stage since they are in
# system paths rather than /srv.
#
# Pre-built R packages from Posit Package Manager are built against system libs
# in ubuntu.
#
# After updating R_VERSION and rstudio-server, update Rprofile.site too.
#ENV R_VERSION=4.4.2-1.2204.0
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" > /etc/apt/sources.list.d/cran.list
RUN curl --silent --location --fail https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc > /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN apt-get update --yes > /dev/null && \
    apt-get install --yes r-base-core r-base-dev

# RStudio Server and Quarto
ENV RSTUDIO_URL=https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.12.0-467-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    apt install --no-install-recommends --yes /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

# For command-line access to quarto, which is installed by rstudio.
RUN ln -s /usr/lib/rstudio-server/bin/quarto/bin/quarto /usr/local/bin/quarto

# Shiny Server
ENV SHINY_SERVER_URL https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb
RUN curl --silent --location --fail ${SHINY_SERVER_URL} > /tmp/shiny-server.deb && \
    apt install --no-install-recommends --yes /tmp/shiny-server.deb && \
    rm /tmp/shiny-server.deb

# Install our custom Rprofile.site file
COPY Rprofile.site /usr/lib/R/etc/Rprofile.site
# Create directory for additional R/RStudio setup code
RUN mkdir /etc/R/Rprofile.site.d
# RStudio needs its own config
COPY rsession.conf /etc/rstudio/rsession.conf

# R_LIBS_USER is set by default in /etc/R/Renviron, which RStudio loads.
# We uncomment the default, and set what we wanna - so it picks up
# the packages we install. Without this, RStudio doesn't see the packages
# that R does.
# Stolen from https://github.com/jupyterhub/repo2docker/blob/6a07a48b2df48168685bb0f993d2a12bd86e23bf/repo2docker/buildpacks/r.py
# To try fight https://community.rstudio.com/t/timedatectl-had-status-1/72060,
# which shows up sometimes when trying to install packages that want the TZ
# timedatectl expects systemd running, which isn't true in our containers
RUN sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
    echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron && \
    echo "TZ=${TZ}" >> /etc/R/Renviron

# =============================================================================

# Create user owned R libs dir
# This lets users temporarily install packages
RUN install -d -o ${NB_USER} ${R_LIBS_USER}

# Install R libraries as our user
USER ${NB_USER}

# Install R packages
COPY install.R /tmp/
RUN /usr/bin/Rscript /tmp/install.R

# =============================================================================

# Install conda environment as our user
USER ${NB_USER}

# Install Conda packages
COPY environment.yml /tmp/environment.yml

RUN mamba env update -f /tmp/environment.yml -y && \
    mamba clean -afy

# https://github.com/berkeley-dsep-infra/datahub/issues/5827
ENV VSCODE_EXTENSIONS=${CONDA_DIR}/share/code-server/extensions
RUN mkdir -p ${VSCODE_EXTENSIONS}

# Install Code Server Jupyter extension
RUN ${CONDA_DIR}/bin/code-server --extensions-dir ${VSCODE_EXTENSIONS} --install-extension ms-toolsai.jupyter
# Install Code Server Python extension
RUN ${CONDA_DIR}/bin/code-server --extensions-dir ${VSCODE_EXTENSIONS} --install-extension ms-python.python

# =============================================================================

# clear out /tmp
USER root
RUN rm -rf /tmp/*

USER ${NB_USER}
WORKDIR ${HOME}
