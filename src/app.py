from flask import Flask, jsonify, redirect, request, send_file, url_for
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
    usuarios = ejecutar_stored_procedure('ObtenerUsuarios')
    usuarios_json = []
    
    for u in usuarios:
        usuario_json = {
            'id': u[0],
            'nombre_usuario': u[1],
            'contraseña': u[2],
        }
        usuarios_json.append(usuario_json)
    
    return jsonify(usuarios_json)


@app.route('/validar', methods=['GET'])
def validar_credenciales():
    
    username = request.args.get('username')
    password = request.args.get('password')

    resultado = ejecutar_stored_procedure('ValidarCredenciales', f"'{username}', '{password}'")

    if resultado[0][0] == 'Usuario válido':
        print('Usuario válido')
        # Enviar la URL de redirección como parte de la respuesta
        return redirect(url_for('pagina_principal'))
    else:
        return redirect(url_for('pagina_error'))

@app.route('/pagina_principal')
def pagina_principal():
    # Especifica la ruta completa del archivo HTML
    archivo_html = '..\\Paginaweb\\index.html'
    
    # Envía el archivo HTML como respuesta
    return send_file(archivo_html)


#@app.route('/insertar', methods=['POST'])
def insertar_empleado():
    idPuesto = 1
    ValorDocumentoIdentidad = 1111
    nombre = "Nombre"
    FechaContratacion = "2021-01-01"
    SaldoVacaiones = 0
    EsActivo = 1

    ejecutar_stored_procedure('InsertarEmpleado', f"{idPuesto}, {ValorDocumentoIdentidad}, '{nombre}', '{FechaContratacion}', {SaldoVacaiones}, {EsActivo}")
    return jsonify({'mensaje': 'Empleado insertado correctamente'})



if __name__ == '__main__':
    app.run(debug=True)