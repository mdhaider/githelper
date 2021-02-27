#!/bin/zsh

# version: 1.0
# description: script for updating commit ids for any repository and its submodules
# author: nehal

# system requirements: install Github CLI

# how to configure: [steps below]
#step 1: download file [keep the file name as is]
#step 2: locate .gitconfig file by 1. go to home directory [shortcut cmd+shift+h]  2. unhide files [shortcut cmd+shift+.]
#step 3: paste under alias, replace by your username xyz= ! bash -c \"source /Users/mdnehaluddinhaider/Documents/githelper.sh && git_cup\"

# how to use: [steps below]
#if commit id branch exists: git ez {branch_name} replace "branch_name" with your branch name
#if commit id branch exists: git ez {branch_name} replace "branch_name" with your branch name

############################### script here, please do not modify any code #####################################

#color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

#text variables
underline=$(tput smul)
nounderline=$(tput rmul)
bold=$(tput bold)
normal=$(tput sgr0)

function main() {
    clear
    echo "=============== STARTING COMMIT ID UPDATE PROCESS ============"

    # check if user entered branch name
    existing_branch_name="$1"
    run_checks
}

function run_checks() {
    echo "********* running few checks**********"
    check_details
}

function check_details() {
    if [ ! -n "$existing_branch_name" ]; then
        ref20=0
        echo "************** you chose us to provide the branch name ************"
    else
        ref20=1
        echo "************** you have entered branch name: $existing_branch_name ************"
        if ! git checkout $existing_branch_name; then
            printf "\e[31m \xe2\x9d\x8c status~invalid_branch_name solution~please try again with correct branch name or just leave empty\e[m\n"
            exit 1
        else
            echo "******* branch name is valid *********"
        fi

    fi

    check_git_repo
}

function check_git_repo() {
    if ! git branch --show-current; then
        printf "\e[31m \xe2\x9d\x8c status~not_in_git_repo reason~current directory do not points to any repo. try again\e[m\n"
        exit 1
    else
        echo "******* in a git repository *********"
    fi
    check_tree_clean
}

function check_tree_clean() {
    if [[ $(git diff --stat) != '' ]]; then
        printf "\e[31m \xe2\x9d\x8c status~dirty_directory solution~to continue please commit/stash/revert any local changes in the current branchand try again\e[m\n"
        exit 1
    else
        echo "******* working directory is clean *********"

        select_another_repo

        if [ $ref13 == 1 ]; then
        update_branches
       else
        pr_creation_2
    
    fi

    fi
}

function select_another_repo() {
    ref10=$(basename $(git rev-parse --show-toplevel))
    if [ $ref10 == "ecomm-b2c-android" ]; then
        var11=j4u-b2c-android
        another_repo=$var11
    else
        var12=ecomm-b2c-android
        another_repo=$var12
    fi

    while true; do
        read -r -p "Do you want to create pr for $another_repo too? [Y/n] " input
        case $input in
        [yY][eE][sS] | [yY])
            echo "***** you have decided to create pr for $another_repo *****"
            ref13=1
            break
            ;;
        [nN][oO] | [nN])
            echo "***** you have decided not to create pr for $another_repo *****"
            ref13=0
            break
            ;;
        *)
            printf "===Invalid input...===\n"
            ;;
        esac
    done

    submodule_selection
}

function submodule_selection() {
    echo "**** submdule selection started ****"
    clear
    oldifs="$IFS"
    IFS=$'\n'
    subArray=($(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'))
    IFS="$oldifs"
    echo "Select submodule for which commit id needs to update?"

    select option in "${subArray[@]}"; do
        echo "****** submodule selected $option ******"
        update_branches $option
        break
    done
}

function update_branches() {
    result=$1
    ref=$(git branch --show-current)
    echo "***** current branch: $ref ********"
    git stash

    if [ $ref == "master" ]; then
        echo "******** already on master branch *******"
    else
        git checkout master
        echo "*********** master checked out **********"
    fi

    ref1=$(basename $(git remote get-url origin) .git)
    if [ $ref1 == "ecomm-b2c-android" ]; then
        echo "*************** in shop repo ************"
        git pull origin master
        echo "************* master updated *************"
    else
        echo "*********** in loyalty repo **************"
        git pull
        echo "************* master updated *************"
    fi

    git submodule sync
    git submodule update --init --recursive

    echo "************* submodules updated *************"

    clear

    branch_creation
}

function branch_creation() {
    if [ $ref20 != 0 ]; then
        branchName=$existing_branch_name
    else
        now="$(date +"%m-%d_%y_%H-%M-%S")"
        branchName=commit-id-update_$now
    fi

    if ! git checkout -b $branchName; then
        echo "******** branch name you provided really exists, so will continue on your branch $existing_branch_name ********"
        git checkout $branchName
    else
        echo "******** either you have not provded branch name or entered non-existent branch name, don't worry we will create one for you ********"
        git push -u origin $branchName
        echo "******** we have created branch with name: $branchName  ********"
    fi
    echo "**** $branchName branch checked out ****"
    submodule_entry
}

function submodule_entry() {
    submodule_name=$(tr '[A-Z]' '[a-z]' <<<$result)
    echo "****** entering in $submodule_name module now *****"
    dirs -c
    pushd $result
    echo "***** entered in $submodule_name module now *****"
    submodule_updation
}

function submodule_updation() {
    ref2=$(git symbolic-ref --short HEAD)
    echo "***** $submodule_name submodule initial branch: $ref2 *****"
    if [[ $ref2 == "main" || $ref2 == "master" ]]; then
        git pull origin main || git pull origin master
    else
        git checkout main || git checkout master
        git pull origin main || git pull origin master
    fi

    ref4=$(git symbolic-ref --short HEAD)
    echo "***** updated branch $ref4 for $submodule_name submodule ******"
    echo "****** leaving  $submodule_name submodule ********"

    submodule_exit
}

function submodule_exit() {
    popd
    echo "****** back to primary module *****"
    push_commit_changes
}

function push_commit_changes() {
    ref7=$(git diff $ref6)
    clear
    echo "$ref7"
    if [[ -n "${ref7// /}" ]]; then
        git add $result
        now="$(date +'%F')"
        git commit -m "commit id update for submodule: $submodule_name"
        git push
        clear
        echo "***** changes commited and pushed ******"
        pr_creation

    else
        printf "\e[31m \xE2\x9C\x94 status~no_change_found reason~looks like submodule $result and main module points to same commit ids"
    fi
}

function pr_creation() {
    echo "***** starting pr creation process using github CLI ******"
    now="$(date +"%m-%d-%Y")"
    gh pr create -t "[commit_id_update] [$submodule_name] on $now" -b "Updated commit id for $result" -r sudheepnair20,gsams04

    if [ $ref13 == 0 ]; then
        printf "\e[32m \xE2\x9C\x94 **** we're done....check the pr link above\e[m\n"
        exit 1
    else
        pr_creation_2
        ref13=0
    fi
}

function pr_creation_2() {
    cd ..
    oldifs1="$IFS"
    IFS1=$'\n'
    subArray1=($(ls))
    IFS1="$oldifs1"
    echo "Select your $another_repo directory?"

    select option in "${subArray1[@]}"; do
        echo "****** selected repo $option *******"
        cd $option
        checking_branch
        break
    done

}

function checking_branch() {
    while true; do
        read -r -p "Do you have branch available for $another_repo too? [Y/n] " br_available

        case $br_available in
        [yY][eE][sS] | [yY])
            echo "***** seems you have branch ready for $another_repo *****"
            read -p "Enter branch name(without quotes): " branch_name1
            git checkout $branch_name1
            until expr "$?" : "[0]"; do
                echo "Invalid, please enter correct branch name"
                read -p "Enter branch name(without quotes): " branch_name1 </dev/tty
                git checkout $branch_name1 </dev/tty
            done

            main $branch_name1

            break
            ;;
        [nN][oO] | [nN])
            echo "***** no worries, we will create one branch for $another_repo now *****"
            main
            break
            ;;
        *)
            printf "===Invalid input...===\n"
            ;;
        esac
    done
}

######################################## script ends #################################################################
