#!/bin/bash

#Constance
OUTPUT_PATH=".output"

#Variables
USER=$(echo $event_json | jq '.pull_request.user.login' | sed 's/"//g') #User who created hotfix-PR
REPO_FULLNAME=$(echo $event_json | jq '.repository.full_name' | sed 's/"//g') #Username + repositoryname

#Create PR
function create_pr ()
{
  TITLE="develop merged by $USER" #Title for PR
  RESPONSE_CODE=$(curl \
    -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_FULLNAME/pulls \
    --data "{\"title\":\"$TITLE\",\"body\":\"merge\",\"head\":\"$BASE\",\"base\":\"$TARGET\"}") #Create PR over REST API and get repsonse code
  newPR_NUMBER=$(cat $OUTPUT_PATH | jq '.number') #Number of new PR
  echo "PR response: $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" -ne "201" ]]; #Check if PR worked
  then  
    echo "Could not create PR";
    exit 1;
  else
    echo "Created PR";
  fi
}

#Merge PR
function merge_pr ()
{
  TITLE="develop merge by $USER" #Title for merge
  RESPONSE_CODE=$(curl \
    -o $OUTPUT_PATH -s -w "%{http_code}\n" \
    -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_FULLNAME/pulls/$newPR_NUMBER/merge \
    --data "{\"commit_title\":\"$TITLE\",\"commit_message\":\"Automated Merge by $USER\"}") #Merge PR and get repsonse code
  echo "Merge response: $RESPONSE_CODE"
  if [[ "$RESPONSE_CODE" -ne "200" ]]; #Check if merge worked
  then  
    echo "Could not merge PR";
    exit 2;
  else
    echo "Merged PR";
  fi
}

#Checks
function check_token_is_defined() #Check if Github Token is defined
{
  if [[ -z "$GITHUB_TOKEN" ]];
  then
    echo "Undefined GITHUB_TOKEN environment variable."
    exit 3
  fi
}

function check_validate() #Execute checks
{
  check_token_is_defined
}

#main function
function main()
{
  check_validate
  create_pr
  merge_pr
}

#Execute main
main