CREATE PROCEDURE ValidarUsuario
    @username VARCHAR(64),
    @password VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT;

    -- Verificar si el usuario y la contraseña coinciden
    SELECT @id = id
    FROM usuarios
    WHERE username = @username
    AND password = @password;

    -- Si se encuentra un usuario con el ID mayor que cero, significa que existe
    IF @id IS NOT NULL
    BEGIN
        SELECT 'Usuario válido' AS Estado;
    END
    ELSE
    BEGIN
        SELECT 'Usuario inválido' AS Estado;
    END
END
