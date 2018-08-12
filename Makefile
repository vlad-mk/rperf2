LIBIPT_FOLDER=$(PWD)/processor-trace/
INSTRUMENTER_FOLDER=$(PWD)/instrumenter/
GSON_TESTER_FOLDER=$(PWD)/gson-tester/

CXX=/opt/rh/devtoolset-7/root/usr/bin/g++
CC=/opt/rh/devtoolset-7/root/usr/bin/gcc
OPTFLAGS?=-O0
CFLAGS=-g -pedantic -fpic
CFLAGS+=$(OPTFLAGS)


build-libipt:
	rm -rf $(LIBIPT_FOLDER)/build
	rm -rf $(LIBIPT_FOLDER)/install
	mkdir -p $(LIBIPT_FOLDER)/build
	mkdir -p $(LIBIPT_FOLDER)/install
	cd $(LIBIPT_FOLDER)/build ; cmake -DCMAKE_INSTALL_PREFIX=$(LIBIPT_FOLDER)/install -DCMAKE_BUILD_TYPE=Release ..
	make clean  install -C $(LIBIPT_FOLDER)/build -j8

build-instrumenter:
	cd $(INSTRUMENTER_FOLDER) ; mvn -Djavax.net.ssl.trustStore=/home/ruamnsa/dev/ET-XXXX-docker/scripts/cks.jks package

build-gson-tester:
	cd $(GSON_TESTER_FOLDER) ; mvn -Djavax.net.ssl.trustStore=/home/ruamnsa/dev/ET-XXXX-docker/scripts/cks.jks package$(INSTRUMENTER_FOLDER) ; mvn -Djavax.net.ssl.trustStore=/home/ruamnsa/dev/ET-XXXX-docker/scripts/cks.jks package

build-librperf2:
	cd librperf2 ; javah -cp ../instrumenter/target/classes/ ru.raiffeisen.PerfPtProf
	CC=$(CC) CXX=$(CXX) CFLAGS="$(CFLAGS)" make librperf2 -C librperf2

run-gson-tester:
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):librperf2:processor-trace/install/lib64 \
		java \
			-DTRIGGER_METHOD=decode \
			-DTRIGGER_CLASS=ru/raiffeisen/App \
			-DTRIGGER_COUNTDOWN=1000 \
			-DDUMP_OUT_CLASSES=true \
			-DOUTPUT_INSTRUMENTED_CLASSES=1 \
			-DPERCENTILE=0.99 \
			-agentlib:rperf2 \
			-javaagent:instrumenter/target/instrumenter-1.2-SNAPSHOT-jar-with-dependencies.jar \
			-cp gson-tester/target/json-tester-1.0-SNAPSHOT.jar:gson-tester/target/lib/gson-2.8.2.jar  \
			ru.raiffeisen.App

