FROM jupyter/r-notebook

MAINTAINER "Mono" monika@praekelt.org
LABEL version="0.3"
LABEL description="Rstudio server dockerfile singleuser for Praekelt.org"

USER root

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		libapparmor1 \
		libedit2 \
		lsb-release \
		psmisc \
		libssl1.0-dev \
		zlib1g-dev \
		libpq-dev \
		postgresql \
	    postgresql-contrib \
	    xml2 \
	    libxml2-dev \
	    libsm-dev \
	    libxt-dev \
		;

# You can use rsession from rstudio's desktop package as well.
ENV RSTUDIO_PKG=rstudio-server-latest-amd64.deb

RUN wget -q http://www.rstudio.org/download/latest/stable/server/ubuntu64/${RSTUDIO_PKG}
RUN dpkg -i ${RSTUDIO_PKG}
RUN rm ${RSTUDIO_PKG}

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER
#USER jovyan

#RUN \
#  echo "www-frame-origin=app.dominodatalab.com" >> /etc/rstudio/rserver.conf && \
#  chown ubuntu:ubuntu /etc/rstudio

RUN pip install git+https://github.com/jupyterhub/nbserverproxy.git
RUN jupyter serverextension enable --sys-prefix --py nbserverproxy

RUN pip install git+https://github.com/jupyterhub/nbrsessionproxy.git
RUN jupyter serverextension enable --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension install    --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension enable     --sys-prefix --py nbrsessionproxy

# The desktop package uses /usr/lib/rstudio/bin
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"


# Setup R configs
RUN Rscript -e "install.packages(c('RPostgreSQL','reshape','rjson','kableExtra','networkD3','googlesheets','survminer', 'sqldf', 'roxygen2'),repos='https://cran.rstudio.com/', method='curl')"


