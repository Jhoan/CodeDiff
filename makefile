#makekefile for build the ProyProc.js
NAMES=Function Program main
SOURCES=$(addsuffix .rb,$(addprefix ./,$(NAMES)))

all: clean
	cat $(SOURCES) > CodeDiff.rb

clean:
	rm -rf CodeDiff.rb
