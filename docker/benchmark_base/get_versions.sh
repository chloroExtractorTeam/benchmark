#!/bin/bash

(
    for i in Log::Log4perl Moose File::Which IPC::Run Term::ProgressBar Graph
    do
	perl -M${i} -e 'print join("\t", "'"${i}"'", $'"${i}"'::VERSION), "\n";'
    done

    echo -e "bowtie2\t"$(bowtie2 --version | grep -Po "(?<=bowtie2-align-s version )(\S+)")
    echo -e "NCBI-blast\t"$(blastn -version | grep -oP "blastn: \S+" | awk -F": " '{print $2}')
    echo -e "samtools\t"$(samtools 2>&1 | grep -oP "(?<=Version: )\S+")
    echo -e "GNU_R\t"$(R --version | grep -oP "(?<=R version )\S+")
    echo -e "Ghostscript\t"$(ghostscript --version)
    echo -e "jellyfish\t"$(jellyfish --version | grep -oP "(?<=jellyfish )\S+")
    echo -e "Python\t"$(python --version 2>&1 | grep -oP "(?<=Python )\S+")
    echo -e "SPAdes\t"$(spades.py --version 2>&1 | grep -oP "(?<=SPAdes )\S+")
) | column -t
