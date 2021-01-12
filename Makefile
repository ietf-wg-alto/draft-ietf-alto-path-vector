LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

to-snlab:
	cp *.md ../alto/ietf-drafts-and-slides/draft-pv
	cp *.txt ../alto/ietf-drafts-and-slides/draft-pv

draft-ietf-alto-path-vector-13.xml: draft-ietf-alto-path-vector.xml
	sed -e 's/draft-ietf-alto-path-vector-latest/draft-ietf-alto-path-vector-13/g' draft-ietf-alto-path-vector.xml > draft-ietf-alto-path-vector-13.xml

draft-gao-alto-new-transport-00.xml: draft-gao-alto-new-transport.xml
	sed -e 's/draft-gao-alto-new-transport-latest/draft-gao-alto-new-transport-00/g' draft-gao-alto-new-transport.xml > draft-gao-alto-new-transport-00.xml
