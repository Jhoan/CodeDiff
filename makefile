#makekefile for build the ProyProc.js
NAMES=Header Program Report main
SOURCES=$(addsuffix .rb,$(addprefix ./src/,$(NAMES)))

all: clean
	@cat $(SOURCES) > CodeDiff.rb
	@chmod 755 CodeDiff.rb

clean:
	@rm -rf CodeDiff.rb
