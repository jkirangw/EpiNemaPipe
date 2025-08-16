#!/usr/bin/env nextflow

/* 
 * This code enables the new dsl of Nextflow. 
 */

nextflow.enable.dsl=2

params.fasta = "$baseDir/Reference/s_ratti.SRAEv7.genome.v7.0.fa"
params.outdir = "/home/bioc1874/NEXTFLOW/test_data/combined_PF_FLF/results"
params.index = "$baseDir/results2/indexes/s_ratti.SRAEv7.genome.v7.0.index"
params.reads = "/home/bioc1874/NEXTFLOW/test_data/combined_PF_FLF/*_r{1,2}_val_*.fq.gz"
params.genome_size=43872816
params.chrom_sizes = "/home/bioc1874/NEXTFLOW/FINAL_WORKING_PIPELINE/CHROME_SIZES/s_ratti_chrom_sizes.txt"

Channel
  .fromPath( params.fasta )
  .ifEmpty { error "Cannot find any fasta file matching: ${params.fasta}" }
  .set { fasta_file }

Channel
  .fromFilePairs(params.reads, flat: true)
  .set { reads_ch }

process INDEXING {
  conda 'envs/bowtie2.yaml'
  tag { fasta.baseName }
  cpus 8
  publishDir "${params.outdir}/indexes", mode: 'copy'

  input:
    path fasta 

  output:
    path "${fasta.baseName}.index.*"

  script:
  """
  bowtie2-build --threads ${task.cpus} ${fasta} ${fasta.baseName}.index &> ${fasta.baseName}_bowtie2_report.txt

  if grep -q "Error" ${fasta.baseName}_bowtie2_report.txt; then
  exit 1
  fi
  """
}

process ALIGN_AND_SORT {
    conda './envs/bowtie2.yaml'
    cpus 8
    publishDir "${params.outdir}/mapping", mode: 'copy'
    tag "${sample_id}"

    input:
    tuple val(sample_id), path(reads1), path(reads2)

    output:
    path "${sample_id}.sorted.bam"

    script:
    """
    bowtie2 -x ${params.index} -1 ${reads1} -2 ${reads2} --threads ${task.cpus} --sensitive | \\
      samtools view -bS - | \\
      samtools sort -@ ${task.cpus} -o ${sample_id}.sorted.bam
    """
}

process BAMTOBEDGRAPH {
  tag { bam_file }
  conda 'envs/deeptools_env.yml'
  publishDir "${params.outdir}/Bedgraph_outdir", mode: 'copy'

  input:

  path bam_file


  output:

  path "${bam_file.simpleName}.bedGraph"


  script:

  """
    samtools index ${bam_file}
    bamCoverage \
    -b ${bam_file} \
    -o ${bam_file.simpleName}.bedGraph \
    --binSize 50 \
    --normalizeUsing RPGC \
    --effectiveGenomeSize ${params.genome_size} \
    --outFileFormat bedgraph
  """

}

process GENOMEDATA {
    tag "genomedata-load"
    conda 'env_segway.yaml'
    publishDir "${params.outdir}/genomedata_outdir", mode: 'copy'

    input:
    path bedgraphs

    output:
    path "combined.genomedata"

    script:
    def tracks = bedgraphs.collect { "-t ${it.simpleName}=${it}" }.join(" ")
    """
    genomedata-load -s ${params.fasta} ${tracks} combined.genomedata
    """
}

process MODEL_TRAIN {
    tag "segway-train"
    conda 'env_segway.yaml'
    publishDir "${params.outdir}/genomedata_outdir", mode: 'copy'

    input:
    path combined_genomedata

    output:
    path "traindir"

    script:
    """
    segway train --num-labels 6 ${combined_genomedata} traindir
    """
}

process SEGMENT_ALL {
    tag "segway-identify"
    conda 'env_segway.yaml'
    publishDir "${params.outdir}/SEGMENTATION_outdir", mode: 'copy'

    input:
    path combined_genomedata
    path traindir

    output:
    path "all_identifydir"

    script:
    """
    segway identify ${combined_genomedata} ${traindir} all_identifydir
    """
}

workflow {

    index_files = INDEXING(fasta_file)
    sorted_ch = ALIGN_AND_SORT(reads_ch)
    bedgraph_ch  = BAMTOBEDGRAPH(sorted_ch)
    combined_genomedata_ch = GENOMEDATA(bedgraph_ch.collect())
    combined_traindir_ch = MODEL_TRAIN(combined_genomedata_ch)
    SEGMENT_ALL(combined_genomedata_ch, combined_traindir_ch)

}
