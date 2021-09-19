#!/usr/bin/env bash

SCRIPT="$0"

FUNCTION=
if [ ! -z $1 ]; then
    FUNCTION="$1"
fi

showHelp() {
    echo "usage: ./make [install] [apply-fixtures] [run-tests]"
    echo ""
    echo "description:"
    echo "      install         - clone project from github repository, run containers and initial scripts"
    echo "      apply-fixtures  - apply database fixtures"
    echo "      run-tests       - run codeception tests"
}

create(){
    mkdir app
    cd app
    git clone https://github.com/helpit33/feedback.git .
    cd ..
}
init(){
    docker exec -it feedback-app ./init --env=Development --overwrite=n
}
install(){
    create
    start
    init
    composer-install
    migrate
}
composer-install(){
    docker exec -it feedback-app composer install
}

update(){
    docker exec -it feedback-app composer update
}
migrate(){
    docker exec -it feedback-app ./yii migrate --interactive=0
}
apply-fixtures(){
    docker exec -it feedback-app ./yii fixture/load '*' --interactive=0
}
run-tests(){
    docker exec -it feedback-app ./vendor/bin/codecept run
}
bash(){
    docker exec -it feedback-app bash
}
start(){
    docker-compose up -d
    chown
    chmode-runtime
}
stop(){
    docker-compose stop
}
destroy(){
    docker-compose down
}
chown(){
    echo "Changing app's owner"
    sudo chown $USER:$USER -R app
}
chmode-runtime(){
    echo "Changing mode of application files"
    sudo chmod 777 -R app/frontend/runtime
    echo chmod 777 -R app/backend/runtime
    echo chmod 777 -R app/console/runtime
}


if [ ! -z $(type -t $FUNCTION | grep function) ]; then
    $1
else
    showHelp
fi