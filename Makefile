.PHONY: run clean build/Output.pdx

run: build/Output.pdx
	open build/Output.pdx

build/Output.pdx:
	pdc source build/Output.pdx

clean:
	rm build/*