FROM ubuntu:16.04

## This handle reaches Thierry
MAINTAINER "Thierry Onkelinx" thierry.onkelinx@inbo.be

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
RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list' \
  && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
  && gpg -a --export E084DAB9 | apt-key add -

## Install R base
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    r-base-core=3.3.2-1xenial0 \
    r-base-dev=3.3.2-1xenial0 \
    r-cran-boot=1.3-18-1cran1xenial0 \
    r-cran-class=7.3-14-1xenial0 \
    r-cran-cluster=2.0.5-1xenial0 \
    r-cran-codetools=0.2-15-1cran1xenial0 \
    r-cran-foreign=0.8.67-1xenial0 \
    r-cran-mass=7.3-45-1xenial0 \
    r-cran-kernsmooth=2.23-15-2xenial0 \
    r-cran-lattice=0.20-34-1xenial0 \
    r-cran-matrix=1.2-7.1-1xenial0 \
    r-cran-mgcv=1.8-15-1cran1xenial0 \
    r-cran-nnet=7.3-12-1xenial0 \
    r-cran-nlme=3.1.128-2xenial0 \
    r-cran-rpart=4.1-10-1 \
    r-cran-spatial=7.3-11-1xenial0 \
    r-cran-survival=2.39-4-2xenial0 \
    r-recommended=3.3.2-1xenial0 \
  && apt-get clean

## Install wget
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget \
  && apt-get clean

## Add minimal LaTeX configuration
## Taken from https://github.com/rocker-org/hadleyverse/blob/master/Dockerfile
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lmodern \
    qpdf \
    texlive-fonts-recommended \
    texlive-humanities \
    texlive-latex-extra \
    texinfo \
  && apt-get clean \
  && cd /usr/share/texlive/texmf-dist \
  && wget http://mirrors.ctan.org/install/fonts/inconsolata.tds.zip \
  && unzip inconsolata.tds.zip \
  && rm inconsolata.tds.zip \
  && echo "Map zi4.map" >> /usr/share/texlive/texmf-dist/web2c/updmap.cfg \
  && mktexlsr \
  && updmap-sys

## Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/1.18/pandoc-1.18-1-amd64.deb \
  && dpkg -i pandoc-1.18-1-amd64.deb \
  && rm pandoc-1.18-1-amd64.deb
