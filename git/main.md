# Commands

## config proxy on git
```bash
set http_proxy=http://cvc_dm\mtzcpd262:SENHA@http://cvcproxy01.cvc.com.br:8080
set https_proxy=http://cvc_dm\mtzcpd262:SENHA@http://cvcproxy01.cvc.com.br:8080
```

### git submodule add 
```bash
git submodule add git@git.cvc.com.br:Desenvolvimento-SOA/GTW_LAMBDA_LIB_COMMONS.git lib/commons

git submodule add git@git.cvc.com.br:Desenvolvimento-SOA/api-tests/LIB_TEST_API.git lib/test-api
```

## Clone with submodules
```bash
git clone git@git.cvc.com.br:Desenvolvimento-SOA/GTW_LAMBDA_LOCATIONS.git --recursive
cd GTW_LAMBDA_LOCATIONS
git checkout develop
git submodule init
git submodule update
git submodule foreach git checkout develop
git submodule foreach git fetch origin/remote/develop
echo foi!
```

## .sh Clone with submodules
```bash
REPO_GIT=$1
REPO_GIT=${REPO_GIT:-GTW_LAMBDA_LIB_COMMONS}

BRANCH_GIT=$2
BRANCH_GIT=${BRANCH_GIT:-develop}

echo 
echo REPO_GIT ..... $REPO_GIT
echo BRANCH_GIT ... $BRANCH_GIT
echo 

read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	git clone git@git.cvc.com.br:Desenvolvimento-SOA/$REPO_GIT.git --recursive
	cd $REPO_GIT
	git submodule update --init --recursive
	git checkout $BRANCH_GIT
	git submodule init
	git submodule update
	git submodule foreach git checkout $BRANCH_GIT
fi
```

