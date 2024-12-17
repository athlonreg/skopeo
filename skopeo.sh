#!/bin/bash

#set -ex

KUBERNETES_VERSION=${KUBERNETES_VERSION:-v1.28.15}
KUBESPHERE_VERSION=${KUBESPHERE_VERSION:-v4.1.2}
IMAGES_LIST_FILE=${IMAGES_LIST_FILE:-images-list-mirrors-kubernetes-${KUBERNETES_VERSION}-kubesphere-${KUBESPHERE_VERSION}.txt}

REGISTRY=${REGISTRY:-ghcr.io}
REPOSITORY=${REPOSITORY:-library}
GITHUB_TOKEN=${GITHUB_TOKEN:-token}

for GROUP in $(cat ${IMAGES_LIST_FILE} | grep "##" | awk '{print $2}' | grep -vE "KubeSphere|Kubernetes")
do
	echo "start syncing image in group $GROUP"
	echo
  for IMAGE in $(cat ${IMAGES_LIST_FILE} | grep $GROUP -A 1000 | grep -v "## $GROUP" | sed '/##/,$d')
	do
		echo "syncing $IMAGE..."
		IMAGE_NAME=$(echo "$IMAGE" | awk -F '/' '{print $3}' | awk -F ':' '{print $1}')
		IMAGE_TAG=$(echo "$IMAGE" | awk -F '/' '{print $3}' | awk -F ':' '{print $2}')
		SRC=docker://$IMAGE
		DEST=docker://$REGISTRY/$REPOSITORY/$IMAGE_NAME:$IMAGE_TAG
		echo
		sleep 2
		if skopeo copy --src-creds $HUAWEI_TOKEN --dest-creds $GITHUB_TOKEN --multi-arch all --override-os linux ${SRC} ${DEST}
		then
		  echo "Process: sync $SRC to $DEST successfully"
		else
		  echo "$SRC sync failed"
		  exit 1
		fi
		sleep 1
	done
	echo "image in group $GROUP has synced successfully"
	sleep 2
done
