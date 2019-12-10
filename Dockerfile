FROM ubuntu:18.04

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="RStable" \
      org.label-schema.description="A docker image with stable versions of R and a bunch of package. The full list of packages is available in the README." \
      org.label-schema.license="MIT" \
      org.label-schema.url="e.g. https://www.inbo.be/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/inbo/RLaTeX" \
      org.label-schema.vendor="Research Institute for Nature and Forest" \
      maintainer="Thierry Onkelinx <thierry.onkelinx@inbo.be>"

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true


## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker \
  && addgroup docker staff

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN apt-get update \
  && apt-get install -y  --no-install-recommends \
    locales \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

## Add apt-get repositories
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
  && sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list' \
  && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
  && gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add -

## Install R base
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    r-base-core=3.6.1-3bionic \
    r-base-dev=3.6.1-3bionic \
    r-cran-boot=1.3-23-2bionic0 \
    r-cran-class=7.3-15-1bionic0 \
    r-cran-cluster=2.1.0-2bionic0 \
    r-cran-codetools=0.2-16-1bionic0 \
    r-cran-foreign=0.8.72-1bionic0 \
    r-cran-kernsmooth=2.23-16-1+1bionic0 \
    r-cran-lattice=0.20-38-1cran1bionic0 \
    r-cran-mass=7.3-51.4-2bionic0 \
    r-cran-matrix=1.2-18-1bionic0 \
    r-cran-mgcv=1.8-31-1cran1bionic0 \
    r-cran-nlme=3.1.142-1bionic0 \
    r-cran-nnet=7.3-12-2cranArtful0~ubuntu18.04.1~ppa1 \
    r-cran-rpart=4.1-15-2bionic0 \
    r-cran-spatial=7.3-11-2cranArtful0~ubuntu18.04.1~ppa1 \
    r-cran-survival=2.44-1.1-2bionic0 \
    r-recommended=3.6.1-3bionic

## Install litter
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    littler=0.3.9-1bionic0

## Install wget
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget

## Use custom R profile
COPY Rprofile.site /usr/lib/R/etc/Rprofile.site

## script to install specific R package from CRAN
COPY cran_install.sh cran_install.sh

## Add minimal LaTeX configuration
## See https://yihui.name/tinytex
RUN ./cran_install.sh xfun 0.11 \
  && ./cran_install.sh tinytex 0.17 \
  && apt-get install -y --no-install-recommends \
    qpdf \
  && Rscript -e "tinytex::install_tinytex()" \
  && Rscript -e "tinytex::tlmgr_install(c('inconsolata', 'times', 'tex', 'helvetic', 'dvips'))"
ENV PATH="/root/bin:${PATH}"

## Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/2.8.1/pandoc-2.8.1-1-amd64.deb \
  && dpkg -i pandoc-2.8.1-1-amd64.deb\
  && rm pandoc-2.8.1-1-amd64.deb
