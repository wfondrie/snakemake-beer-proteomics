# A Snakemake Example with Beer Proteomics

This is an example of a Snakemake workflow that I put together for the Noble
lab in late 2021. This workflow analyses proteomics data from four different
beers using data that was part of "The 2020 ABRF Beer Study: beer proteomics at
the global scale"
([MSV000088080](https://massive.ucsd.edu/ProteoSAFe/dataset.jsp?task=b1d83491073946d3b617b739e9b9f378)).

It specifically performs the following steps:
1. Downloads the four mass spectrometry data files from
   [MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) using
   [ppx](https://ppx.readthedocs.io/en/latest/).
2. Downloads an appropriate beer FASTA file consisting of the yeast, barley,
   wheat, and hops verified UniProt proteomes.
3. Converts the raw mass spectrometry data files to an open format (mzML) using
   [ThermoRawFileParser](https://github.com/compomics/ThermoRawFileParser).
4. Searches each of the data files against the beer FASTA file using
   [Comet](https://uwpr.github.io/Comet/).
5. Refines the search results with
   [mokapot](https://mokapot.readthedocs.io/en/latest/) using a joint model.
5. Creates a plot showing the number of PSMs, peptides, and proteins from each.


## Setup

### 1. Prerequisites
This repository includes a conda environment that is compatible with MacOS and
Linux systems. First, if you'll need a working conda installation. If you need
to install one, I recommend
[miniconda](https://docs.conda.io/en/latest/miniconda.html). You'll also need
[git](https://git-scm.com/) to clone this repository, which can be installed
using conda:

``` sh
conda install git
```

### 2. Clone this repository
With conda installed, you should first clone this repository:

``` sh
git clone https://github.com/wfondrie/snakemake-beer-proteomics.git
```
Then enter it:

``` sh
cd snakemake-beer-proteomics
```


### 3. Create and activate the conda environment

Create the conda environment:

``` sh
conda env create --prefix ./envs -f environment.yaml
```

Activate the conda environment:

``` sh
conda activate ./envs
```

## Run the workflow

To run this workflow on your local machine using all available cores:

``` sh
snakemake --cores all
```

To run this workflow on an SGE cluster like at UWGS:

``` sh
snakemake --profile sge --use-conda
```
*Note, you should ideally encapsulate this command into its own job, rather than running it on the head node.*

## Repository organization

This is an overview of how this repository is organized after the workflow 
has been executed.

```
snakemake-beer-proteomics
|- Snakefile          # The instructions for Snakemake
|
|- data               # The downloaded data.
|  |- raw             # The Thermo raw files.
|  |- mzML            # The mzML files
|  `- fasta           # The FASTA files.
|
|- results            # Results from Comet, mokapot, and the final figure.
|  |- comet           # The comet results.
|  |- mokapot         # The mokapot results.
|  `- figures         # The final figure.
|
|- scripts            # The scripts used during the analysis.
|  `- make_figure.py  # The script to create the final figure.
|
|- profiles           # Profiles for cluster jobs.
|  `- sge             # A basic SGE profile, tailored for UWGS.
|     `- config.yaml  # The configuration file that tells snakemake how to 
|                     #   submit jobs to the cluster and what resources we
|                     #   can specify.
|
|- params             # Parameter files.
|  `- comet.params    # The Comet search parameters. 
|
|- logs               # Log files from the various steps of the pipelne.
|- envs               # The installed conda environement.
|- job.sh             # An example SGE job script to run the workflow.
|- README.md          # This file.
`- LICENSE            # MIT.
```

