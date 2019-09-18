configfile: "config.yaml"
import os

SAMPLES_DICT = [os.path.splitext(f)[0] for f in os.listdir("./") if f.endswith('.fasta')| f.endswith('.fa')]

#Push your image to docker hub if needed
#singularity:"docker://vaibhav810/snakemake_image:snakemake_wf1" 

tempdir=config["tempdir"]
dbdir=config["dbdir"]
outdir=config["outdir"]
output_filename=config["out_filename"]

rule all:
    input:
        tempdir + str(expand("{sample4}.dict",sample4=SAMPLES_DICT)[0]),
        outdir + "Aligned_sorted_RG_index.marked.bam",
        outdir + str(expand("{sample4}.vcf",sample4=SAMPLES_DICT)[0]),
        outdir + "structural.bcf",
        outdir + "structural.vcf",
        outdir + "structural_output.annovar"
        #outdir + "plot.html",

rule genomedir:
    input:
        input_fasta = expand("{sample2}",
                 sample2 = config["genome"])
    priority: 50
    params : 
         sa=config["sa"],
         threads=config["threads"]
    output:
        tempdir + str(expand("{sample4}.dict",sample4=SAMPLES_DICT)[0]),
    shell:
        "samtools faidx {input.input_fasta} |"
        "gatk CreateSequenceDictionary --REFERENCE {input.input_fasta} --OUTPUT={output} |"
        "STAR --runMode genomeGenerate --genomeDir {tempdir} --genomeFastaFiles {input.input_fasta} --genomeSAindexNbases {params.sa} --runThreadN {params.threads} "

rule star_run:
    input:
             fq1 = expand("{sample1}",
                 sample1 = config["reads1"]),
             fq2 = expand("{sample1}",
                 sample1 = config["reads2"])
    output:
        tempdir + "{sample1}.out.sam"
    conda:
      "environment.yaml"
    params : 
         threads=config["threads"]
    shell:
        "STAR --genomeDir {tempdir} --readFilesIn {input.fq1} {input.fq2} --runThreadN {params.threads} --outFileNamePrefix {tempdir}"

rule run_gatk:
    input:
        temp = tempdir + "Aligned.out.sam",
        input_fasta = expand("{sample2}",
                 sample2 = config["genome"])
    output:
        outdir + "Aligned_sorted_RG_index.marked.bam",
        vcf = tempdir + str(expand("{sample4}_output_1.vcf",sample4=SAMPLES_DICT)[0]),
    params : 
         rgid=config["rgid"],
         rglb=config["rglb"],
         rgpl=config["rgpl"],
         rgsm=config["rgsm"],
         rgpu=config["rgpu"],
    shell:
        "cd {tempdir} &&"
        "gatk SamFormatConverter -I ../{input.temp} -O Aligned.out.bam &&" 
        "gatk SortSam -I Aligned.out.bam -O Aligned_sorted.bam -SO coordinate &&"
        "gatk AddOrReplaceReadGroups -I Aligned_sorted.bam -O Aligned_sorted_RG.bam --SORT_ORDER=coordinate --RGID={params.rgid} --RGLB={params.rglb} --RGPL={params.rgpl} --RGSM={params.rgsm} --RGPU={params.rgpu} &&"
        "gatk BuildBamIndex -I Aligned_sorted_RG.bam -O Aligned_sorted_RG.bai &&"
        "gatk MarkDuplicates -I Aligned_sorted_RG.bam -O Aligned_sorted_RG_index.marked.bam --METRICS_FILE=Aligned_sorted_RG_dup_metrics --VALIDATION_STRINGENCY=LENIENT --CREATE_INDEX=true --REMOVE_DUPLICATES=true --ASSUME_SORTED=true &&"
        "cp *.dict ../ &&"
        "gatk SplitNCigarReads -R ../{input.input_fasta} -I Aligned_sorted_RG_index.marked.bam -O Aligned_sorted_RG_index.marked_split.bam &&"
        "gatk HaplotypeCaller -R ../{input.input_fasta} -I Aligned_sorted_RG_index.marked_split.bam -O ../{output.vcf} &&"
        "cp Aligned_sorted_RG_index.marked.bam ../{outdir} &&"
        "cp Aligned_sorted_RG_index.marked.bai ../{outdir}"

rule run_variants:
    input:
        temp = tempdir + str(expand("{sample4}_output_1.vcf",sample4=SAMPLES_DICT)[0]),
        input_fasta = expand("{sample2}",
                 sample2 = config["genome"])
    output:
        outdir + str(expand("{sample4}_output_2.vcf",sample4=SAMPLES_DICT)[0]),
    conda:
      "environment.yaml"
    shell:
        "gatk SelectVariants -R {input.input_fasta} -V {input.temp} -O {output} --select-type-to-include INDEL"

rule run_snp:
    input:
        temp = outdir + str(expand("{sample4}_output_2.vcf",sample4=SAMPLES_DICT)[0]),
        input_fasta = expand("{sample2}",
                 sample2 = config["genome"])
    output:
        outdir + str(expand("{sample4}.vcf",sample4=SAMPLES_DICT)[0]),
    conda:
      "environment.yaml"
    shell:
        "gatk SelectVariants -R {input.input_fasta} -V {input.temp} -O {output} --select-type-to-include SNP"

rule rundelly:
    input:
        marked_bam = outdir + "Aligned_sorted_RG_index.marked.bam",
        input_fasta = expand("{sample2}",
                 sample2 = config["genome"])
    output:
        delly=outdir + "structural.bcf",
        bcf=outdir + "structural.vcf",
#        plot=outdir + "plot.html",
    conda:
        "environment.yaml"
    shell:
         "ls &&"
         "delly call -g {input.input_fasta} {input.marked_bam} -o {output.delly} &&"
         "bcftools view {output.delly} > {output.bcf} && "
         #"mv ./*.dict {tempdir} &&"
         "mv ./Log.out {tempdir}"
         #"mv *.fai {tempdir} "
#         "viva -f {output.bcf} -o {output.plot}"
rule annovar:
    input:
       convert2annovar = expand("{sample1}",
                 sample1 = config["cnvt2ann"]),
       table_annovar = expand("{sample1}",
                 sample1 = config["tableannovar"]),
       annovar = expand("{sample1}",
                 sample1 = config["annovar"]),
       indel_vcf = outdir + str(expand("{sample4}_output_2.vcf",sample4=SAMPLES_DICT)[0]),
       snp_vcf = outdir + str(expand("{sample4}.vcf",sample4=SAMPLES_DICT)[0]),
       structural_vcf = outdir + "structural.vcf",
       input_fasta = expand("{sample2}",
                 sample2 = config["genome"]),
				 database = dbdir
    output:
        indel = outdir + "indel_output.annovar",
        snp = outdir + "snp_output.annovar",
        structural = outdir + "structural_output.annovar"
    conda:
        "environment.yaml"
    shell:
	    "perl {input.convert2annovar} --format vcf4 --includeinfo -withzyg {input.snp_vcf} > {output.snp}&&"
	    "perl {input.convert2annovar} --format vcf4 --includeinfo -withzyg {input.indel_vcf} > {output.indel}&&"
	    "perl {input.convert2annovar} --format vcf4 --includeinfo -withzyg {input.structural_vcf} > {output.structural} &&"
	    "perl {input.table_annovar} --buildver hg19 {output.snp} -out snp -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a,clinvar_20190305,cosmic70,ALL.sites.2015_08 -operation g,r,f,f,f,f,f,f -nastring . -csvout {input.database} &&"
	    "perl {input.table_annovar} --buildver hg19 {output.indel} -out indel -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a,clinvar_20190305,cosmic70,ALL.sites.2015_08 -operation g,r,f,f,f,f,f,f -nastring . -csvout {input.database} &&"
	    "perl {input.table_annovar} --buildver hg19 {output.structural} -out structural -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a,clinvar_20190305,cosmic70,ALL.sites.2015_08 -operation g,r,f,f,f,f,f,f -nastring . -csvout {input.database}"
