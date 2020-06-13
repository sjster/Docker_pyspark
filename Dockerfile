FROM nvidia/cuda:10.0-base-ubuntu16.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Install Java JDK
# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update && apt-get install -y \
    software-properties-common iputils-ping

# Add the "JAVA" ppa
RUN add-apt-repository -y \
    ppa:webupd8team/java

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
    && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \ 
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p ~/miniconda \
    && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

RUN echo $PATH
RUN ls /home/user/miniconda/bin/conda

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda install conda-build 
RUN /home/user/miniconda/bin/conda create -y --name py36 python=3.6.5 \
    && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH

# CUDA 10.0-specific steps
RUN conda install -y -c anaconda pyspark \
   && conda clean -ya

# Install Requests, a Python library for making HTTP requests
RUN conda install -y requests=2.19.1 \
    && conda clean -ya

# Install Deep learning packages
RUN conda install pandas numpy pyarrow fastparquet pip \
    && conda clean -ya
RUN conda install -c conda-forge spacy 
RUN pip install graphframes

RUN pyspark --packages graphframes:graphframes:0.6.0-spark2.3-s_2.11
# Copy the requirement file to the continer 
ADD /requirements.txt /app/
RUN pip install -r requirements.txt

# Install OpenCV3 Python bindings
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libcanberra-gtk-module \
    && sudo rm -rf /var/lib/apt/lists/*

# Set the default command to python3
CMD ["python3"]
