#!/bin/bash
export SOURCE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# in case SOURCE_BRANCH is HEAD, we want to have the tag instead
# taken from https://stackoverflow.com/questions/3404936/show-which-git-tag-you-are-on
if [ ${SOURCE_BRANCH} = "HEAD" ]
then
    export SOURCE_BRANCH=$(git describe --tags)
fi

for i in benchmark-baseimage benchmark_chloroextractor benchmark_fast-plast benchmark_GetOrganelle benchmark_IOGA benchmark_NOVOPlasty benchmark_org-asm benchmark_chloroplast_assembly_protocol
do
	cd ${i};
	export DOCKER_REPO=chloroextractorteam/$(echo $i | tr "A-Z" "a-z");
	export IMAGE_NAME="${DOCKER_REPO}":${SOURCE_BRANCH}

	./hooks/build &>/dev/zero

	if [ $? -ne 0 ]
	then
		echo "$i FAIL"
	else
		echo "$i PASS"
		docker push ${IMAGE_NAME}
		./hooks/post_push
	fi

	cd $OLDPWD
done
