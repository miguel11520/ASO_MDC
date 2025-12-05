#!/bin/bash

for ip in $(cat remotos.txt)
do
	echo "usuario" | scp usuarios.csv usuario@$ip:/home/usuario
done
