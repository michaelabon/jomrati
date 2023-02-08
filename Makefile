.PHONY: run clean build/output.pdx

run: build/output.pdx
	open build/output.pdx

build/Output.pdx:
	pdc source build/output.pdx

clean:
	rm build/*