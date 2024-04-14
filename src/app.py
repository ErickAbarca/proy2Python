from flask import Flask, jsonify, redirect, request, url_for
from flask_cors import CORS
import pyodbc
import json

app = Flask(__name__)
CORS(app)

def ejecutar_stored_procedure(nombre_sp, parametros=None):
    
    server = 'ERICKPC'
    database = 'prog2'
    username = 'hola'
    password = '12345678'
    conn_str = f'DRIVER=ODBC Driver 17 for SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'

    
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    try:
        if parametros:
            cursor.execute(f"EXEC {nombre_sp} {parametros}")
        else:
            cursor.execute(f"EXEC {nombre_sp}")
        
        resultado = cursor.fetchall()
        return resultado
    finally:
        cursor.close()
        conn.close()

@app.route('/usuarios', methods=['GET'])
def obtener_usuarios():
    
    usuario = ejecutar_stored_procedure('ObtenerUsuarios')
    
    usuarios = []
    for u in usuario:
        usuariox = {
            'id': u[0],
            'nombre_usuario': u[1],
            'contraseña': u[2],
        }
        usuarios.append(usuariox)
    return json.dumps(usuarios)


@app.route('/validar', methods=['GET'])
def validar_credenciales():
    
    username = request.args.get('username')
    password = request.args.get('password')

    resultado = ejecutar_stored_procedure('ValidarCredenciales', f"'{username}', '{password}'")

    if resultado[0][0] == 'Usuario válido':
        return redirect(url_for('pagina_exitosa'))
    else:
        return redirect(url_for('pagina_error'))

@app.route('/exitoso', methods=['GET'])
def pagina_exitosa():
    # Redireccionar a la página exitosa.html si las credenciales son válidas
    return redirect('/index..html')

@app.route('/error', methods=['GET'])
def pagina_error():
    # Redireccionar a la página error.html si las credenciales son inválidas
    return redirect('/error.html')

if __name__ == '__main__':
    app.run(debug=True)