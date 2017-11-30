all:

clean:
	rm -rf _impactbatch.log iseconfig *_xdb

realclean: clean
	rm -rf output_files filter.filter *.ipf
