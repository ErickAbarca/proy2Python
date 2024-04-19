--SP de prueba para obtener todos los usuarios y probar la coenxión
ALTER PROCEDURE ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM usuario;
END
GO


CREATE PROCEDURE ObtenerUsuarioPorId
    @nombre_usuario VARCHAR(50),
    @password VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM usuario WHERE id = @id;
END
GO

CREATE PROCEDURE ObtenerIdPorNombre
    @nombre_usuario VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id FROM usuario WHERE username = @nombre_usuario;
END
GO


CREATE PROCEDURE ValidarCredenciales
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
        SET @rollback = 1;
        DECLARE @error_message NVARCHAR(2048) = ERROR_MESSAGE();
        DECLARE @error_number INT = ERROR_NUMBER();
        DECLARE @error_state INT = ERROR_STATE();
        DECLARE @error_severity INT = ERROR_SEVERITY();
        DECLARE @error_line INT = ERROR_LINE();
        DECLARE @error_procedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @current_datetime DATETIME = GETDATE();

        INSERT INTO [dbo].[dbError] ([idPostByUser], [number], [state], [severity], [line], [procedi], [message], [datetime])
        VALUES (NULL, @error_number, @error_state, @error_severity, @error_line, @error_procedure, @error_message, @current_datetime);

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


CREATE PROCEDURE GetPuestoId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM puesto WHERE id = @id;
END
GO

CREATE PROCEDURE GetPuestos
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

CREATE PROCEDURE GetMovimientosById
    @valorDocumento INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idEmpleado, idTipoMovimiento, fecha, monto, nuevoSaldo, idPostByUser, postInIp, postTime 
    FROM movimiento
    WHERE idEmpleado = @valorDocumento
END
GO

CREATE PROCEDURE ModificarEmpleado
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
        SET @rollback = 1;
        DECLARE @error_message NVARCHAR(2048) = ERROR_MESSAGE();
        DECLARE @error_number INT = ERROR_NUMBER();
        DECLARE @error_state INT = ERROR_STATE();
        DECLARE @error_severity INT = ERROR_SEVERITY();
        DECLARE @error_line INT = ERROR_LINE();
        DECLARE @error_procedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @current_datetime DATETIME = GETDATE();

        INSERT INTO [dbo].[dbError] ([idPostByUser], [number], [state], [severity], [line], [procedi], [message], [datetime])
        VALUES (NULL, @error_number, @error_state, @error_severity, @error_line, @error_procedure, @error_message, @current_datetime);

        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH

    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO

CREATE PROCEDURE ElimiEmpleado
    @valorDocumento VARCHAR(64)
AS
BEGIN
    DECLARE @rollback BIT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM [dbo].[empleado] WHERE [valorDocumento] = @valorDocumento)
        BEGIN
            DELETE FROM [dbo].[empleado]
            WHERE [valorDocumento] = @valorDocumento;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @rollback = 1;
        DECLARE @error_message NVARCHAR(2048) = ERROR_MESSAGE();
        DECLARE @error_number INT = ERROR_NUMBER();
        DECLARE @error_state INT = ERROR_STATE();
        DECLARE @error_severity INT = ERROR_SEVERITY();
        DECLARE @error_line INT = ERROR_LINE();
        DECLARE @error_procedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @current_datetime DATETIME = GETDATE();

        INSERT INTO [dbo].[dbError] ([idPostByUser], [number], [state], [severity], [line], [procedi], [message], [datetime])
        VALUES (NULL, @error_number, @error_state, @error_severity, @error_line, @error_procedure, @error_message, @current_datetime);

        IF @rollback = 1
            ROLLBACK TRANSACTION;
    END CATCH

    IF @rollback = 0
        COMMIT TRANSACTION;
END
GO