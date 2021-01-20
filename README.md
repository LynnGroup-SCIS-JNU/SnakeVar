<h1 align="center">Welcome to SnakeVar 👋</h1>
<p>
  <a href="#" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" />
  </a>
</p>

>Snakemake base pipeline
![](https://github.com/lynngroup/Snakemake_Annotation_variant/blob/master/annovar.svg)
### 🏠 [Homepage](https://github.com/naveen584/Snakemake_Annotation_variant)

## Installation

```sh
1) Install snakemake using:  pip install snakemake
2) Installation via Conda: conda install -c bioconda -c conda-forge snakemake
3) conda packages: conda install -c bioconda -y gatk4 samtools  star bcftools  delly
```

## Usage

```sh
Reports and Visualization:

snakemake --report report.html

snakemake --dag | dot | display

snakemake --dag | dot -Tpdf > dag.pdf

snakemake --forceall --dag | dot -Tpdf > dag.pdf

```

## Run tests

```sh

# Steps for conda and without conda:

1) Run below commands for without anaconda
    snakemake all
2) For particular target run  snakemake <target_name> 
 For example: snakemake genomedir/ebola_ref.dict

3) Run below commands for with anaconda env. Change env as per your machine in environment.yml
 e.g. snakemake all --use-conda


# Steps for docker:

From Private registry

1) Create docker image using below command :
    docker build -t <image_name> .
    For example, docker build -t myimage .

2) Run & test container from image :
    docker run -i -t <image_name> /bin/bash & then
	snakemake all


# Steps for singularity:

1) snakemake --use-singularity

From Private registry

2) Start a Registry Container
docker run -d -p 127.0.0.1:5000:5000 --restart always -v  registry:/var/lib/registry --name registry -e REGISTRY_STORAGE_DELETE_ENABLED=true registry:2.4

4) Prepare your local images for the private registry.
   docker tag <local image> localhost:5000/<local image>

5) Add an image to the private registry.
   docker push localhost:5000/<local image>

Note: By default, our local registry does not have https enabled. Therefore
we need to use the SINGULARITY_NOHTTPS variable to force Singularity
to not use https when interacting with a Docker registry.

6) export SINGULARITY_NOHTTPS=true

7) Give name in Snakefile for pulling i.e
   docker pull localhost:5000/<local image>

8) If we dont want to use singularity, then comment out that part in Snakefile
```

## Author

👤 **Naveen Kumar Meena, Divya Saxena ,Andrew M. Lynn.**

* Github: [@naveen584](https://github.com/naveen584)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/naveen584/nextflow_structural_variant/issues).

## Show your support

Give a ⭐️ if this project helped you!
