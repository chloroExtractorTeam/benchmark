#!/bin/bash

# first test for the input files
if [ ! -e forward.fq ]
then
    date +"[%Y-%m-%d %H:%M:%S] Missing forward reads. Please add a file called forward.fq"
    exit 1;
fi

if [ ! -e reverse.fq ]
then
    date +"[%Y-%m-%d %H:%M:%S] Missing reverse reads. Please add a file called reverse.fq"
    exit 1;
fi

# prevent race conditions in creating the input files
if mkdir "read_sets_changed.started";
then
    # copy both read sets
    cp forward.fq forward.changed.fq
    cp reverse.fq reverse.changed.fq

    # put random quality for the first 10 reads
    random_qual.pl forward.changed.fq
    random_qual.pl reverse.changed.fq

    touch read_sets_changed.done
else
    date +"[%Y-%m-%d %H:%M:%S] Waiting for finishing of read preparation by other task"

    while [ ! -e read_sets_changed.done ];
    do
	sleep 60
	date +"[%Y-%m-%d %H:%M:%S] Still waiting for other job to prepare reads..."
    done
    date +"[%Y-%m-%d %H:%M:%S] Other process prepared the reads"
fi

FW_READ=forward.changed.fq
REV_READ=reverse.changed.fq

# the number of CPUs can be specified using the environment variable NUMCPUS
: "${NUMCPUS:=4}"

date +"[%Y-%m-%d %H:%M:%S] Number of CPUs/threads is set to ${NUMCPUS} and might be changed by defining NUMCPUS as environmental variable"

# Run the correct assembler based on the environment variable
if [ -n "$CHLOROEXTRACTORVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting chloroExtractor"

    mkdir chloroextractor
    cd chloroextractor
    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    ptx -1 "${FW_READ}" -2 "${REV_READ}" -d ptx --threads ${NUMCPUS}

    if [ -e ptx/fcg.fa ]
    then
	cp ptx/fcg.fa output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$GETORGANELLEVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting GetOrganelle"

    : "${SPADESOPTIONS:=--careful --phred-offset 33}"

    SPADESOPTIONS_OPT="--spades-options"

    if [ -z $SPADESOPTIONS ]
    then
	SPADESOPTIONS_OPT=""
    fi
    date +"[%Y-%m-%d %H:%M:%S] SPAdes options are set to ${SPADESOPTIONS} to call GetOrganelle. Other values might be specified by setting the env var SPADESOPTIONS"

    mkdir get_organelle
    cd get_organelle
    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    get_organelle_reads.py -1 "${FW_READ}" -2 "${REV_READ}" "${SPADESOPTIONS_OPT}" "${SPADESOPTIONS}" -o ./ -R 15 -k 21,45,65,85,105 -F plant_cp -t ${NUMCPUS}

    find -name "*path_sequence.fasta" | sort | head -1 | xargs -I{} cp {} output.fa
fi

if [ -n "$IOGAVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting IOGA"

    mkdir ioga
    cd ioga
    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	date +"[%Y-%m-%d %H:%M:%S] Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    IOGA.py --reference "${REFERENCE}" --forward "${FW_READ}" --reverse "${REV_READ}" --threads ${NUMCPUS}

    REQ_OUTPUT_FILE=$(sed -n '2p' IOGA_RUN.final/IOGA_RUN.statistics | cut -f 1).fasta
    if [ -e IOGA_RUN.final/"${REQ_OUTPUT_FILE}" ]
    then
	cp IOGA_RUN.final/"${REQ_OUTPUT_FILE}" output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$NOVOPLASTYVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting NOVOPlasty"

    mkdir novo_plasty
    cd novo_plasty

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	date +"[%Y-%m-%d %H:%M:%S] Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    # Estimate read length
    export NUMREADS=10000
    export READLEN=$(($(head -n $((${NUMREADS}*4)) "${FW_READ}" | sed -n '1~4{n;p}' | tr -d "\n" | wc -c)/${NUMREADS}))
    export INSERTSIZE=$((${READLEN}*23/10))

cat >config.txt <<EOF
Project:
-----------------------
Project name          = NOVOPlasty
Type                  = chloro
Genome Range          = 100000-250000
K-mer                 = 39
Max memory            =
Extended log          = 1
Save assembled reads  = no
Seed Input            = $REFERENCE
Reference sequence    =
Variance detection    = no
Heteroplasmy          =
HP exclude list       =
Chloroplast sequence  =

Dataset 1:
-----------------------
Read Length           = $READLEN
Insert size           = $INSERTSIZE
Platform              = illumina
Single/Paired         = PE
Combined reads        =
Forward reads         = ${FW_READ}
Reverse reads         = ${REV_READ}

Heteroplasmy:
-----------------------
MAF                   =
HP exclude list       =
PCR-free              =

Optional:
-----------------------
Insert size auto      = yes
Insert Range          = 1.8
Insert Range strict   = 1.3
Use Quality Scores    = no
EOF

    NOVOPlasty.pl -c config.txt

    if [ -e Circularized_assembly_1_NOVOPlasty.fasta ]
    then
	cp Circularized_assembly_1_NOVOPlasty.fasta output.fa
    elif [ -e Option_1_NOVOPlasty.fasta ]
    then
	cp Option_1_NOVOPlasty.fasta output.fa
    elif [ -e Contigs_1_NOVOPlasty.fasta ]
    then
	cp Contigs_1_NOVOPlasty.fasta output.fa
    else
        echo -n "" >output.fa
    fi

fi

if [ -n "$CHLOROPLASTASSEMBLYPROTOCOL" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting chloroplast-assembly-protocol"

    mkdir chloroplastassemblyprotocol
    cd chloroplastassemblyprotocol

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	date +"[%Y-%m-%d %H:%M:%S] Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    mkdir input
    cd input
    # generate an interleaved file from our input files
    perl -e '
       open(my $fw,"../../'"${FW_READ}"'")  || die("$!\n");
       open(my $rev,"../../'"${REV_READ}"'") || die("$!\n");

       my $readnumber = 0;

       while(! (eof($fw) || eof($rev)))
       {
          my $read = 1;
          $readnumber++;
          foreach my $file ($fw, $rev)
          {
             foreach my $i (1..4)
             {
                my $line = <$file>;
                if ($i==1)
                {
                   $line=sprintf("\@read.%d.%d\n", $readnumber, $read);
                   $read++;
                   $read=1 if ($read>2);
                }
                $line="+\n" if ($i == 3);
                print $line;
             }
          }
       }' >interleaved.fq
    cd ..

    0_get_cp_reads.pl input cp_noref $REFERENCE

    # set threads
    sed -i 's/\(CPUTHREADS[[:space:]]*=[[:space:]]*\)[0-9]*/\1'${NUMCPUS}'/g' $(which 1_cleanreads.pl)
    1_cleanreads.pl -folder cp_noref

    if [ -e cp_noref/cleanreads.txt ]
    then
	sed 's/[[:space:]]*nd[[:space:]]*nd[[:space:]]*/ FR 250 /g' cp_noref/cleanreads.txt >cp_noref/assembly_pe
	2_assemble_reads.pl cp_noref assembly_pe -threads ${NUMCPUS}

	find -name "sspace.final.scaffolds.fasta" | sort | head -1 | xargs -I{} cp {} output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$FASTPLASTVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting fast-plast"

    mkdir fast-plast
    cd fast-plast
    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    fast-plast.pl -1 "${FW_READ}" -2 "${REV_READ}" -name fast-plast --threads ${NUMCPUS}

    REQ_OUTFILE=$(find -name "*_FULLCP.fsa" | head -n 1)
    if [ -e "${REQ_OUTFILE}" ]
    then
	cp "${REQ_OUTFILE}" output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$ORGASMVERSION" ]
then
    date +"[%Y-%m-%d %H:%M:%S] Starting ORG-asm"

    mkdir org-asm
    cd org-asm
    ln -s ../"${FW_READ}"
    ln -s ../"${REV_READ}"

    oa index chloro "${FW_READ}" "${REV_READ}"
    oa buildgraph --probes protChloroArabidopsis chloro chloro.graph
    oa unfold chloro chloro.graph >output.fa
fi

date +"[%Y-%m-%d %H:%M:%S] Finished wrapper script"
