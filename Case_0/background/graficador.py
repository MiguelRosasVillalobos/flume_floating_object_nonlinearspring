import pandas as pd
import matplotlib.pyplot as plt

# Ruta del archivo CSV
csv_file = '6dof_positions.csv'

# Cargar los datos del CSV
data = pd.read_csv(csv_file)

# Extraer el tiempo y la posición del centro de masa en z
times = data['Time']
com_z = data['Centre_of_mass_z']

# Graficar la posición del centro de masa en z vs el tiempo
plt.figure(figsize=(10, 6))
plt.plot(times, com_z, marker='o', linestyle='-', color='b')
plt.xlabel('Time (s)')
plt.ylabel('Centre of Mass Position (z)')
plt.title('Centre of Mass Position (z) vs Time')
plt.grid(True)
plt.show()
