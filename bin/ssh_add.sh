#!/usr/bin/env bash

eval $(ssh-agent)
ssh-add ~/.ssh/ucb.key
