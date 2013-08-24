#makekefile for build the ProyProc.js
NAMES=Function Program common main
SOURCES=$(addsuffix .rb,$(addprefix ./,$(NAMES)))

all: clean
	cat $(SOURCES) > CodeDiff.rb
	chmod 755 CodeDiff.rb

clean:
	rm -rf CodeDiff.rb
