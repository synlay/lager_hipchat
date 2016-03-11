.PHONY: compile clean distclean test release

all: compile

compile:
	@rebar3 compile

clean:
	@rebar3 clean

distclean: clean
	@rm -rf _build

test:
	@rebar3 eunit

release:
	@rebar3 release
