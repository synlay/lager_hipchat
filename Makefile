REBAR3 = ./rebar3

.PHONY: compile clean distclean test release dialyzer ci coveralls travis_ci

all: compile

compile:
	@$(REBAR3) compile

clean:
	@$(REBAR3) clean

distclean: clean
	@rm -rf _build

ci: test dialyzer

travis_ci: ci coveralls

test:
	@$(REBAR3) eunit

dialyzer:
	@$(REBAR3) dialyzer

coveralls:
	@$(REBAR3) as test coveralls send

release:
	@$(REBAR3) release
