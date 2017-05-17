FROM continuumio/miniconda3:4.3.11

MAINTAINER antimon2 <antimon2.me@gmail.com>

# Install NumPy / Matplotlib.
RUN /opt/conda/bin/conda install numpy matplotlib -y --quiet

# Install Jupyter.
RUN /opt/conda/bin/conda install jupyter -y --quiet

# Install libzmq
RUN apt-get update \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o DPkg::Options::="--force-confold" \
    && apt-get install -y \
    libzmq3-dev \
    libzmq3

# Install Julia0.5.2
RUN mkdir -p /opt/julia-0.5.2 && \
    curl -s -L https://julialang.s3.amazonaws.com/bin/linux/x64/0.5/julia-0.5.2-linux-x86_64.tar.gz | tar -C /opt/julia-0.5.2 -x -z --strip-components=1 -f -
RUN ln -fs /opt/julia-0.5.2 /opt/julia-0.5

# Make v0.5.2 default julia
RUN ln -fs /opt/julia-0.5.2 /opt/julia

# RUN echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/julia/bin\"" > /etc/environment && \
#     echo "export PATH" >> /etc/environment && \
#     echo "source /etc/environment" >> /root/.bashrc

ENV PATH /opt/julia/bin:$PATH

# Install IJulia with using installed miniconda, and then precompile it
RUN CONDA_JL_HOME=/opt/conda /opt/julia/bin/julia -e 'Pkg.add("IJulia")'
RUN /opt/julia/bin/julia -e 'Pkg.build("IJulia");using IJulia'

# Install PyPlot with using installed matplotlib, and then precompile it
RUN PYTHON=/opt/conda/bin/python /opt/julia/bin/julia -e 'Pkg.add("PyPlot")'
# RUN /opt/julia/bin/julia -e 'Pkg.build("PyPlot")'
RUN /opt/julia/bin/julia -e 'using PyPlot'

# v0.3: add_iruby: install rvm
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"

# v0.3: add_iruby: install ruby-2.4.0
RUN /bin/bash -l -c "rvm install 2.4.0"
RUN cd / && /bin/bash -l -c "rvm --ruby-version use 2.4.0@global"
RUN cd / && /bin/bash -l -c "gem install bundler --no-rdoc --no-ri"
RUN echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc

# v0.3: add_iruby: install iruby
RUN /bin/bash -l -c "gem install bundle --no-rdoc --no-ri"
# RUN /bin/bash -l -c "rvm gemset create iruby"
# RUN cd ~ && /bin/bash -l -c "rvm --ruby-version use 2.4.0@iruby"
RUN /bin/bash -l -c "gem install cztop --no-rdoc --no-ri"
RUN cd ~ && git clone https://github.com/zeromq/czmq && \
    cd czmq && \
    ./autogen.sh && ./configure && make && make install && \
    cd ~ && rm -rf czmq
RUN /bin/bash -l -c "gem install iruby --no-rdoc --no-ri"
RUN IPYTHONDIR=/opt/conda/share/jupyter /bin/bash -l -c "iruby register --force"

# v0.3: add_iruby: install related library and gems
RUN apt-get install -y gnuplot && \
    /bin/bash -l -c "gem install pry pry-doc numo-narray numo-gnuplot --no-rdoc --no-ri"

# Define working directory.
WORKDIR /opt/notebooks

# EXPOSE
EXPOSE 8888

# Define default command.
# CMD ["/opt/conda/bin/jupyter", "notebook", "--notebook-dir=/opt/notebooks", "--ip='*'", "--port=8888", "--no-browser"]
CMD ["/bin/bash"]
