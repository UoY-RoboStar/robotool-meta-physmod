# robotool-meta [![CI](https://github.com/UoY-RoboStar/robotool-meta/actions/workflows/build.yml/badge.svg)](https://github.com/UoY-RoboStar/robotool-meta/actions/workflows/build.yml)
This repository contains self-contained RoboTool releases, including a JRE, ready for download.

A release is built using Eclipse's Tycho Maven plug-in by compiling all plug-ins in context at once. A change
in the main branch leads to a build followed by automated testing, and, if successful, deployment of the 
RoboTool product as a GitHub release in this repository and the corresponding 
[update site](https://robostar.cs.york.ac.uk/robotool/stable/update/) is updated.