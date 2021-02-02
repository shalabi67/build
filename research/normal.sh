fix_prop(){
  echo "fix properties for application $1 and environment $2..."
  sleep 6
}

build_maven(){
  echo "Build maven for environment $1..."
  # 7 minutes
  sleep 420
}

publish() {
  echo "Publish for application $1 and environment $2..."
  # 1 min
  sleep 60
}

# Convert names of WHs to the list of deployable components
	# e.g. erfurt -> de.zalando:zalos-erfurt-backend,de.zalando:zalos-erfurt-frontend
	#set -e -x
	ALL_APPS=$1
	ALL_ENVS=$2
	DEPLOY=$3


	app_array=($(echo $ALL_APPS | tr "," "\n"))


	env_array=($(echo $ALL_ENVS | tr "," "\n"))

  echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	date
	#Print the split string
	for ENVS in "${env_array[@]}"
	do
	    ENV=${ENVS%_*}
	    STAGE=${ENVS#*_}
	    # gather version in order to place the api version for the Sprocs
	    all_builds=""
	    for APP in "${app_array[@]}"
	    do

	        fix_prop $APP, $ENV
	    done

	    build_maven $ENV

	    for APP in "${app_array[@]}"
	    do
	        echo backend
	        publish $APP, $ENV

	        echo frontend
	        publish $APP, $ENV
	    done

	done

	date