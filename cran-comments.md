## Test environments
* local x86_64-w64-mingw32/x64 install, R 3.3.1
* Ubuntu 12.04 (on Travis CI), R devel, release and oldrel
* Windows on Appveyor CI (stable, patched and oldrel)

## R CMD check results

0 errors | 0 warnings | 0 note

## Release summary

* Better states the dependency on tibble, it is tibble >= 1.2.

* Better handles blank text in input, outputs an empty tibble and a warning if the request is only blank, and a message if only parts of the request are blank.

* Disables HTTP2 for now because of a bug for Windows users. Fix by Jeroen Ooms.


---
