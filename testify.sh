#!/bin/bash

# testify.sh - Check of je programma werkt op de gespecificeerde testcases
# Deze code staat onder de WTFPL versie 2 (zie COPYING)
# (Maar het zou fijn zijn als je eventuele veranderingen zou doorsturen)

# Geschreven door Tim Baanen (http://vierkantor.com, vierkantor@vierkantor.com)
# https://github.com/Vierkantor/StomTester

# Benodigdheden:
# 1. De testcases in folders genummerd per opdracht, genaamd <test>.in en <test>.out per paar voorbeeld in- en outputs
# 2. Je programma in dezelfde folder als de testcase, genaamd main.<extensie>, de volgende worden geaccepteerd:
#  C#: .cs
#  Haskell: .hs
# 3. De compiler en runtimes:
#  C#: Mono en bijbehorende compiler (mono en gmcs)
#  Haskell: GHC

# Lees argumenten in
entry=$1;

# Check of we wel alle argumenten weten
if [ "${entry}" == "" ]; then
	echo "Usage: testify.sh <entry>";
	exit 1;
fi

# Check ook of de opdracht wel bestaat
if !([ -e ${entry} ]); then
	echo "That entry doesn't actually exist.";
	exit 1;
fi

# Detecteer wat voor soort taal we doen (zie ook benodigdheid #2)
if [ -e ${entry}/main.cs ]; then # C#
	compile="mcs ${entry}/main.cs -out:${entry}/main.exe";
	run="mono ${entry}/main.exe";
	executable="${entry}/main.exe";
elif [ -e ${entry}/main.hs ]; then # Haskell
	compile="ghc --make -o main ${entry}/main.hs";
	run="./main";
	executable="main";
else
	echo "No source files found.";
	exit 1;
fi

# Compileer de hap
if !(${compile}); then
	# Of error en stop
	echo "COMPILE ERROR";
	exit 2;
fi

# Run de hap
for test in ${entry}/*.in; do
	# Zoek de echte testnaam op
	test=$(basename ${test} .in);
	
	echo "-------------";
	echo "Testing $test";
	
	# Voer de test uit
	if !(time ${run} < ${entry}/${test}.in > test.out); then
		# Erroren
		echo "RUN ERROR";
		
		# Opschonen
		rm ${executable};
		
		# En stoppen
		exit 3;
	fi
	
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
