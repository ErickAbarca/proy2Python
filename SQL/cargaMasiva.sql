ALTER PROCEDURE CargarDatosDesdeXML
    @DatosXML XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; 

        INSERT INTO puesto (nombre, salarioHora)
        SELECT
            puesto.value('@Nombre', 'varchar(64)') AS nombre,
            puesto.value('@SalarioxHora', 'money') AS salarioHora
        FROM @DatosXML.nodes('/Datos/Puestos/Puesto') AS Tbl(puesto);

        INSERT INTO tipoEvento (id, nombre)
        SELECT
            tipoEvento.value('@Id', 'int') AS id,
            tipoEvento.value('@Nombre', 'varchar(64)') AS nombre
        FROM @DatosXML.nodes('/Datos/TiposEvento/TipoEvento') AS Tbl(tipoEvento);

        INSERT INTO tipoMovimiento (id, nombre, tipoAccion)
        SELECT
            tipoMovimiento.value('@Id', 'int') AS id,
            tipoMovimiento.value('@Nombre', 'varchar(64)') AS nombre,
            tipoMovimiento.value('@TipoAccion', 'char(1)') AS tipoAccion
        FROM @DatosXML.nodes('/Datos/TiposMovimientos/TipoMovimiento') AS Tbl(tipoMovimiento);

        INSERT INTO error (codigo, descripcion)
        SELECT
            error.value('@Codigo', 'int') AS codigo,
            error.value('@Descripcion', 'varchar(64)') AS descripcion
        FROM @DatosXML.nodes('/Datos/Error/error') AS Tbl(error);

        INSERT INTO empleado (idPuesto, valorDocumento, nombre, fechaContratacion, saldoVacaciones, esActivo)
        SELECT
            (SELECT id FROM puesto WHERE nombre = empleado.value('@Puesto', 'varchar(64)')) AS idPuesto,
            empleado.value('@ValorDocumentoIdentidad', 'nvarchar(20)') AS ValorDocumentoIdentidad,
            empleado.value('@Nombre', 'nvarchar(64)') AS Nombre,
            empleado.value('@FechaContratacion', 'date') AS FechaContratacion,
            0 AS SaldoVacaciones,
            1 AS EsActivo
        FROM @DatosXML.nodes('/Datos/Empleados/empleado') AS Tbl(Empleado);

        INSERT INTO usuario (id, username, password)
        SELECT
            usuario.value('@Nombre', 'int') AS id,
            usuario.value('@Username', 'nvarchar(64)') AS username,
            usuario.value('@Password', 'nvarchar(64)') AS password
        FROM @DatosXML.nodes('/Datos/Usuarios/usuario') AS Tbl(usuario);

        INSERT INTO movimiento (idEmpleado, idTipoMovimiento, fecha, monto, nuevoSaldo, idPostByUser, postInIp, postTime)
        SELECT
            (SELECT id FROM empleado WHERE valorDocumento = movimiento.value('@ValorDocumentoIdentidad', 'nvarchar(20)')) AS idEmpleado,
            movimiento.value('@IdTipoMovimiento', 'int') AS idTipoMovimiento,
            movimiento.value('@Fecha', 'datetime') AS fecha,
            movimiento.value('@Monto', 'money') AS monto,
            0 AS nuevoSaldo,
            movimiento.value('@IdPostByUser', 'int') AS idPostByUser,
            movimiento.value('@PostInIp', 'nvarchar(15)') AS postInIp,
            movimiento.value('@PostInDate', 'datetime') AS postInDate
        FROM @DatosXML.nodes('/Datos/Movimientos/movimiento') AS Tbl(movimiento);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        ROLLBACK TRANSACTION;
    END CATCH;
END
