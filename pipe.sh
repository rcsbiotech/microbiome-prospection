#!/usr/bin/env zsh
#
#
# BSD 2-Clause License
#
# Copyright (c) 2018, Rafael Correia da Silva
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# # * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


### Inputs
ids=$1
# assembler=${2:megahit}
# p_nproc=${3:"20"}

# - # - # - # - # - # - # - # - # - # - # - # - #
# - # - # Pipeline: Do SRR até Kraken # - # - # -
# - # - # - # - # - # - # - # - # - # - # - # - #

# Changelog
# 13/12 removed "run date" (stringdate)

for sample in $(cat ${ids});
do

    ## Carregando minhas variáveis ambiente
    source /home/rcsilva/.zshrc

    ## Variable attribution ##
    
    
    # Sample name, sample name in short (sam)
    sample2down=${sample}
    sam=${sample2down}
    
    paired_run='yes'
    stringdate=$(date +%Y-%m-%d)
    
    ## Kraken database
    db_kraken="/usr/local/bioinfo/kraken2/DB"

    ## TODO: Reimplementar ascp-download
    p_down_speed="2m"

    ## TODO: Implementar threads como parâmetro
    p_nproc=20

    ## TODO: Generalizar diretório
    base_dir='/work/rcsilva/projects/masters-citrus'

    ## TODO: Implementar opções de assembly
    assembler="megahit"

    ## Capturando FQ1 e FQ2
    fq1="${base_dir}/data/02_public_data/runs/${sample2down}.ps_1.fastq"
    fq2="${base_dir}/data/02_public_data/runs/${sample2down}.ps_2.fastq"
    fq1_single="${base_dir}/data/02_public_data/runs/${sample2down}.ps_1_singletons.fastq"
    fq2_single="${base_dir}/data/02_public_data/runs/${sample2down}.ps_2_singletons.fastq"

    ## Diretório de output
    outdir="${base_dir}/analysis/${sample2down}"
    mkdir -p ${outdir}

    if [[  -n $(find ${base_dir}/data/02_public_data/runs -name \*${sample2down}_1.fastq\*) ]] || \
        [[  -n $(find ${base_dir}/data/02_public_data/runs -name \*${sample2down}.ps_1.fastq\*) ]] || \
        [[  -n $(find ${base_dir}/data/02_public_data/runs -name \*${sample2down}.sra\*) ]] ;
        
    
        #|| [[  -f ${base_dir}/data/02_public_data/runs/${sample2down}*.fastq ]] \ 
        #|| [[ -n $(find ${base_dir}/data/02_public_data/runs -name \*${sample2down}_1.fastq\*) ]]; 
        
        then
        echo "File exists, not fetching...";
    else
        echo "Prefetching sample ${sampledown}"
        #prefetch --ascp-options "-l ${p_down_speed}" ${sample2down}
        prefetch -X 40000000 -t http ${sample2down}
    
        echo "Moving to data..."
        mv /home/rcsilva/ncbi/public/sra/${sample2down}.sra ${base_dir}/data/02_public_data/runs
        
    fi
    
    if [[ -f ${base_dir}/data/02_public_data/runs/${sample2down}_1.fastq ]]
    then
        echo "Pairs exist"
        echo
    else
        echo "Splitting pairs..."
        cd ${base_dir}/data/02_public_data/runs
        fastq-dump --split-3 ./${sample2down}.sra
    fi
    
    echo "Creating directory for kraken analysis..."
    mkdir -p ${base_dir}/analysis/${sam}
    
    # ddd ${sample2down}-kraken
    # mkdir -p ${sample2down}-kraken/seqs
    
    
    
    
    
    
    
    
    
    
    
    # PREPROC: Prinseq
    # Prinseq: filtrar LC
    echo "Starting Prinseq if not done yet..."
    
    
    if [[ -f ${base_dir}/data/02_public_data/runs/${sample2down}.ps_1.fastq ]]; then
        echo "Prinseq already run."
    else
        echo "Prinseq will remove low quality and low complexity sequences..."
        echo
        echo "Commencing Prinseq for sample ${sam}"
        
        prinseq-lite.pl \
            -verbose \
            -fastq ${base_dir}/data/02_public_data/runs/${sample2down}_1.fastq \
            -fastq2 ${base_dir}/data/02_public_data/runs/${sample2down}_2.fastq \
            -trim_qual_step 1 \
            -trim_qual_window 3 \
            -trim_qual_type mean \
            -trim_qual_right 20 \
            -trim_qual_rule lt \
            -lc_method dust \
            -lc_threshold 30 \
            -out_good ${base_dir}/data/02_public_data/runs/${sample2down}.ps \
            -out_bad null \
            1> ${base_dir}/data/02_public_data/runs/${sample2down}.prsq.log.txt \
            2> ${base_dir}/data/02_public_data/runs/${sample2down}.prsq.err.txt
            
        echo "Prinseq finished."
        echo
        echo
    fi
    
       echo
    # END OF PREPROC: Prinseq
    
    
    
    
    
    ## IMPLEMENTATION WIP
    ## 1. Check for fastq integrity (fqtools)
    ## https://github.com/alastair-droop/fqtools
    
    
    ## 2. If messed up, repair with BBMap (repair.sh)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ## Kraken pass
    echo "Starting taxonomic prediction of reads for sample ${sam}."
    echo "Checking for existing classifications"
    
    if [[ ${paired_run} = "yes" ]]; then
        p_conf="1.00"
        
    
        
        if [[ -n $(find ${base_dir}/analysis/ -name \*report.${p_conf}.${sam}.reads\*) ]]; then
        
            echo "Classification at ${p_conf} already exists, skipping..."
            
        else
        
            echo "Kraken pass (reads) confidence: ${p_conf}"
            kraken2 \
                --db /usr/local/bioinfo/kraken2/DB/  \
                --report ${base_dir}/analysis/${sample2down}/report.${p_conf}.${sam}.reads \
                --memory-mapping \
                --paired \
                --threads ${p_nproc} \
                --confidence ${p_conf} \
                ${fq1} ${fq2} >  /dev/null # ${base_dir}/analysis/${sam}/kr_out.${p_conf}.${sam}.reads
            
        fi
        
        
        p_conf="0.51"
        ## If classification exists, skip, else run kraken on reads again
        if [[ -n $(find ${base_dir}/analysis/ -name \*report.${p_conf}.${sam}.reads\*) ]]; then
        
            # p_conf="0.51"
            echo "Classification at ${p_conf} already exists, skipping..."
            
        else
        
            
            echo "Kraken pass (reads) confidence: ${p_conf}"
        
            kraken2 \
                --db /usr/local/bioinfo/kraken2/DB/  \
                --report ${base_dir}/analysis/${sam}/report.${p_conf}.${sam}.reads \
                --memory-mapping \
                --paired \
                --threads ${p_nproc} \
                --confidence ${p_conf} \
                ${fq1} ${fq2} >  /dev/null # ${base_dir}/analysis/${sam}/kr_out.${p_conf}.${sam}.reads

        fi
        
        
        
        ## If classification exists, skip, else run kraken on reads again
        p_conf="0.01"
        if [[ -n $(find ${base_dir}/analysis/ -name \*report.${p_conf}.${sam}.reads\*) ]]; then
        
            
            echo "Classification at ${p_conf} already exists, skipping..."
            
        else
        
            
            echo "Kraken pass (reads) confidence: ${p_conf}"
        
            kraken2 \
                --db /usr/local/bioinfo/kraken2/DB/  \
                --report ${base_dir}/analysis/${sample2down}/report.${p_conf}.${sam}.reads \
                --memory-mapping \
                --paired \
                --threads ${p_nproc} \
                --confidence ${p_conf} \
                ${fq1} ${fq2} >  /dev/null # ${base_dir}/analysis/${sample2down}/kr_out.${p_conf}.${sam}.reads

        fi
        
        
        
        else
        # TODO: Implement single-end
            
            echo "First kraken pass..."
            p_conf="1.00"
            
            kraken2 \
            --db /usr/local/bioinfo/kraken2/DB/  \
            --report ${base_dir}/analysis/${sample2down}/new.${sample2down}.${p_conf}.report.tsv \
            --memory-mapping \
            --threads ${p_nproc} \
            --confidence ${p_conf} \
            ${base_dir}/data/02_public_data/runs/${sample2down}.fastq > ${base_dir}/analysis/${sample2down}/${sample2down}.${p_conf}.classif.tsv
	
        echo "Second kraken pass..."
        p_conf="0.51"
        
        kraken2 \
        --db /usr/local/bioinfo/kraken2/DB/  \
        --report ${base_dir}/analysis/${sample2down}/new.${sample2down}.${p_conf}.report.tsv \
        --memory-mapping \
        --threads ${p_nproc} \
        --confidence ${p_conf} \
        ${base_dir}/data/02_public_data/runs/${sample2down}.fastq > ${base_dir}/analysis/${sample2down}/${sample2down}.${p_conf}.classif.tsv
	
        echo "Third kraken pass..."
        p_conf="0.1"
        
        kraken2 \
        --db /usr/local/bioinfo/kraken2/DB/  \
        --report ${base_dir}/analysis/${sample2down}/new.${sample2down}.${p_conf}.report.tsv \
        --memory-mapping \
        --threads ${p_nproc} \
        --confidence ${p_conf} \
        ${base_dir}/data/02_public_data/runs/${sample2down}.fastq > ${base_dir}/analysis/${sample2down}/${sample2down}.${p_conf}.classif.tsv
	
    fi

    echo "Finished download and kraken run for ${sample2down}"
    rm ${base_dir}/analysis/${sample2down}/*.classif.tsv


    ## Steps    
    # 1. Assemble with spades
    ## Add: megahit | trinity

    if [[ ${assembler} = "spades" ]]; then
    
	    echo "Assembling with SPADES..."
        if [[ -f ${base_dir}/analysis/${sample2down}/spades/scaffolds.fasta ]]
        then
            echo "Assembly already exist, skipping to classification..."
            echo
        else
            echo "Starting..."
            spades-311.py \
            -1 ${fq1} \
            -2 ${fq2} \
            -o ${outdir}/spades \
            --meta \
            --only-assembler \
            --threads ${p_nproc}
    
	    # echo "Annotating ${assembler} output..."
	    # cd ${outdir}/spades
	    # kr2fa ./scaffolds.fasta 1.0 ${p_nproc}
	    # kr2fa ./scaffolds.fasta 0.51 ${p_nproc}
	    # kr2fa ./scaffolds.fasta 0.01 ${p_nproc}
  
        fi
    fi

        ## Steps    
    # 1. Assemble with MEGAHIT
    if [[ ${assembler} = "megahit" ]]; then
    
        echo "Assembling with MEGAHIT..."
        echo "First, checking for file: ${sample2down}"
    

        if [[ -n $(find ${base_dir}/analysis/ -name \*${sam}.asm.megahit\*) ]]
        then
            echo "Assembly already exists, skipping to classification..."
            echo
        else
            # Directory hash
            asm_var=${RANDOM}

            echo "Starting MEGAHIT..."
            echo "Assemblying sample: ${sam}"
            
            megahit \
                -1 ${fq1} \
                -2 ${fq2} \
                -r ${fq1_single},${fq2_single} \
                --num-cpu-threads ${p_nproc} \
                --out-dir ${outdir}/megahit_${asm_var}
	
            echo "Linking assembly..."
            ln -s ${outdir}/megahit_${asm_var}/final.contigs.fa ${outdir}/${sam}.asm.megahit.fasta
        fi
    fi
    
    
    echo "Annotating ${assembler} output..."
    cd ${outdir}
    
    ## If file can't be found, then
    p_conf=1.00
    if [[ -n $(find ${base_dir}/analysis -name \*kr_out.${sam}.${p_conf}.${assembler}\*) ]]; then
    
        echo "Kraken for contigs for confidence ${p_conf} already run, skipping..."
        echo
    else
    
        echo "Starting Kraken for ${assembler} assembly, confidence: ${p_conf}"
        
        # If it doesn't exist, annotate
        kraken2 \
            --db ${db_kraken} \
            --memory-mapping \
            --threads ${p_nproc} \
            --confidence ${p_conf} \
            --report ${base_dir}/analysis/${sam}/report.${p_conf}.${sam}.${assembler} \
            ${base_dir}/analysis/${sam}/${sam}.asm.megahit.fasta > \
            ${base_dir}/analysis/${sam}/kr_out.${sam}.${p_conf}.${assembler}
            
    fi
    
    p_conf=0.51
    if [[ -n $(find ${base_dir}/analysis -name \*kr_out.${sam}.${p_conf}.${assembler}\*) ]]; then
    
        echo "Kraken for contigs for confidence ${p_conf} already run, skipping..."
        echo
    else
    
        echo "Starting Kraken for ${assembler} assembly, confidence: ${p_conf}"
        # If it doesn't exist, annotate
        kraken2 \
            --db ${db_kraken} \
            --memory-mapping \
            --threads ${p_nproc} \
            --confidence ${p_conf} \
            --report ${base_dir}/analysis/${sam}/report.${p_conf}.${sam}.${assembler} \
            ${base_dir}/analysis/${sam}/${sam}.asm.megahit.fasta > \
            ${base_dir}/analysis/${sam}/kr_out.${sam}.${p_conf}.${assembler}
            
    fi
    
    p_conf=0.01
    if [[ -n $(find ${base_dir}/analysis -name \*kr_out.${sam}.${p_conf}.${assembler}\*) ]]; then
    
        echo "Kraken for contigs for confidence ${p_conf} already run, skipping..."
        echo
    else
        
        echo "Starting Kraken for ${assembler} assembly, confidence: ${p_conf}"
        # If it doesn't exist, annotate
        kraken2 \
            --db ${db_kraken} \
            --memory-mapping \
            --threads ${p_nproc} \
            --confidence ${p_conf} \
            --report ${base_dir}/analysis/${sam}/report.${p_conf}.${sam}.${assembler} \
            ${base_dir}/analysis/${sam}/${sam}.asm.megahit.fasta > \
            ${base_dir}/analysis/${sam}/kr_out.${sam}.${p_conf}.${assembler}
            
    fi
        
    cd ${base_dir}
    echo "Run finished in $(date), for sample ${sample2down}"
    echo "Run finished in $(date), for sample ${sample2down}" >> ${outdir}/log
    echo "GG WP"
    echo
    echo
    echo

done

