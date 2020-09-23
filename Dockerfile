FROM ubuntu:18.04

# Anaconda
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget && \
    rm -rf /var/lib/apt/lists/*
COPY environment.yml /var/tmp/environment.yml
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://repo.anaconda.com/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh && \
    bash /var/tmp/Miniconda3-4.7.12-Linux-x86_64.sh -b -p /usr/local/anaconda && \
    /usr/local/anaconda/bin/conda init && \
    ln -s /usr/local/anaconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    . /usr/local/anaconda/etc/profile.d/conda.sh && \
    conda activate base && \
    conda env update -f /var/tmp/environment.yml && \
    rm -rf /var/tmp/environment.yml && \
    conda install -y ipython jupyter && \
    /usr/local/anaconda/bin/conda clean -afy && \
    rm -rf /var/tmp/Miniconda3-4.7.12-Linux-x86_64.sh

EXPOSE 8888

COPY pygpu-final.ipynb /notebook/

RUN echo "#!/bin/bash\nsource /usr/local/anaconda/bin/activate python-gpu\njupyter notebook --ip 0.0.0.0 --no-browser --notebook-dir /notebook --allow-root" > /usr/local/bin/entrypoint.sh && \
    chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
