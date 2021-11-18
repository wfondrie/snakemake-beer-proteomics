"""Perform a Comet search on 3 beer samples and compare the results"""
BEERS = ["Basis", "Heineken", "HopPerPaw", "PRGbeer"]
STEM = "07_Evosep_Exploris480_{beer}_1"


rule all:
    input: "results/figures/detections.png"


rule download_raw_files:
    output: expand("data/raw/" + STEM + ".raw", beer=BEERS)
    log: "logs/ppx.log"
    shell:
        "ppx --local data MSV000088080 '07_Evosep_Exploris480_*_1.raw' 2> {log}"


rule download_fasta_file:
    output: "data/fasta/beer.fasta"
    log: "logs/wget.log"
    shell:
        """
        wget -O data/fasta/beer.fasta 'https://www.uniprot.org/uniprot/?query=\
        (taxonomy:559292 OR taxonomy:4565 OR taxonomy:4513 OR taxonomy:3486) AND reviewed:yes\
        &format=fasta' 2> {log}
        """


rule convert_raw_files:
    input: "data/raw/{stem}.raw"
    output: "data/mzML/{stem}.mzML.gz"
    log: "logs/thermorawfileparser.{stem}.log"
    shell:
        "thermorawfileparser --gzip --output data/mzML --input {input} 2> {log}"


rule comet_search:
    input:
        "data/mzML/{stem}.mzML.gz",
        "data/fasta/beer.fasta"
    output:
        "results/comet/{stem}.pin"
    log: "logs/comet.{stem}.log"
    threads: workflow.cores
    resources:
        cpus=12,
        mfree=1
    shell:
        """
        cd results/comet && \
        comet -P../../params/comet.params ../../{input[0]} 2> {log}
        """

rule mokapot:
    input:
        fasta="data/fasta/beer.fasta",
        pins=expand("results/comet/" + STEM + ".pin", beer=BEERS)
    output:
        expand(
            "results/mokapot/" + STEM + ".mokapot.{level}.txt",
            beer=BEERS,
            level=["psms", "peptides", "proteins"]
        )
    log: "logs/mokapot.log"
    threads: workflow.cores
    resources:
        cpus=12,
        mfree=1
    shell:
        """
        mokapot \
          --dest_dir results/mokapot \
          --proteins {input.fasta} \
          {input.pins} \
        2> {log}
        """


rule make_figure:
    input:
        expand(
            "results/mokapot/" + STEM + ".mokapot.{level}.txt",
            beer=BEERS,
            level=["psms", "peptides", "proteins"]
        )
    output: "results/figures/detections.png"
    log: "logs/make_figure.log"
    script:
        "scripts/make_figure.py"
