#FROM ubuntu
FROM continuumio/miniconda3


#MAINTAINER Vaibhav Kothari


## Install git
#RUN apt-get update \
#    && apt-get install -y --no-install-recommends git apt-transport-https gnupg2 \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log



# Clone germlinewrapper script for pindel filtering
#USER root
WORKDIR /workflow

RUN apt-get update \
    && apt-get install -y git build-essential wget zlib1g-dev libncurses5-dev libbz2-dev liblzma-dev unzip libxss1 libgtk2.0-0 libx11-xcb1 libxcb1 libxtst6 libgconf-2-4 libasound2 libnss3 \
    && rm -rf /var/lib/apt/lists/*
#RUN conda env create -f environment.yaml
RUN conda create -n env python=3.6
RUN echo "source activate env" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH
RUN conda install -c bioconda -y gatk4 samtools snakemake star bcftools nextflow snakemake delly && \
#    conda install -c conda-forge julia && \
    conda clean -y --all
#RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz \
#    && tar -xvf julia-1.1.1-linux-x86_64.tar.gz
	#    && ln -s julia-1.1.1/bin/julia /usr/local/bin/julia

RUN ls
#ENV PATH ./julia-1.1.1/bin/:$PATH
#RUN ln -s julia-1.1.1/bin/julia /usr/local/bin/julia
#RUN ln -s julia-1.1.1/bin/julia /opt/conda/envs/env/bin/julia

	#RUN git clone https://github.com/ding-lab/germline_variant_snakemake.git
#RUN julia -e 'using Pkg; Pkg.add("VariantVisualization.jl")'
#RUN julia -e 'using Pkg;Pkg.add(PackageSpec(url="https://github.com/compbiocore/VariantVisualization.jl.git", rev="master"))'
	# Execute the pipeline
	#RUN snakemake all
#COPY . .
COPY annovar .
COPY Snakefile .
COPY config.yaml .
COPY genome.fa .
COPY paired_end1.fq .
COPY paired_end2.fq .

