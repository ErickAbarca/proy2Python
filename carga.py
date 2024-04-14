import pyodbc

import pyodbc

# Detalles de conexión
driver = '{ODBC Driver 17 for SQL Server}'
servidor = 'ERICKPC'
base_de_datos = 'prog2' 
autenticacion = 'UID=hola;PWD=12345678'

# Cadena de conexión
conn_str = f'DRIVER={driver};SERVER={servidor};DATABASE={base_de_datos};{autenticacion}'

# Conexión a la base de datos
conn = pyodbc.connect(conn_str)


# Ruta al archivo XML
ruta_xml = 'datos.xml'

# Leer el contenido del archivo XML
with open(ruta_xml, 'rb') as f:
    xml_content = f.read()


# Llamar al stored procedure y pasar el XML como parámetro
conn.execute("{CALL CargarDatosDesdeXML(?)}", xml_content)

# Confirmar la transacción
conn.commit()

# Cerrar la conexión
conn.close()
