#!/bin/bash

# Archivo de log de OpenFOAM
logfile="log"

# Archivo CSV de salida
output_csv="6dof_positions.csv"

# Imprimir encabezado en el archivo CSV con columnas adicionales para las fuerzas
echo "Time,Centre_of_rotation_x,Centre_of_rotation_y,Centre_of_rotation_z,Centre_of_mass_x,Centre_of_mass_y,Centre_of_mass_z,Orientation_11,Orientation_12,Orientation_13,Orientation_21,Orientation_22,Orientation_23,Orientation_31,Orientation_32,Orientation_33,Fx,Fy,Fz" >$output_csv

# Extraer datos del log y escribir en el CSV
awk '
/^Time =/ { time = $3 }
/^6-DoF rigid body motion$/ { rigid_body_motion = 1 }
/^forces forces:/ { forces_block = 1 }
/Restraint nonlinearSpring:.*force \(/ && forces_block {
    match($0, /force \((-?[0-9.eE+-]+) (-?[0-9.eE+-]+) (-?[0-9.eE+-]+)\)/, force);
    fx = force[1]; fy = force[2]; fz = force[3];
    forces_block = 0  # Resetea el bloque de fuerzas después de la extracción
}
/^    Centre of rotation:/ && rigid_body_motion { cor = $4 " " $5 " " $6 }
/^    Centre of mass:/ && rigid_body_motion { com = $4 " " $5 " " $6 }
/^    Orientation:/ && rigid_body_motion { 
    orientation = $4 " " $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12
}
cor && com && orientation && fx && fy && fz {
    gsub(/[()]/, "", cor)  # Eliminar paréntesis
    gsub(/[()]/, "", com)
    gsub(/[()]/, "", orientation)
    cor = gensub(/ /, ",", "g", cor)
    com = gensub(/ /, ",", "g", com)
    orientation = gensub(/ /, ",", "g", orientation)

    # Escribir línea en el archivo CSV
    print time "," cor "," com "," orientation "," fx "," fy "," fz >> "'$output_csv'"

    # Limpiar variables después de cada entrada
    rigid_body_motion = 0
    cor = ""; com = ""; orientation = ""; fx = ""; fy = ""; fz = ""
}
' $logfile

echo "Extraction complete. Results saved in $output_csv."
