#!/bin/bash

# testify.sh - Check of je programma werkt op de gespecificeerde testcases
# Deze code staat onder de WTFPL versie 2 (zie COPYING)
# (Maar het zou fijn zijn als je eventuele veranderingen zou doorsturen)

# Geschreven door Tim Baanen (http://vierkantor.com, vierkantor@vierkantor.com)
# https://github.com/Vierkantor/StomTester

# Benodigdheden:
# 1. De testcases in folders genummerd per opdracht, genaamd <test>.in en <test>.out per paar voorbeeld in- en outputs
# 2. Je programma in dezelfde folder als de testcase, genaamd main.cs
# 3. Mono en bijbehorende compiler (mono en gmcs)

# Lees argumenten in
entry=$1;

# Check of we wel alle argumenten weten
if [ "${entry}" == "" ]; then
	echo "Usage: testify.sh <entry>";
	exit 1;
fi

# Compileer de hap
if !(mcs ${entry}/main.cs -out:${entry}/main.exe); then
	# Of error en stop
	echo "COMPILE ERROR";
	exit 2;
fi

# Run de hap
for test in ${entry}/*.in; do
	# Zoek de echte testnaam op
	test=$(basename ${test} .in);
	
	# Voer de test uit
	if !(mono ${entry}/main.exe < ${entry}/${test}.in > test.out); then
		# Erroren
		echo "RUN ERROR";
		
		# Opschonen
		rm ${entry}/main.exe;
		
		# En stoppen
		exit 3;
	fi
	
	# (Ruim de executable op)
	rm ${entry}/main.exe;
	
	# En check of dat klopt
	if !(diff test.out ${entry}/${test}.out); then
		# Erroren
		echo "WRONG ANSWER";
		
		# Opschonen
		rm test.out;
		
		# En stoppen
		exit 4;
	fi
done

echo "CORRECT";
exit 0;
