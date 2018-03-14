FROM ubuntu:16.04

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
  && apt-get install -y --no-install-recommends dirmngr \
  && apt-get clean \
  && sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list' \
  && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9 \
  && gpg -a --export E084DAB9 | apt-key add -

## Install R base
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    r-base-core=3.4.3-1xenial0 \
    r-base-dev=3.4.3-1xenial0 \
    r-cran-boot=1.3-20-1xenial0 \
    r-cran-class=7.3-14-2xenial0 \
    r-cran-cluster=2.0.6-2xenial0 \
    r-cran-codetools=0.2-15-1cran1xenial0 \
    r-cran-foreign=0.8.69-1xenial0 \
    r-cran-kernsmooth=2.23-15-3xenial0 \
    r-cran-lattice=0.20-35-1cran1xenial0 \
    r-cran-mass=7.3-47-1xenial0 \
    r-cran-matrix=1.2-11-1xenial0 \
    r-cran-mgcv=1.8-22-1cran1xenial0 \
    r-cran-nlme=3.1.131-3xenial0 \
    r-cran-nnet=7.3-12-2xenial0 \
    r-cran-rpart=4.1-11-1xenial0 \
    r-cran-spatial=7.3-11-1xenial0 \
    r-cran-survival=2.41-3-2xenial0 \
    r-recommended=3.4.3-1xenial0 \
  && apt-get clean

## Install wget
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget \
  && apt-get clean

## Use custom R profile
COPY Rprofile.site /usr/lib/R/etc/Rprofile.site

## script to install specific R package from CRAN
COPY cran_install.sh cran_install.sh

## Add minimal LaTeX configuration
## Taken from https://github.com/rocker-org/hadleyverse/blob/master/Dockerfile
RUN ./cran_install.sh tinytex 0.4 \
  && apt-get install -y --no-install-recommends \
    qpdf \
  && Rscript -e "tinytex::install_tinytex()" \
  && Rscript -e "tinytex::tlmgr_install(c('inconsolata', 'times', 'tex', 'helvetic', 'dvips'))"

## Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/2.0.4/pandoc-2.0.4-1-amd64.deb \
  && dpkg -i pandoc-2.0.4-1-amd64.deb\
  && rm pandoc-2.0.4-1-amd64.deb
