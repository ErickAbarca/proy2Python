ALTER PROCEDURE ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM usuario;
END

GO

-- SP para obtener un usuario por id
CREATE PROCEDURE ObtenerUsuarioPorId
    @nombre_usuario VARCHAR(50),
    @password VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM usuario WHERE id = @id;
END

GO
-- Procedimiento almacenado para validar las credenciales de inicio de sesión
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

-- Procedimiento almacenado para insertar un nuevo empleado en la base de datos
CREATE PROCEDURE InsertarEmpleado
    @IdPuesto VARCHAR(50),
    @ValorDocumentoIdentidad NVARCHAR(50),
    @Nombre VARCHAR(50),
    @FechaContratacion DATE,
    @SaldoVacaciones INT,
    @EsActivo BIT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO empleado (IdPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion, SaldoVacaciones, EsActivo)
    VALUES (@IdPuesto, @ValorDocumentoIdentidad, @Nombre, @FechaContratacion, @SaldoVacaciones, @EsActivo);
END

