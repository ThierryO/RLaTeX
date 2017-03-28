FROM ubuntu:16.10

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
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

## Add apt-get repositories
RUN apt-get update \
  && apt-get install -y --no-install-recommends dirmngr \
  && apt-get clean \
  && sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu yakkety/" >> /etc/apt/sources.list' \
  && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9 \
  && gpg -a --export E084DAB9 | apt-key add -

## Install R base
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    r-base-core=3.3.3-1yakkety0 \
    r-base-dev=3.3.3-1yakkety0 \
    r-cran-boot=1.3-18-2 \
    r-cran-class=7.3-14-1yakkety0 \
    r-cran-cluster=2.0.5-1yakkety0 \
    r-cran-codetools=0.2-14-2 \
    r-cran-foreign=0.8.67-1yakkety0 \
    r-cran-mass=7.3-45-1yakkety0 \
    r-cran-kernsmooth=2.23-15-2yakkety0 \
    r-cran-lattice=0.20-34-1yakkety0 \
    r-cran-matrix=1.2-8-1yakkety0 \
    r-cran-mgcv=1.8-16-1cran1yakkety0 \
    r-cran-nnet=7.3-12-1yakkety0 \
    r-cran-nlme=3.1.131-2yakkety0 \
    r-cran-rpart=4.1-10-2yakkety0 \
    r-cran-spatial=7.3-11-1yakkety0 \
    r-cran-survival=2.39-5-1 \
    r-recommended=3.3.3-1yakkety0 \
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
    texlive-xetex \
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
RUN wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb \
  && dpkg -i pandoc-1.19.2.1-1-amd64.deb\
  && rm pandoc-1.19.2.1-1-amd64.deb
