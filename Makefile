REBAR3 = ./rebar3

.PHONY: compile clean distclean test release dialyzer ci

all: compile

compile:
	@$(REBAR3) compile

clean:
	@$(REBAR3) clean

distclean: clean
	@rm -rf _build

ci: test dialyzer

test:
	@$(REBAR3) eunit

dialyzer:
	@$(REBAR3) dialyzer

release:
	@$(REBAR3) release
