#!/usr/bin/env bash
# Week 8 - CI/CD with GitHub Actions
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Local commands only. The CI/CD pipeline runs on GitHub Actions on every push.

# Task 1: Project setup
mkdir cloud-ci-cd-demo && cd cloud-ci-cd-demo
code .
git init
node --test
git add .
git commit -m "initial commit"
git remote add origin https://github.com/zionabyrke/cloud-ci-cd-demo.git
git push -u origin master

# Tasks 2-6: push triggers pipeline on each change
git add .
git commit -m "<describe change>"
git push
