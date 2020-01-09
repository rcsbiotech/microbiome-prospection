#!/usr/bin/env bash
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

in=$1
bdir="/work/rcsilva/projects/masters-citrus"
nap_time=1

for id in $(cat ${in}); do

	echo "-------------------------------------"
	echo "| .. Checking id: ${id}"
	sleep ${nap_time}
	reads_kr="${bdir}/analysis/${id}/report.0.51.${id}.reads"
	cntgs_kr="${bdir}/analysis/${id}/report.0.51.${id}.megahit"
	assembly="${bdir}/analysis/${id}/${id}.asm.megahit.fasta"

    # Checa report das reads
	if [[ -s ${reads_kr} ]];
	then
		reads_stat="TRUE"
	else
		reads_stat="FALSE"
	fi
    
    # Checa report da montagem
    if [[ -s ${cntgs_kr} ]];
	then
		asm_kr_stat="TRUE"
	else
		asm_kr_stat="FALSE"
	fi

	# Checa report do assembly
    if [[ -s ${assembly} ]];
	then
		asm_status="TRUE"
	else
		asm_status="FALSE"
	fi
    
    echo "| .. Sample: ${id}"
    echo "| .. Read taxa prediction stats (0.51): ${reads_stat}"
    echo "| .. Assembly (MEGAHIT) stat: ${asm_status}"
    echo "| .. Assembly taxa prediction stats (0.51): ${asm_kr_stat}"
    # echo
    sleep ${nap_time}
    
    if [[ ${reads_stat} == "TRUE" ]] && \
        [[ ${asm_kr_stat} == "TRUE" ]] && \
            [[ ${asm_status} == "TRUE" ]]; 
    then
            
            echo "| .. All are true, proceed."
            sleep ${nap_time}
            
            echo "| .. Moving run to finished dir"
            mv ${bdir}/analysis/${id} ${bdir}/analysis/2019-finished_checked/
            # echo
            sleep ${nap_time}
            
            echo "| .. Deleting Prinseq reads"
            rm ${bdir}/data/02_public_data/runs/${id}*
            # echo
            sleep ${nap_time}
            
            echo "| .. Deleting run ID from input: ${in}"
            sed -i "/${id}/d" ${in}
            # echo
            sleep ${nap_time}
            
            echo "| .. Tagging run as 'ready to delete' on logfile, at: ${bdir}/logs/ready.txt"
            echo "| .. Cleansing complete for run: ${id}"
            echo "${id} is complete" >> ${bdir}/logs/ready.txt
            sleep ${nap_time}
            
    else
            echo "| XX Run ${id} is somehow faulty. Logged at ${bdir}/logs/faulty.txt"
            echo -e "${id}\t${reads_stat}\t${asm_status}\t${asm_kr_stat}" >> ${bdir}/logs/faulty.txt
            # echo
            sleep ${nap_time}
            
            echo
            echo "| -- Starting over..."
	    echo "| -- Now would be a great time to kill the process..."
	    echo "| ZZ Sleeping twice..."
	    sleep ${nap_time}
	    sleep ${nap_time}
            
            
            
    fi
    
    
    
    

done

