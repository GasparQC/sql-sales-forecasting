import os

import pyodbc
from sklearn.linear_model import LinearRegression
import numpy as np

# --- Parámetros de conexión ---
# Credenciales por variables de entorno (antes estaban escritas en el código)
server = os.environ.get('SQL_SERVER', '.')
database = os.environ.get('SQL_DATABASE', 'Ventas2')
username = os.environ['SQL_USER']
password = os.environ['SQL_PASSWORD']

# Conexión a la base de datos
cnxn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    f'SERVER={server};DATABASE={database};UID={username};PWD={password}'
)
cursor = cnxn.cursor()

# --- Solicitar año y mes a estimar ---
ano = int(input("Ingrese el año a analizar (ej: 2005): "))
mes_estimado = int(input("Ingrese el mes a estimar (1-12): "))

# --- Calcular los 5 meses anteriores ---
meses_hist = []
anos_hist = []

for i in range(5, 0, -1):
    mes = mes_estimado - i
    if mes >= 1:
        meses_hist.append(mes)
        anos_hist.append(ano)
    else:
        meses_hist.append(12 + mes)
        anos_hist.append(ano - 1)

# --- Validar y obtener datos históricos ---
años_necesarios = set(anos_hist)
ventas_por_año = {}

for a in años_necesarios:
    query = """
        SELECT [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
        FROM TableroVentas
        WHERE Año = ?
    """
    cursor.execute(query, a)
    row = cursor.fetchone()
    if row is None:
        print(f"No hay datos disponibles para el año {a}.")
        cursor.close()
        cnxn.close()
        exit()
    ventas_por_año[a] = list(row)

# --- Armar vector de datos históricos ---
datos = []
for a, m in zip(anos_hist, meses_hist):
    valor = ventas_por_año[a][m - 1]  # columna m-1 (porque está en una lista de 0 a 11)
    if valor is None:
        print(f"Faltan datos para {a}-{str(m).zfill(2)}.")
        cursor.close()
        cnxn.close()
        exit()
    datos.append(valor)

# --- Aplicar regresión lineal ---
X = np.arange(1, 6).reshape(-1, 1)  # puntos 1 a 5
y = np.array(datos)

modelo = LinearRegression()
modelo.fit(X, y)

# Estimar el punto 6 (el mes deseado)
X_pred = np.array([[6]])
estimado = modelo.predict(X_pred)[0]

# --- Mostrar resultados ---
print("\n📊 Datos históricos utilizados:")
for i, (a, m, v) in enumerate(zip(anos_hist, meses_hist, datos), start=1):
    print(f"Punto {i}: {a}-{str(m).zfill(2)} = {round(v, 2)}")

print(f"\n📈 Estimación para {ano}-{str(mes_estimado).zfill(2)}: {round(estimado, 2)}")

# --- Cerrar conexión ---
cursor.close()
cnxn.close()
