from flask import Flask, jsonify, request
import pyodbc

app = Flask(__name__)

def validar_usuario(nombre_usuario, contraseña):

    server = 'ERICKPC'
    database = 'prog2'
    username = 'hola'
    password = '12345678'
    conn_str = f'DRIVER=ODBC Driver 17 for SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'

    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    try:
        cursor.execute("EXEC ValidarUsuario ?, ?", nombre_usuario, contraseña)
        estado = cursor.fetchone()[0]
        return estado
    finally:

        cursor.close()
        conn.close()

@app.route('/validar_usuario', methods=['POST'])
def validar_usuario_endpoint():

    datos = request.get_json()
    nombre_usuario = datos.get('nombre_usuario')
    contraseña = datos.get('contraseña')

    resultado = validar_usuario(nombre_usuario, contraseña)

    return jsonify({'resultado': resultado})

if __name__ == '__main__':
    app.run(debug=True)
