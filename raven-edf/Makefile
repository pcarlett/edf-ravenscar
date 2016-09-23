CC=leon-elf-gnatmake
FLAGS=-a
# SOURCES=s-bb.ads s-bbbosu.adb s-bbbosu.ads s-bbcaco.adb s-bbcaco.ads s-bbcppr.adb s-bbcppr.ads s-bbdead.adb s-bbdead.ads s-bbexti.adb s-bbexti.ads s-bbinte.adb s-bbinte.ads s-bbpara.ads s-bbprot.adb s-bbprot.ads s-bbsule.ads s-bbthqu.adb s-bbthqu.ads s-bbthre.adb s-bbthre.ads s-bbtiev.adb s-bbtiev.ads s-bbtime.adb s-bbtime.ads s-osinte.ads s-taprob.adb s-taprob.ads s-taprop.adb s-taprop.ads s-tarest.adb s-tarest.ads s-taskin.adb s-taskin.ads s-tposen.adb s-tposen.ads system.ads
SOURCES= *.ad*
# OUTPUT=-aO`./lib/`
# DEBUG=-aI`./debug/`
# DEBUG=-gnatD
DEBUG='-g' '-O0'

all: libs

libs:
	$(CC) $(FLAGS) $(DEBUG) $(SOURCES)
	# $(CC) $(FLAGS) $(DEBUG) $(OUTPUT) $(SOURCES)

clean:
	rm *o *ali
