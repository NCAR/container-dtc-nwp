#! /bin/bash

source ${GITHUB_WORKSPACE}/.github/jobs/bash_functions.sh

# Check required arguments
if [ $# != 3 ]; then
   echo "ERROR: $0 requires 3 arguments:"
   echo "ERROR:   1. Software component name"
   echo "ERROR:   2. Docker image name"
   echo "ERROR:   3. Path to component Dockerfile"
   exit 1 
else
   COMPONENT=$1
   IMAGE_NAME=$2
   DOCKERFILE_PATH=$3
fi

# Check environment variables required to push
if [ -z ${DOCKER_USERNAME+x} ] || [ -z ${DOCKER_PASSWORD+x} ]; then
    echo "ERROR: DockerHub credentials not set!"
    exit 1 
fi

# Check required environment variables
if [ -z ${SOURCE_BRANCH+x} ] || [ -z ${BASE_IMAGE+x}  ] ||
   [ -z ${BUILD_BASE+x}   ]  || [ -z ${BUILD_IMAGE+x} ]; then
   echo "ERROR: Required environment variables not set!"
   echo "ERROR:    \${SOURCE_BRANCH} = \"${SOURCE_BRANCH}\""
   echo "ERROR:    \${BASE_IMAGE}    = \"${BASE_IMAGE}\""
   echo "ERROR:    \${BUILD_BASE}    = \"${BUILD_BASE}\""
   echo "ERROR:    \${BUILD_IMAGE}   = \"${BUILD_IMAGE}\""
   exit 1 
fi

CMD_LOGFILE=${GITHUB_WORKSPACE}/docker_build_${COMPONENT}.log

# Software component image
if [ "${BUILD_IMAGE}" == "true" ]; then

   # Base image: either build locally or pull
   if [ "${BUILD_BASE}" == "true" ]; then

      # Check for Dockerfile or Dockerfile_simple
      BASE_DOCKERFILE="Dockerfile"
      if [[ "${BASE_IMAGE}" =~ "simple" ]]; then
         BASE_DOCKERFILE="Dockerfile_simple"
      fi

      time_command docker build -t ${BASE_IMAGE} \
         -f ${GITHUB_WORKSPACE}/components/base/${BASE_DOCKERFILE}
   fi

   COMPONENT_IMAGE=dtcenter/container-dtc-nwp-dev:${COMPONENT}_${SOURCE_BRANCH}

   # Build the software component image
   time_command docker build -t ${COMPONENT_IMAGE} \
      -f ${GITHUB_WORKSPACE}/components/${DOCKERFILE_PATH}/Dockerfile \
      ${GITHUB_WORKSPACE}/components/${DOCKERFILE_PATH}

   # List the images
   time_command docker images

   # Push the image up the DockerHub
   echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
   time_command docker push ${COMPONENT_IMAGE}

else
   time_command echo "No work to be done for the \"${COMPONENT}\" component since \${BUILD_IMAGE} = ${BUILD_IMAGE}"
fi
