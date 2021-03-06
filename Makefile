PACKAGES 	= glib-2.0 gtk+-3.0 granite libxml-2.0 libarchive unity libsoup-2.4
SOURCES 	= $(wildcard src/*.vala)
UI_SOURCES  = $(wildcard data/ui/*.ui)
PRG 		= de.hannenz.parole

#CC 			= gcc
VALAC 		= valac
#CFLAGS 		= -W -Wall
VALAFLAGS	= -D WITH_GRANITE --target-glib=2.38 -X -lssl -X -lcrypto -X -lgmp -X -g 
#LDFLAGS		=

VALAFLAGS 	+= $(PACKAGES:%=--pkg=%)
#CFLAGS 		+= $(shell pkg-config --cflags $(PACKAGES))
#LDFLAGS 	+= $(shell pkg-config --libs $(PACKAGES))

#CSOURCES 	= $(SOURCES:.vala=.c)
#OBJS 		= $(CSOURCES:.c=.o)

# parole: $(OBJS)
# 	$(CC) $^ -o $@ $(LDFLAGS)

# %.o: %.c
#  	$(CC) $^ -c -o $@ -fPIC $(CFLAGS)

# %.c: %.vala
#  	$(VALAC) $^ -C -o $@ $(VALAFLAGS)

$(PRG):	$(SOURCES) src/generator.c src/resources.c
	$(VALAC) -o $@ $^  $(VALAFLAGS) --gresources data/parole.gresource.xml 

src/resources.c: $(UI_SOURCES) data/parole.gresource.xml data/parole.css
	cd data ; glib-compile-resources parole.gresource.xml --target=../src/resources.c --generate-source

install: $(PRG)
	install -m 644 data/de.hannenz.parole.desktop /usr/share/applications/
	install $(PRG) /usr/local/bin/

run: $(PRG)
	./$(PRG)

rundebug: $(PRG)
	G_MESSAGES_DEBUG=all ./$(PRG)

clean:
	rm src/*.vala.c
