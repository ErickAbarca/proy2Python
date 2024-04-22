ALTER PROCEDURE InsertarEmpleado
    @idPuesto INT,
    @valorDocumento VARCHAR(64),
    @nombre VARCHAR(64),
    @fechaContratacion DATE,
    @saldoVacaciones INT,
    @esActivo BIT,
    @idPostByUser INT,
    @inIp VARCHAR(64),

    @outResultCode INT OUTPUT
    
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @outResultCode = 0;

        IF NOT EXISTS (SELECT 1 FROM [dbo].[empleado] WHERE [valorDocumento] = @valorDocumento)
            AND NOT EXISTS (SELECT 1 FROM [dbo].[empleado] WHERE [nombre] = @nombre)
        BEGIN
            BEGIN TRANSACTION tInsertEmpleado;
                INSERT INTO [dbo].[empleado] (
                    [idPuesto]
                    ,[valorDocumento]
                    ,[nombre]
                    ,[fechaContratacion]
                    ,[saldoVacaciones]
                    ,[esActivo])
                VALUES (@idPuesto, 
                        @valorDocumento, 
                        @nombre, 
                        @fechaContratacion, 
                        @saldoVacaciones, 
                        @esActivo);
            
                INSERT INTO [dbo].[bitacoraEvento] 
                ([idTipoEvento],
                [descripcion],
                [idPostByUser], 
                [postInIp], 
                [postTime])

                VALUES (6, 
                    'Doc: ' + @valorDocumento + 
                    ' Nombre: ' + @nombre + 
                    ' Puesto: ' + (SELECT nombre FROM puesto WHERE id = @idPuesto), 
                    @idPostByUser, 
                    @inIp, 
                    GETDATE()
                );
            COMMIT TRANSACTION tInsertEmpleado;
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM [dbo].[empleado] WHERE [valorDocumento] = @valorDocumento)
            BEGIN
                SET @outResultCode = 50006;
            END
            ELSE
            BEGIN
                SET @outResultCode = 50005;
            END
        END;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tInsertEmpleado;
      
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

        INSERT INTO dbo.bitacoraEvento
            ([idTipoEvento],
            [descripcion],
            [idPostByUser], 
            [postInIp], 
            [postTime])

            VALUES (5, 
                    'Error: '+(SELECT descripcion FROM error WHERE codigo = @outResultCode) + 
                    'Nombre: ' + @nombre + ' Doc: ' + @valorDocumento + 
                    ' Puesto: ' + (SELECT nombre FROM puesto WHERE id = @idPuesto),
                    @idPostByUser, 
                    @inIp, 
                    GETDATE()
            );

        SET @outResultCode = 50005;
    END CATCH

    SET NOCOUNT OFF;
END
GO