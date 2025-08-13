# EpigeneNemaPipe

EpigeneNemaPipe is a pipeline for analysis of chromatin state changes
in the nematode *Strongyloides ratti*. The pipeline uses two unsupervised
machine learning techniques to segment the genome.

The chromatin states are learned from binarized data using a multivariate
Hidden Markov Model (HMM) and Dynamic Bayesian Network (DBN).


## Installation

EpigeneNemaPipe pipeline is written in Nextflow and runs on Linux and Mac OSX systems.

## Dependencies

In order to run EpigeneNemaPipe, you need to have the following programs installed:

- **Java v8+** for Nextflow
- **Nextflow** for workflow management, specifically DSL2 support
- **Conda** for installation of workflow tools

## Install EpigeneNemaPipe

After installing all the above dependencies, EpigeneNemaPipe will automatically install the software needed for the process using Conda when running the pipeline.

## Quick guide on how to install most tools

- **Java v8+**: [https://anaconda.org/cyclus/java-jdk](https://anaconda.org/cyclus/java-jdk)  
- **Nextflow**: [https://www.nextflow.io/docs/latest/getstarted.html#installation](https://www.nextflow.io/docs/latest/getstarted.html#installation)  
- **Conda**: [https://docs.conda.io/projects/conda/en/latest/user-guide/install/](https://docs.conda.io/projects/conda/en/latest/user-guide/install/)

