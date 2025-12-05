#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

ARCHIVO="usuarios.csv" #Guarda el nombre del fichero que contiene los usuarios
LOG="/var/log/gestion_usuarios.log" #Guarda la ruta donde almacenamos el registro

mkdir -p /home/.eliminados # Crea el directorio para los usuarios que vamos a eliminar

while IFS= ',' read usuario grupo operacion; do # Creamos un bucle que lea el archivo csv por línea
	fecha=$(date '+%Y-m-%d %H:%M:%S') # Con esto imprimimos el momento exacto de cuando se llevo a cabo cada operación
	if [ "$operacion" = "add" ]; then # Comprueba al ejecutar add si el usuario ya existe
		if id "$usuario" &>/dev/null; then # Comprueba en el sistema si existe el usuario
			echo "[$fecha] - ERROR - $usuario ya existe en  el sistema" >> $LOG # Genera un mensaje de error en caso de que si que exista

			getent group "$grupo" &>/dev/null || groupadd "$grupo" # Comprueba si el grupo existe, si no es así lo crea
			useradd -m -g "$grupo" -s /bin/bash "$usuario" # creacion del usuario, -m sirve para crear su carpeta hoome -g sirve para asignarle al grupo -s para asignar shell bash
				echo "[$fecha] - Usuario_Creado - $usuario" >> $LOG # Registra en el log la creación del usuario
			fi

				elif [ "$operacion" = "rm" ];  then # Si se ejecuta la operacion rm y se comprueba que el usuario existe
					if id "$usuario" &>/dev/null; then
						usermod -L "$usuario"	# Ejecuta la accion de bloquear a su usuario y mueve su home para evitar crear conflictos usermod -L bloquea usuarios y -d verifica la existencia de la carpet
						[  -d "/home/$usuario" ] && mv "/home/$usuario" "/home/.eliminados/$usuario" # Si lo anterior ha funcionado entonces moverá la carpeta.
							echo "[$fecha] -Usuario_Eliminado - $usuario" >> $LOG # Registra que el usuario ha sido eliminado en el log.
				else
					echo "[$fecha] - Error_RM - $usuario no existe" >> $LOG # Si el usuario no existe se registra el error en el log

					fi
				fi

		done < "$ARCHIVO" # Sirve para cerrar tanto el bucle como el if

		echo "Proceso completado. Ver log: $LOG" # Muestra mensaje final indicandole al usuario donde se ve el resultado
