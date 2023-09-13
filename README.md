# Reproduction code for VLDB 2023 EAB paper on LDBC SNB BI

This repository contains the source code for a partial reproduction of the [VLDB 2023 paper "The LDBC Social Network Benchmark:
Business Intelligence Workload"](https://www.vldb.org/pvldb/vol16/p877-szarnyas.pdf), authored by Szárnyas et al.
The paper was published at VLDB's Experiment, Analysis, & Benchmark track, and presents the LDBC SNB BI workload, an analytical workload that targets data processing systems with graph processing capabilities (e.g. path finding).
The paper includes two sets of experiments.
These execute the full LDBC SNB BI workload on two database management systems.
One set of experiments uses the Umbra RDBMS and runs on a single-node setup.
The other set uses the TigerGraph graph DBMS and runs on a multi-node setup.

In the following, we document the details of the reproduction, including background information and instructions on how to run our scripts. For questions, please reach out to Gábor Szárnyas (`gabor.szarnyas@ldbcouncil.org`).

## Scope of reproduction

The scope of the reproduction covers the experiments performed on the Umbra RDBMS using scale factors 30, 100, and 300. Successful execution of this code is expected to reproduce columns 2–4 of [Table 4 (page 9)](https://www.vldb.org/pvldb/vol16/p877-szarnyas.pdf#page=9).

The experiments for the TigerGraph graph DBMS are out of scope for this reproduction.
We decided to omit them due to their distributed infrastructure setup (using 4-48 AWS EC2 instances) and high execution costs (estimated to be $1,849.97 for the SF10,000 experiments).
That said, we would like to highlight that the TigerGraph system's implementation of the LDBC SNB BI workload was submitted to LDBC's official auditing process and it passed the audit successfully in April 2023. The full disclosure reports are available:

* [Official LDBC benchmark results for TigerGraph on Scale Factor 1,000](https://ldbcouncil.org/benchmarks/snb/LDBC_SNB_BI_20230406_SF1000_tigergraph.pdf)
* [Official LDBC benchmark results for TigerGraph on Scale Factor 10,000](https://ldbcouncil.org/benchmarks/snb/LDBC_SNB_BI_20230406_SF10000_tigergraph.pdf)

Note: the official LDBC audits used benchmark setups that are different from the ones used in the paper's experiments.
The differences stem from the selection of cloud provider: the audited results were executed in AWS instead of the Google Cloud used in the paper's TigerGraph experiments.
While similar instances were selected in both clouds, there are a number of small differences between the CPU, memory, and disk types, which have an impact on performance.

## Estimated effort of reproduction

We estimate the required effort for reproduction as follows.
The preparation of the infrastructure takes 30-60 minutes.
The execution of the experiments requires a total time of 6 hours. During this time the scripts proceed automatically without the need for user interaction.
Examining the outputs and tearing down the infrastructure require an additional 30 minutes.

## Data sets

The data sets used in the experiments can be generated with the [LDBC Spark Datagen v0.5.0](https://github.com/ldbc/ldbc_snb_datagen_spark/releases/tag/v0.5.0).
To help the adoption of the benchmark, we generated these data sets for scale factors up to SF10,000.
These are linked in the [BI repository](https://github.com/ldbc/ldbc_snb_bi/blob/main/snb-bi-pre-generated-data-sets.md) and available for the public:
the data sets can be downloaded for free (i.e. there are no egress charges) and without the need for authentication.
The reproduction scripts use these pre-generated data sets.

## Instructions

1. Start an [`m6id.32xlarge`](https://instances.vantage.sh/aws/ec2/r6id.32xlarge) instance on AWS EC2. The default root disk size (8 GB) is sufficient.

1. Log in to the machine using SSH.

1. Open a `tmux` session and run:

    ```bash
    cd ${HOME}
    git clone https://github.com/ldbc/ldbc-snb-bi-vldb2023-reproduction
    cd ldbc-snb-bi-vldb2023-reproduction
    ./prepare-instance.sh
    ```

1. Log out and log in again (this is required by Docker).

2. To download the required artifacts (Umbra Docker image, data sets) and run the benchmark, issue the following commands:

    ```bash
    cd ${HOME}/ldbc-snb-bi-vldb2023-reproduction
    ./prepare-benchmark.sh && ./run-benchmark.sh
    ```

    Note: if there are no errors, these scripts will download the artifacts and perform three benchmarks runs (SF30, SF100, and SF300) without requiring user interaction.

3. The results are saved in the `/data/ldbc_snb_bi/umbra/umbra-results.zip` file:

    * `output/`: query outputs
    * `logs/`: execution logs
    * `scoring/`: benchmark scores
   
   For each scale factor `${SF}`, the `scoring/runtimes-umbra-sf${SF}.csv` file contains the results included in Table 4 of the paper from line 1 (power@SF score) to line 42 (n_{throughput batches}). The results are expected to match those given in column 2 (SF30), column 3 (SF100), and column 4 (SF300).
