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
    @IdPuesto int,
    @ValorDocumentoIdentidad VARCHAR(64),
    @Nombre VARCHAR(64),
    @FechaContratacion DATE,
    @SaldoVacaciones INT,
    @EsActivo BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO empleado (idPuesto, valorDocumento, nombre, fechaContratacion, saldoVacaciones, esActivo)
        VALUES (@IdPuesto, @ValorDocumentoIdentidad, @Nombre, @FechaContratacion, @SaldoVacaciones, @EsActivo);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
GO

ALTER PROCEDURE GetEmpleados
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo 
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



ALTER PROCEDURE GetFiltroEmpleadosDoc
    @valorDocumento int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo 
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
    SELECT idPuesto, valorDocumento, nombre, fechaContratacion, esActivo 
    FROM empleado
    WHERE nombre LIKE '%' + @nombre + '%'
    ORDER BY nombre ASC;
END
GO

