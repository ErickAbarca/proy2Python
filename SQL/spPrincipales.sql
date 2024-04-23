ALTER PROCEDURE ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM usuario;
END
GO

ALTER PROCEDURE ObtenerIdPorNombre
    @nombre_usuario VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id FROM usuario WHERE username = @nombre_usuario;
END
GO


ALTER PROCEDURE ValidarCredenciales
    @username VARCHAR(64),
    @password VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM usuario WHERE username = @username AND password = @password)
    BEGIN
        SELECT 'Usuario válido' AS Estado;
    END
    ELSE
    BEGIN
        SELECT 'Usuario inválido' AS Estado;
        
    END
END
GO

ALTER PROCEDURE InsertarEmpleado
    @idPuesto INT,
    @valorDocumento VARCHAR(64),
    @nombre VARCHAR(64),
    @fechaContratacion DATE,
    @saldoVacaciones INT,
    @esActivo BIT,
    @idPostByUser INT,
    @inIp VARCHAR(64)

AS
BEGIN
    DECLARE @rollback BIT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [dbo].[empleado] ([idPuesto], [valorDocumento], [nombre], [fechaContratacion], [saldoVacaciones], [esActivo])
        VALUES (@idPuesto, @valorDocumento, @nombre, @fechaContratacion, @saldoVacaciones, @esActivo);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.DBErrors	VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);

        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH

    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO


ALTER PROCEDURE GetEmpleados
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo, saldoVacaciones, id 
    FROM empleado
    ORDER BY nombre ASC;
END
GO


ALTER PROCEDURE GetPuestoId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, nombre, salarioHora FROM puesto WHERE id = @id;
END
GO

ALTER PROCEDURE GetPuestos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, nombre, salarioHora  FROM puesto;
END
GO

ALTER PROCEDURE GetFiltroEmpleadosDoc
    @valorDocumento int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo, saldoVacaciones, id
    FROM empleado
    WHERE CAST(valorDocumento AS VARCHAR(20)) LIKE '%' + CAST(@valorDocumento AS VARCHAR(20)) + '%'
    ORDER BY nombre ASC;

END
GO


ALTER PROCEDURE GetFiltroEmpleadosNombre
    @nombre VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo, saldoVacaciones, id
    FROM empleado
    WHERE nombre LIKE '%' + @nombre + '%'
    ORDER BY nombre ASC;
END
GO

ALTER PROCEDURE GetMovimientosById
    @valorDocumento VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idEmpleado, idTipoMovimiento, fecha, monto, nuevoSaldo, idPostByUser, postInIp, postTime 
    FROM movimiento
    WHERE idEmpleado = (SELECT id FROM empleado WHERE valorDocumento = @valorDocumento)
    ORDER BY fecha DESC;
    SET NOCOUNT OFF;
END
GO

ALTER PROCEDURE GetEmpleadoById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo, saldoVacaciones, id
    FROM empleado
    WHERE id = @id;
    SET NOCOUNT OFF;
END
GO

ALTER PROCEDURE GetTipoMovimientoById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nombre, tipoAccion FROM tipoMovimiento WHERE id = @id;
    SET NOCOUNT OFF;
END
GO

CREATE PROCEDURE GetTipoMovimientos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, nombre, tipoAccion FROM tipoMovimiento;
    SET NOCOUNT OFF;
END
GO

ALTER PROCEDURE ModificarEmpleado
    @idPuesto INT,
    @valorDocumento VARCHAR(64),
    @nombre VARCHAR(64),
    @fechaContratacion DATE,
    @saldoVacaciones INT,
    @esActivo BIT,
    @idPostByUser INT,
    @inIp VARCHAR(64)

AS
BEGIN
    DECLARE @rollback BIT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM [dbo].[empleado] WHERE [valorDocumento] = @valorDocumento)
        BEGIN
            UPDATE [dbo].[empleado]
                SET [idPuesto] = @idPuesto,
                    [nombre] = @nombre,
                    [fechaContratacion] = @fechaContratacion,
                    [esActivo] = @esActivo
                WHERE [valorDocumento] = @valorDocumento;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
       INSERT INTO dbo.DBErrors	VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);

        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH

    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO



ALTER PROCEDURE ElimiEmpleado
    @valorDocumento VARCHAR(64),
    @idPostByUser INT,
    @inIp VARCHAR(64)
AS
BEGIN
    DECLARE @rollback BIT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY

        BEGIN
            DELETE FROM [dbo].[empleado]
            WHERE [valorDocumento] = @valorDocumento;
        END
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.DBErrors	VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);
        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH
    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO


CREATE PROCEDURE InsertarMovimiento
    @idEmpleado INT,
    @idTipoMovimiento INT,
    @fecha DATE,
    @monto INT,
    @nuevoSaldo INT,
    @idPostByUser INT,
    @postInIp VARCHAR(64),
    @postTime DATETIME

AS
BEGIN
    DECLARE @rollback BIT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [dbo].[movimiento] ([idEmpleado], [idTipoMovimiento], [fecha], [monto], [nuevoSaldo], [idPostByUser], [postInIp], [postTime])
        VALUES (@idEmpleado, @idTipoMovimiento, @fecha, @monto, @nuevoSaldo, @idPostByUser, @postInIp, @postTime);
        UPDATE [dbo].[empleado]
            SET [saldoVacaciones] = @nuevoSaldo
        WHERE [id] = @idEmpleado;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.DBErrors	VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);

        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH

    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO