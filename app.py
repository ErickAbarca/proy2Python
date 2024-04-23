from flask import Flask, jsonify, redirect, render_template, request, url_for
from flask_cors import CORS
import pyodbc
import datetime

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
            resultados = cursor.fetchall()
            return resultados
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

@app.route('/GetTipoMovimientos', methods=['GET'])
def obtener_tipos_movimiento():
    tipos_movimiento = ejecutar_stored_procedure('GetTipoMovimientos')
    tipos_movimiento_json = []
    
    for tm in tipos_movimiento:
        tipo_movimiento_json = {
            'id': tm[0],
            'nombre': tm[1],
        }
        tipos_movimiento_json.append(tipo_movimiento_json)
    
    return jsonify(tipos_movimiento_json)


@app.route('/validar', methods=['GET'])
def validar_credenciales():
    
    username = request.args.get('username')
    password = request.args.get('password')

    resultado = ejecutar_stored_procedure('ValidarCredenciales', f"'{username}', '{password}'")

    if resultado[0][0] == 'Usuario válido':
        return redirect(url_for('pagina_principal', username=username))
    else:
        return jsonify({'error': 'Usuario inválido'}), 401

@app.route('/pagina_principal/<username>')
def pagina_principal(username):
    return render_template('index.html', username=username)



@app.route('/logout')
def logout():
    return render_template('login.html')

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
            username = request.form['idPostByUser']
            idPostByUser = ejecutar_stored_procedure('ObtenerIdPorNombre', f"'{username}'")[0][0]
            inIp = request.remote_addr


            parametros = f"{idPuesto}, '{valorDocumento}', '{nombre}', '{fechaContratacion}', {saldoVacaciones}, {esActivo}, {idPostByUser}, '{inIp}'"
            ejecutar_stored_procedure("InsertarEmpleado", parametros)

            return jsonify({'message': 'Datos ingresados correctamente'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

@app.route('/modificaremp', methods=['GET'])
def abrir_modificar_empleado():
    username = request.args.get('username')
    documento = request.args.get('documento')
    return render_template('modificaremp.html', username=username, documento=documento)

@app.route('/modificaremp', methods=['POST'])
def modificar_empleado():
    if request.method == 'POST':
        try:
            print(request.form)
            # Obtener los datos del formulario
            valorDocumento = request.form['valorDocumento']
            idPuesto = request.form['idPuesto']
            nombre = request.form['nombre']
            fechaContratacion = request.form['fechaContratacion']
            saldoVacaciones = int(request.form['saldoVacaciones'])
            esActivo = int(request.form.get('esActivo', 0))
            username = request.form['idPostByUser']
            idPostByUser = ejecutar_stored_procedure('ObtenerIdPorNombre', f"'{username}'")[0][0]
            inIp = request.remote_addr
            parametros = f"{idPuesto}, '{valorDocumento}', '{nombre}', '{fechaContratacion}', {saldoVacaciones}, {esActivo}, {idPostByUser}, '{inIp}'"
            ejecutar_stored_procedure("ModificarEmpleado", parametros) 
            return jsonify({'message': 'Datos modificados correctamente'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500
        
        
@app.route('/eliminaremp', methods=['POST'])
def eliminar_empleado():
    try:
        username = request.args.get('username')
        documento = request.args.get('documento')
        user = ejecutar_stored_procedure('ObtenerIdPorNombre', f"'{username}'")[0][0]
        inIp = request.remote_addr
        ejecutar_stored_procedure('ElimiEmpleado', f"'{documento}', '{user}', '{inIp}'")
        
        return jsonify({'message': 'Empleado eliminado correctamente'})
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
            'saldoVacaciones': e[5]
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
            'fechaContratacion': str(e[3]),
            'esActivo': e[4],
            'saldoVacaciones': e[5],
            'id': e[6],
            'idPuesto': str(e[0])
        }
        empleados_json.append(empleado_json)
    return jsonify(empleados_json)
    
        
@app.route('/movimientoemp', methods=['GET'])
def abrir_movimiento_empleado():
    username = request.args.get('username')
    documento = request.args.get('documento')
    return render_template('movimientos.html', username=username, documento=documento)

@app.route('/movimientos', methods=['GET'])
def ver_movimientos_empleado():
    if request.method == 'GET':
        try:
            valorDocumento = request.args.get('documento')
            movimientos_empleado = ejecutar_stored_procedure('GetMovimientosById', valorDocumento)
            movimientos_json = []
            for m in movimientos_empleado:
                movimiento_json = {
                    'idEmpleado': ejecutar_stored_procedure('GetEmpleadoById', f"'{m[0]}'")[0][1],
                    'idTipo': m[1],
                    'tipo': ejecutar_stored_procedure('GetTipoMovimientoById', f"{m[1]}")[0][0],
                    'fecha': m[2],
                    'monto': m[3],
                    'nuevoSaldo': m[4],
                    'idPostbyUser': m[5],
                    'postInIp': m[6],
                    'postTime': m[7]
                }
                movimientos_json.append(movimiento_json)
            empleado = ejecutar_stored_procedure('GetFiltroEmpleadosDoc', f"'{valorDocumento}'")
            return jsonify(movimientos_json)
        except Exception as e:
            return jsonify({'error': str(e)}), 500


@app.route('/insertmovimiento', methods=['GET'])
def abrir_insertar_movimiento_empleado():
    username = request.args.get('username')
    documento = request.args.get('documento')
    return render_template('insertarMovimiento.html', username=username, documento=documento)


@app.route('/insertarmovimiento', methods=['POST'])
def insertar_movimiento():
    if request.method == 'POST':
        try:
            valorDocumento = request.form['valorDocumento']
            idMovimiento = request.form['idMovimiento']
            monto = request.form['monto']
            saldo = request.form['saldoVacaciones']
            idPostByUser = request.form['idPostByUser']
            postInIp = request.remote_addr
            idEmpleado = ejecutar_stored_procedure('GetFiltroEmpleadosDoc', f"'{valorDocumento}'")[0][6]
            user = ejecutar_stored_procedure('ObtenerIdPorNombre', f"'{idPostByUser}'")[0][0]
            idEmpleado = int(idEmpleado)

            tipoMovimientos = ejecutar_stored_procedure('GetTipoMovimientoById', idMovimiento)[0][1]
            if tipoMovimientos == 'C':
                saldo = int(saldo) + int(monto)
            else:
                saldo = int(saldo) - int(monto)

            fechaHora = datetime.datetime.now()

            fechaHora = fechaHora.isoformat(timespec='milliseconds')
            fechaHora = fechaHora.replace('T', ' ')
            fecha = datetime.datetime.now().strftime('%Y-%m-%d')
            parametros = f"{idEmpleado}, {idMovimiento}, '{fecha}', {monto}, {saldo}, {user}, '{postInIp}', '{fechaHora}'"
            ejecutar_stored_procedure("InsertarMovimiento", parametros)
            return jsonify({'message': 'Movimiento ingresado correctamente'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)