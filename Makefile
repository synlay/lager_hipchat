REBAR3 = ./rebar3

.PHONY: compile clean distclean test release

all: compile

compile:
	@$(REBAR3) compile

clean:
	@$(REBAR3) clean

distclean: clean
	@rm -rf _build

test:
	@$(REBAR3) eunit

release:
	@$(REBAR3) release
