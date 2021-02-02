# Convert names of WHs to the list of deployable components
	# e.g. erfurt -> de.zalando:zalos-erfurt-backend,de.zalando:zalos-erfurt-frontend
	set -e -x
	ALL_APPS=$1
	ALL_ENVS=$2
	DEPLOY=$3


	app_array=($(echo $ALL_APPS | tr "," "\n"))


	env_array=($(echo $ALL_ENVS | tr "," "\n"))
	#Print the split string
	for ENVS in "${env_array[@]}"
	do
	    ENV=${ENVS%_*}
	    STAGE=${ENVS#*_}
	    # gather version in order to place the api version for the Sprocs
	    all_builds=""
	    for APP in "${app_array[@]}"
	    do
	        if [ ! -d "common/$APP/backend/deploy/src/main/patches/$ENV" ]
	        then
	            continue
	        fi
	        all_builds+="de.zalando:zalos-$APP-backend,de.zalando:zalos-$APP-frontend,"
	        cd common/$APP/backend/deploy
	        FULLVERSION=`printf 'VERSION=${project.version}\n0\n' | mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep '^VERSION'`
	        API="_r${FULLVERSION:8:2}_00_${FULLVERSION:11:2}_${DEPLOY:2:8}"
	        BE_SVC="zalos-$APP-backend-$STAGE-$DEPLOY:8080"
	        if [ "$STAGE" == "release-staging" ]; then BE_SVC="zalos-$APP-backend-staging-$DEPLOY":8080; fi
	        sed -e "s/{API}/${API}/" src/main/patches/$ENV/WEB-INF/classes/application.properties > application.properties1
	        sed -e "s/{zalosBeSVC}/${BE_SVC}/" application.properties1 > application.properties
	        rm application.properties1
	        cat application.properties
	        sed -e "s/{API}/${API}/" src/main/patches/$ENV/WEB-INF/classes/db_api_version.properties > db_api_version.properties
	        cat db_api_version.properties
	        cd ../../../../

	        cd common/$APP/frontend/deploy
	        sed -e "s/{zalosBeSVC}/${BE_SVC}/" src/main/patches/$ENV/WEB-INF/classes/application.properties > application.properties
	        cd ../../../../

	        # Override Properties
	        cp common/$APP/backend/deploy/application.properties common/$APP/backend/src/main/resources/
	        cp common/$APP/backend/deploy/db_api_version.properties common/$APP/backend/src/main/resources/
	        cp common/$APP/frontend/deploy/application.properties common/$APP/frontend/src/main/resources/
	        rm common/$APP/backend/deploy/application.properties
	        rm common/$APP/backend/deploy/db_api_version.properties
	        rm common/$APP/frontend/deploy/application.properties
	    done
	    all_builds_sanitized=`echo ${all_builds} | sed 's/.$//'`
	    # Build Zalos FE and BE
	    if [ -f "/proc/meminfo" ]; then cat /proc/meminfo; fi

	    docker run --net=host \
	      --memory 30G \
	      -v /etc/resolv.conf:/etc/resolv.conf \
	      -v $JAVA_HOME/lib/security/cacerts:$JAVA_HOME/jre/lib/security/cacerts \
	      -v /etc/ssl/certs/java/cacerts:/etc/ssl/certs/java/cacerts \
	      -v /etc/default/cacerts:/etc/default/cacerts \
	      -v $(pwd):/home/master \
	      -w /home/master \
	      pierone.stups.zalan.do/spoq/base-deps-zalos:latest -- \
	      mvn -Denforcer.skip=true -Ddbapi.version=${API} -B -pl $all_builds_sanitized -am package -DskipTests -Pk8s -PApplication

	    echo Docker/Maven exit code: $?

	    for APP in "${app_array[@]}"
	    do
	        if [ ! -d "common/$APP/backend/deploy/src/main/patches/$ENV" ]
	        then
	            continue
	        fi
	        cp common/$APP/backend/target/*.war build/app.war

	        cd build
	        sed -e "s/{APP}/${APP}/" -e "s/{ENV}/${STAGE}/" -e "s/{PART}/backend/" MANIFEST-template.MF > MANIFEST.MF
	        sed -e "s/{APP}/${APP}/" -e "s/{ENV}/${STAGE}/" -e "s/{PART}/backend/" pom-template.properties > pom.properties
	        docker build -t pierone.stups.zalan.do/grip/zalos-$APP-backend:${CDP_BUILD_VERSION}.$STAGE --build-arg APP_NAME=be .
	        docker push pierone.stups.zalan.do/grip/zalos-$APP-backend:${CDP_BUILD_VERSION}.$STAGE
	        rm MANIFEST.MF
	        rm pom.properties
	        rm app.war
	        cd ..

	        cp common/$APP/frontend/target/*.war build/app.war
	        cd build
	        sed -e "s/{APP}/${APP}/" -e "s/{ENV}/${STAGE}/" -e "s/{PART}/frontend/" MANIFEST-template.MF > MANIFEST.MF
	        sed -e "s/{APP}/${APP}/" -e "s/{ENV}/${STAGE}/" -e "s/{PART}/frontend/" pom-template.properties > pom.properties
	        docker build -t pierone.stups.zalan.do/grip/zalos-$APP-frontend:${CDP_BUILD_VERSION}.$STAGE --build-arg APP_NAME=ui .
	        docker push pierone.stups.zalan.do/grip/zalos-$APP-frontend:${CDP_BUILD_VERSION}.$STAGE
	        rm MANIFEST.MF
	        rm pom.properties
	        rm app.war
	        cd ..
	    done

	done