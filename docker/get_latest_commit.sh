#!/bin/bash

declare -A repos=(
    [chloroExtractor]="./benchmark_chloroextractor/Dockerfile|https://github.com/chloroExtractorTeam/chloroExtractor.git"
    [chloroplast_assembly_protocol]="./benchmark_chloroplast_assembly_protocol/Dockerfile|https://github.com/eead-csic-compbio/chloroplast_assembly_protocol.git"
    [GetOrganelle]="./benchmark_GetOrganelle/Dockerfile|https://github.com/Kinggerm/GetOrganelle.git"
    [IOGA]="./benchmark_IOGA/Dockerfile|https://github.com/holmrenser/IOGA.git"
    [NOVOPlasty]="./benchmark_NOVOPlasty/Dockerfile|https://github.com/ndierckx/NOVOPlasty.git"
    [Fast-Plast]="./benchmark_fastplast/Dockerfile|https://github.com/mrmckain/Fast-Plast.git"
    [ORG.Asm]="./benchmark_org-asm/Dockerfile|https://git.metabarcoding.org/org-asm/org-asm.git"
    )

for reponame in ${!repos[@]}
do
    repourl=$(echo ${repos[${reponame}]} | cut -f 2 -d "|")
    repodockerfile=$(echo ${repos[${reponame}]} | cut -f 1 -d "|")

    echo -e "*****\n${reponame}"
    echo "Used in container: "$(grep -P "^ENV.+VERSION" "${repodockerfile}")
    
    git clone "${repourl}" tmp_clone &>/dev/null
    pushd tmp_clone &>/dev/null
    git checkout master &>/dev/null
    echo "Latest commit in master branch: "$(git log --max-count=1 | grep "^commit")
    echo -e "*****\n"
    popd &>/dev/null
    rm -rf tmp_clone
done
