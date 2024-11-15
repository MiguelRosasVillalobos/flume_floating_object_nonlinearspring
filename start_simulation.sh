#!/bin/bash
#Miguel Rosas

# Leer valores desde el archivo parametros.txt
# n=$(grep -oP 'n\s*=\s*\K[\d.+-]+' parameters.txt)

# Obtiene la cantidad desde el primer argumento
cantidad=1

# Bucle para crear y mover carpetas, editar y genrar mallado
for ((i = 1; i <= $cantidad; i++)); do
  # Genera el nombre de la carpeta
  nombre_carpeta="Case_$i"

  # Crea la carpeta del caso
  mkdir "$nombre_carpeta"

  # Copia carpetas del caso dentro de las carpetasgeneradas
  cp -r "Case_0/background" "$nombre_carpeta/"
  cp -r "Case_0/overSetWaves" "$nombre_carpeta/"

  # ddir=$(pwd)
  # sed -i "s|\$ddir|$ddir|g" "./$nombre_carpeta/extract_freesurface_plane.py"

  # Realiza el intercambio en el archivo
  # valor_a="${valores_a[i - 1]}"
  # sed -i "s/\$i/$i/g" "$nombre_carpeta/extract_freesurface_plane.py"
  # sed -i "s/\$i/$i/g" "$nombre_carpeta/extractor.py"
  # sed -i "s/\$nn/$n/g" "$nombre_carpeta/constant/porosityProperties"
  # sed -i "s/\$nn/$n/g" "$nombre_carpeta/system/setFieldsDict"

  mkdir ./$nombre_carpeta/overSetWaves/constant
  mkdir ./$nombre_carpeta/overSetWaves/constant/triSurface

  cp ./geometry/body.stl ./$nombre_carpeta/overSetWaves/constant/triSurface
  cd "$nombre_carpeta/overSetWaves"
  blockMesh >blockMesh.log
  snappyHexMesh -overwrite >snappyHexMesh.log
  cd ..

  cd ./background
  blockMesh >blockMesh.log
  mergeMeshes . ../overSetWaves/ -overwrite >mergeMeshes.log
  topoSet >topoSet.log
  setFields >setFields.log
  decomposePar >decomposePar.log
  mpirun -np 6 overInterDyMFoam -parallel >log
  cd ../..
done

echo "Proceso completado."
