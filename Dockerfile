FROM continuumio/anaconda3:4.3.1

MAINTAINER antimon2 <antimon2.me@gmail.com>

# Install Jupyter42.
RUN /opt/conda/bin/conda install jupyter -y --quiet

# Install libzmq
RUN apt-get update \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o DPkg::Options::="--force-confold" \
    && apt-get install -y \
    libzmq3-dev \
    libzmq3

# Install Julia0.5.1
RUN mkdir -p /opt/julia-0.5.1 && \
    curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.5/julia-0.5.1-linux-x86_64.tar.gz | tar -C /opt/julia-0.5.1 -x -z --strip-components=1 -f -
RUN ln -fs /opt/julia-0.5.1 /opt/julia-0.5

# Make v0.5.1 default julia
RUN ln -fs /opt/julia-0.5.1 /opt/julia

# RUN echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/julia/bin\"" > /etc/environment && \
#     echo "export PATH" >> /etc/environment && \
#     echo "source /etc/environment" >> /root/.bashrc

ENV PATH /opt/julia/bin:$PATH

# Install IJulia with using installed anaconda, and then precompile it
RUN CONDA_JL_HOME=/opt/conda /opt/julia/bin/julia -e 'Pkg.add("IJulia")'
RUN /opt/julia/bin/julia -e 'Pkg.build("IJulia");using IJulia'

# Install PyPlot with using installed matplotlib, and then precompile it
RUN PYTHON=/opt/conda/bin/python /opt/julia/bin/julia -e 'Pkg.add("PyPlot")'
# RUN /opt/julia/bin/julia -e 'Pkg.build("PyPlot")'
RUN /opt/julia/bin/julia -e 'using PyPlot'

# Define working directory.
WORKDIR /opt/notebooks

# EXPOSE
EXPOSE 8888

# Define default command.
# CMD ["/opt/conda/bin/jupyter", "notebook", "--notebook-dir=/opt/notebooks", "--ip='*'", "--port=8888", "--no-browser"]
CMD ["/bin/bash"]
