# Generate files for the 
file:= ToBeOveride

# linux or windows
system := linux

all:
ifeq ($(system) , linux)
	flutter pub run pigeon --input ./lib/pigeons/${file}
else 
ifeq ($(system) , windows)
	flutter pub run pigeon --input .\lib\pigeons\${file}
endif
endif