FROM ubuntu:24.04

# ENV variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        python3.12  \
        python3-pip  \
        python3-dev \
        build-essential \
        libgomp1 \
        git \
        curl && \
    rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install text-generation-webui
USER ubuntu
ENV PATH="/home/ubuntu/.local/bin:$PATH"
WORKDIR /app
RUN git clone --depth 1 https://github.com/oobabooga/text-generation-webui.git . && \
    pip3 install --no-cache-dir -r requirements/full/requirements_cuda128.txt

# Add the provided utility script in the image
COPY download.py .

# Install nvcc for transformers loading quatization
USER root
RUN curl -O https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y cuda-nvcc-12-8  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER ubuntu

# Note: based on https://raw.githubusercontent.com/oobabooga/text-generation-webui/refs/heads/main/requirements/full/requirements_cuda128.txt
RUN pip3 install --no-cache-dir https://github.com/oobabooga/llama-cpp-binaries/releases/download/v0.31.0/llama_cpp_binaries-0.31.0+cu124-py3-none-linux_x86_64.whl && \
    pip3 install --no-cache-dir flash-attn --no-build-isolation

# Entrypoint
ENTRYPOINT [ "python3", "server.py", "--listen", "--api" ]
