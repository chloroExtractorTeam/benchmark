File Edit Options Buffers Tools Sh-Script Help                                                                                                                                                
#!/bin/bash                                                                                                                                                                                   

i=$SLURM_ARRAY_TASK_ID ;
ID=$SLURM_ARRAY_TASK_ID ;


echo $i ;


A=($(cat data)) ;


dat=($(echo "${A[@]:$i:1}")) ;

echo $dat  ;
con=$1 ;

echo $con ;

chmod u+x run_singularity.sh;

cd $dat ;

pwd ;
sh ../run_singularity.sh $con  v2.0.5 ;


if   [[ $con == chloroextractor ]]; then
│   rm -r chloroextractor/ptx/ ;
elif [[ $con == chloroplast_assembly_protocol ]]; then
│   rm -r chloroplastassemblyprotocol/*fastq ;
│   rm -r chloroplastassemblyprotocol/cp_noref ;
│   rm -r chloroplastassemblyprotocol/input  ;
elif [[ $con == fastplast ]] ; then
│   rm -r fast*/fast*/ ;
elif [[ $con == org-asm ]] ; then
│   rm -r org-asm/chloro*/ ;
elif [[ $con == getorganelle ]] ; then
│   rm -r get_organelle/fil* ;
│   rm -r get_organelle/seed/ ;
│   rm -r get_organelle/emb* ;
elif [[ $con == ioga ]] ; then
│   rm -r ioga/IOGA* ;
elif [[ $con == novoplasty ]] ; then
│   rm novo_plasty/*txt ;
│   rm novo_plasty/*fast ;
fi



cd ..

cp slurm-${SLURM_ARRAY_JOB_ID}_${ID}.out $dat/$con.out

exit
