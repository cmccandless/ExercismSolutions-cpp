MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))
CWD := $(shell pwd)

ifeq ($(MAKEFILE_DIR),$(CWD))

EXERCISES := $(notdir $(patsubst %/,%,$(dir $(abspath $(shell find . -type d -name .exercism)))))
CLEAN_TARGETS := $(addprefix clean-,$(EXERCISES))

.PHONY: $(EXERCISES) $(CLEAN_TARGETS)

all: test

test: $(EXERCISES)
$(EXERCISES):
	make --directory=$@ --makefile=../Makefile test
clean: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	make --directory=$(patsubst clean-%,%,$@) --makefile=../Makefile clean

else

EXERCISE := $(notdir $(CWD))
BINARY := .build/$(EXERCISE)
SOURCES := $(shell find . -maxdepth 1 -type f -iname '*.cpp')
HEADERS := $(shell find . -maxdepth 1 -type f \( -iname '*.h' -o -iname '*.hpp' \))
CMAKE_OUTPUT := .build/Makefile

.PHONY: clean print-env

print-env:
	@ echo "EXERCISE=$(EXERCISE)"
	@ echo "BINARY=$(BINARY)"
	@ echo "SOURCES=$(SOURCES)"
	@ echo "HEADERS=$(HEADERS)"

test: $(BINARY)
$(BINARY): $(CMAKE_OUTPUT) $(HEADERS) $(SOURCES)
	make --directory=.build/

$(CMAKE_OUTPUT): CMakeLists.txt
	@ mkdir -p .build/ > /dev/null
	cd .build/ && cmake -G "Unix Makefiles" ..

clean:
	rm -rf .build/

endif
