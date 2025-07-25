FROM ubuntu:24.04

# ENV variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        python3.12  \
        python3-pip  \
        libgomp1 \
        git && \
    rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED

# Install text-generation-webui
USER ubuntu
ENV PATH="/home/ubuntu/.local/bin:$PATH"
WORKDIR /app
RUN git clone --depth 1 https://github.com/oobabooga/text-generation-webui.git . && \
    pip3 install --no-cache-dir -r requirements/full/requirements_cuda128.txt

# Note: you may need to adapt the pip3 install {url} command, based on your environment and https://raw.githubusercontent.com/oobabooga/text-generation-webui/refs/heads/main/requirements/full/requirements_cuda128.txt
RUN pip3 install --no-cache-dir https://github.com/oobabooga/llama-cpp-binaries/releases/download/v0.31.0/llama_cpp_binaries-0.31.0+cu124-py3-none-linux_x86_64.whl

# Clean the env
USER root
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu
ENTRYPOINT [ "python3", "server.py", "--listen", "--api" ]
