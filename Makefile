.PHONY: setup run

M ?= 01_mochila

run:
	julia --project=. modelos/$(M)/main.jl modelos/$(M)/input.txt

setup:
	julia --project=. -e 'using Pkg; Pkg.instantiate()'