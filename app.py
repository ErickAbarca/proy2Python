from flask import Flask, jsonify, redirect, render_template, request, url_for, session
from flask_cors import CORS
import pyodbc
import json

app = Flask(__name__)
CORS(app)

def ejecutar_stored_procedure(nombre_sp, parametros=None):
    # Configuración de la conexión a la base de datos
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

        if cursor.description:
            resultado = cursor.fetchall()
            return resultado
        else:
            return None
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

@app.route('/GetPuestos', methods=['GET'])
def obtener_puestos():
    puestos = ejecutar_stored_procedure('GetPuestos')
    puestos_json = []
    
    for p in puestos:
        puesto_json = {
            'id': p[0],
            'nombre': p[1],
        }
        puestos_json.append(puesto_json)
    
    return jsonify(puestos_json)


@app.route('/validar', methods=['GET'])
def validar_credenciales():
    
    username = request.args.get('username')
    password = request.args.get('password')

    resultado = ejecutar_stored_procedure('ValidarCredenciales', f"'{username}', '{password}'")

    if resultado[0][0] == 'Usuario válido':
        return redirect(url_for('pagina_principal', username=username))
    else:
        return redirect(url_for('pagina_error'))

@app.route('/pagina_principal/<username>')
def pagina_principal(username):
    return render_template('index.html', username=username)


@app.route('/insertaremp', methods=['GET'])
def abrir_insertar_empleado():
    username = request.args.get('username')
    return render_template('insertaremp.html', username=username)



@app.route('/insertaremp', methods=['POST'])
def insertar_empleado():
    if request.method == 'POST':
        try:
            # Obtener los datos del formulario
            idPuesto = request.form['idPuesto']
            valorDocumento = request.form['valorDocumento']
            nombre = request.form['nombre']
            fechaContratacion = request.form['fechaContratacion']
            saldoVacaciones = request.form['saldoVacaciones']
            esActivo = request.form.get('esActivo', 0)

            parametros = f"{idPuesto}, '{valorDocumento}', '{nombre}', '{fechaContratacion}', {saldoVacaciones}, {esActivo}"
            ejecutar_stored_procedure("InsertarEmpleado", parametros)

            return jsonify({'message': 'Datos ingresados correctamente'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500



@app.route('/empleados', methods=['GET'])
def obtener_empleados():
    empleados = ejecutar_stored_procedure('GetEmpleados')
    empleados_json = []
    for e in empleados:
        empleado_json = {
            'puesto': ejecutar_stored_procedure('GetPuestoId', f"{e[0]}")[0][1],
            'valorDocumento': e[1],
            'nombre': e[2],
            'fechaContratacion': e[3],
            'esActivo': e[4],
            'id': e[5]
        }
        empleados_json.append(empleado_json)
    return jsonify(empleados_json)


@app.route('/empleados/filtro', methods=['GET'])
def filtro_doc():
    bus = request.args.get('search')
    if bus.isdigit():
        empleados = ejecutar_stored_procedure('GetFiltroEmpleadosDoc', f"{bus}")
        empleados_json = []
    else:
        empleados = ejecutar_stored_procedure('GetFiltroEmpleadosNombre', f"'{bus}'")
        empleados_json = []
    for e in empleados:
        empleado_json = {
            'puesto': ejecutar_stored_procedure('GetPuestoId', f"{e[0]}")[0][1],
            'valorDocumento': e[1],
            'nombre': e[2],
            'fechaContratacion': e[3],
            'esActivo': e[4],
            'id': e[5]
        }
        empleados_json.append(empleado_json)
    return jsonify(empleados_json)
    



if __name__ == '__main__':
    app.run(debug=True)