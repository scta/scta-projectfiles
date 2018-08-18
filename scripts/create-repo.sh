#!/usr/bin/env bash
repo=$1
token=$2
topics=$3


curl -i -H "Authorization: token $token" \
    -d "{ \"name\": \"$repo\", \"auto_init\": true}" \
    https://api.github.com/orgs/scta-texts/repos

# curl -i -H "Authorization: token $token" \
#     -d "{ \"names\": [\"$topics\"]}" \
#     https://api.github.com/repos/scta-texts/$repo/topics
