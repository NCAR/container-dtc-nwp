#! /bin/bash

# Run by GitHub Actions (in .github/workflows/testing.yml) to parse
# info from GitHub event and commit message from last commit before
# a push to determine which jobs to run and which to skip.

# set default status for jobs
build_all=false # rebuild all the software component images but not the base image
build_base=false
build_wps_wrf=false
build_gsi=false
build_upp=false
build_python=false
build_met=false
build_metviewer=false
run_sandy=true

# determine comparison version
if [ "${GITHUB_EVENT_NAME}" == "pull_request" ]; then
  ref_version="origin/${GITHUB_BASE_REF}"
elif [ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]; then
  ref_version=''
else
  ref_version=${reference_sha}
fi

# get list of modified files
diff_files=`git diff --name-only ${ref_version}`
echo "Modified files (git diff --name-only ${ref_version}):"
echo ${diff_files}
echo

# check for ci-build-base
if grep -q "ci-build-base" <<< "$commit_msg"; then
  echo "Build base and all the software component images since ci-build-base is in the commit message."
  build_base=true
fi

# handle workflow dispatch
if [ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]; then
  if [ "${force_build_base}" == "true" ]; then
    echo "Workflow dispatch: Build the base image and all the software component images."
    build_base=true
  fi
  if [ "${force_build_wps_wrf}" == "true" ]; then
    echo "Workflow dispatch: Build the WPS/WRF image."
    build_wps_wrf=true
  fi
  if [ "${force_build_gsi}" == "true" ]; then
    echo "Workflow dispatch: Build the GSI image."
    build_gsi=true
  fi
  if [ "${force_build_upp}" == "true" ]; then
    echo "Workflow dispatch: Build the UPP image."
    build_upp=true
  fi
  if [ "${force_build_python}" == "true" ]; then
    echo "Workflow dispatch: Build the Python image."
    build_python=true
  fi
  if [ "${force_build_met}" == "true" ]; then
    echo "Workflow dispatch: Build the MET image."
    build_met=true
  fi
  if [ "${force_build_metviewer}" == "true" ]; then
    echo "Workflow dispatch: Build the METviewer image."
    build_metviewer=true
  fi
  if [ "${force_run_sandy}" == "true" ]; then
    echo "Workflow dispatch: Run the Sandy case."
    run_sandy=true
  fi

# check for ci-build-all
elif grep -q "ci-build-all" <<< "$commit_msg"; then
  echo "Build all the software component images since ci-build-all is in the commit message."
  build_all=true

# check for specific build commands
else
  if grep -q "ci-build-wps-wrf" <<< "$commit_msg"; then
    echo "Build the WPS/WRF image since ci-build-wps-wrf is in the commit message."
    build_wps_wrf=true
  fi
  if grep -q "ci-build-gsi" <<< "$commit_msg"; then
    echo "Build the GSI image since ci-build-gsi is in the commit message."
    build_gsi=true
  fi
  if grep -q "ci-build-upp" <<< "$commit_msg"; then
    echo "Build the UPP image since ci-build-upp is in the commit message."
    build_upp=true
  fi
  if grep -q "ci-build-python" <<< "$commit_msg"; then
    echo "Build the Python image since ci-build-python is in the commit message."
    build_python=true
  fi
  if grep -q "ci-build-met" <<< "$commit_msg"; then
    echo "Build the MET image since ci-build-met is in the commit message."
    build_met=true
  fi
  if grep -q "ci-build-metviewer" <<< "$commit_msg"; then
    echo "Build the METviewer image since ci-build-metviewer is in the commit message."
    build_metviewer=true
  fi
fi

# check diff files
if grep -q "components/base/" <<< "$diff_files"; then
  echo "Build base and all the software component images since components/base has changed."
  build_base=true
fi
if grep -q "components/wps_wrf/" <<< "$diff_files"; then
  echo "Build the WPS/WRF image since components/wps_wrf has changed."
  build_wps_wrf=true
fi
if grep -q "components/gsi/" <<< "$diff_files"; then
  echo "Build the GSI image since components/gsi has changed."
  build_gsi=true
fi
if grep -q "components/upp/" <<< "$diff_files"; then
  echo "Build the UPP image since components/upp has changed."
  build_upp=true
fi
if grep -q "components/python/" <<< "$diff_files"; then
  echo "Build the Python image since components/python has changed."
  build_python=true
fi
if grep -q "components/met/" <<< "$diff_files"; then
  echo "Build the MET image since components/met has changed."
  build_met=true
fi
if grep -q "components/metviewer/" <<< "$diff_files"; then
  echo "Build the METviewer image since components/metviewer has changed."
  build_metviewer=true
fi

# rebuild all software components but not the base image
if [ $build_all == "true" ] || [ $build_base == "true" ]; then
  build_wps_wrf=true
  build_gsi=true
  build_upp=true
  build_python=true
  build_met=true
  build_metviewer=true
fi

# get branch name
branch_name=`${GITHUB_WORKSPACE}/.github/jobs/print_branch_name.py`

# build job control output file
touch job_control_status
echo branch_name=${branch_name} >> job_control_status
echo build_base=${build_base} >> job_control_status
echo build_wps_wrf=${build_wps_wrf} >> job_control_status
echo build_gsi=${build_gsi} >> job_control_status
echo build_upp=${build_upp} >> job_control_status
echo build_python=${build_python} >> job_control_status
echo build_met=${build_met} >> job_control_status
echo build_metviewer=${build_metviewer} >> job_control_status
echo run_sandy=${run_sandy} >> job_control_status

echo
echo Job Control Settings:
cat job_control_status

echo ::set-output name=branch_name::$branch_name
echo ::set-output name=build_base::$build_base
echo ::set-output name=build_wps_wrf::$build_wps_wrf
echo ::set-output name=build_gsi::$build_gsi
echo ::set-output name=build_upp::$build_upp
echo ::set-output name=build_python::$build_python
echo ::set-output name=build_met::$build_met
echo ::set-output name=build_metviewer::$build_metviewer
echo ::set-output name=run_sandy::$run_sandy
