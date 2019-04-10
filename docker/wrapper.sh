#!/bin/bash

# first test for the input files
if [ ! -e forward.fq ]
then
    echo "Missing forward reads. Please add a file called forward.fq"
    exit 1;
fi

if [ ! -e reverse.fq ]
then
    echo "Missing reverse reads. Please add a file called reverse.fq"
    exit 1;
fi

# the number of CPUs can be specified using the environment variable NUMCPUS
: "${NUMCPUS:=4}"

echo "Number of CPUs/threads is set to ${NUMCPUS} and might be changed by defining NUMCPUS as environmental variable"

# Run the correct assembler based on the environment variable
if [ -n "$CHLOROEXTRACTORVERSION" ]
then
    echo "Running chloroExtractor"

    ptx -1 forward.fq -2 reverse.fq -d ptx --threads ${NUMCPUS}

    if [ -e ptx/fcg.fa ]
    then
	cp ptx/fcg.fa output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$GETORGANELLEVERSION" ]
then
    echo "Running GetOrganelle"

    mkdir get_organelle
    cd get_organelle
    ln -s ../forward.fq
    ln -s ../reverse.fq
    get_organelle_reads.py -1 forward.fq -2 reverse.fq -o ./ -R 15 -k 21,45,65,85,105 -F plant_cp -t ${NUMCPUS}

    find -name "*path_sequence.fasta" | sort | head -1 | xargs -I{} cp {} ../output.fa
fi

if [ -n "$IOGAVERSION" ]
then
    echo "Running IOGA"

    REFERENCE="reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    IOGA.py --reference "${REFERENCE}" --forward forward.fq --reverse reverse.fq --threads ${NUMCPUS}

    cp IOGA_RUN.final/$(sed -n '2p' IOGA_RUN.final/IOGA_RUN.statistics | cut -f 1).fasta output.fa
fi

if [ -n "$NOVOPLASTYVERSION" ]
then
    echo "Running NOVOPlasty"

    mkdir novo_plasty
    cd novo_plasty

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    ln -s ../forward.fq
    ln -s ../reverse.fq

    # Estimate read length
    export NUMREADS=10000
    export READLEN=$(($(head -n $((${NUMREADS}*4)) forward.fq | sed -n '1~4{n;p}' | tr -d "\n" | wc -c)/${NUMREADS}))
    export INSERTSIZE=$((${READLEN}*23/10))

cat >config.txt <<EOF
Project:
-----------------------
Project name          = NOVOPlasty
Type                  = chloro
Genome Range          = 100000-250000
K-mer                 = 39
Max memory            =
Extended log          = 0
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
Forward reads         = forward.fq
Reverse reads         = reverse.fq

Optional:
-----------------------
Insert size auto      = yes
Insert Range          = 1.8
Insert Range strict   = 1.3
Use Quality Scores    = no
EOF

    NOVOPlasty.pl -c config.txt

    cp Circularized_assembly_1_NOVOPlasty.fasta ../output.fa
fi

if [ -n "$CHLOROPLASTASSEMBLYPROTOCOL" ]
then
    echo "Running chloroplast-assembly-protocol"

    mkdir chloroplastassemblyprotocol
    cd chloroplastassemblyprotocol

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    mkdir input
    cd input
    # generate an interleaved file from our input files
    perl -e '
       open(my $fw,"../../forward.fq")  || die("$!\n");
       open(my $rev,"../../reverse.fq") || die("$!\n");

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
    fi
fi

if [ -n "$FASTPLASTVERSION" ]
then
    echo "Running fast-plast"

    fast-plast.pl -1 forward.fq -2 reverse.fq -name fast-plast --threads ${NUMCPUS}

    cp $(find -name "*_FULLCP.fsa") output.fa
fi

if [ -n "$ORGASMVERSION" ]
then
    echo "Running ORG-asm"
fi
