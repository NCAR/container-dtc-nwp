#! /bin/bash

# Run by GitHub Actions (in .github/workflows/testing.yml) to parse
# info from GitHub event and commit message from last commit before
# a push to determine which jobs to run and which to skip.

# set default status for jobs
build_base=false
build_wps_wrf=false
build_gsi=false
build_upp=false
build_python=false
build_met=false
build_metviewer=false
run_case_names="sandy"

# TODO: Check to see what files have changed and set flags accordingly

# check for specific build commands
if grep -q "ci-build-base" <<< "$commit_msg"; then
  build_base=true
fi
if grep -q "ci-build-wps-wrf" <<< "$commit_msg"; then
  build_wps_wrf=true
fi
if grep -q "ci-build-gsi" <<< "$commit_msg"; then
  build_gsi=true
fi
if grep -q "ci-build-upp" <<< "$commit_msg"; then
  build_upp=true
fi
if grep -q "ci-build-python" <<< "$commit_msg"; then
  build_python=true
fi
if grep -q "ci-build-met" <<< "$commit_msg"; then
  build_met=true
fi
if grep -q "ci-build-metviewer" <<< "$commit_msg"; then
  build_metviewer=true
fi

# if rebuilding the base image, rebuild all
if [ $build_base == "true" ]; then
  build_wps_wrf=true
  build_gsi=true
  build_upp=true
  build_python=true
  build_met=true
  build_metviewer=true
fi

# check for specific case names being requested
if grep -q "ci-run-case-" <<< "$commit_msg"; then
  run_case_names=`echo ${commit_msg}  | sed -r 's/ /\n/g' | \
                  grep "ci-run-case-" | sed -r 's/ci-run-case-//g' | \
                  sed -r 's/$/ /g'    | tr -d '\n'`
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
echo run_case_names=${run_case_names} >> job_control_status

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
echo ::set-output name=run_case_names::$run_case_names
