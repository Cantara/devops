Update/New Installation 
===================
These scripts will query Nexus for the latest verision found on your maven repository (nexus).
When the version on nexus is different than the version currently installed, or when no version is actually installed:
* The artifact will be downloaded
* Java Service Wrapper will install this artifact on your Windows machine.

Installation
============

* Set host and port to nexus in install-latest-module-jsw.bat
* Set package and artifact in update-artifact.bat
* run update-artifact.bat


