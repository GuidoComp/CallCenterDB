/* LISTA DE STORE PROCEDURES, FUNCIONES, TRIGGERS */

--CARGA DE ERROR MESSAGES PERSONALIZADOS:
exec sp_addmessage 50006, 10, "EL CLIENTE NO CUMPLE CON LAS VALIDACIONES REQUERIDAS", 'us_english'
exec sp_addmessage 50007, 14, "ERROR EN EL PROCESO DE ALTA DE CLIENTE", 'us_english'
exec sp_addmessage 50008, 10, "ERROR: CLIENTE INEXISTENTE", 'us_english'
exec sp_addmessage 50009, 10, "ERROR: EL CLIENTE DEBE TENER EMAIL Y FECHA DE NACIMIENTO", 'us_english'
exec sp_addmessage 50010, 11, "ERROR EN EL ALTA DEL SERVICIO", 'us_english'
exec sp_addmessage 50011, 11, "ERROR: SERVICIO INEXISTENTE", 'us_english'
exec sp_addmessage 50012, 11, "ERROR: EN LA BAJA DE LOS SERVICIOS", 'us_english'
exec sp_addmessage 50013, 9, "ERROR: TIPO DE DNI INVALIDO", 'us_english'
exec sp_addmessage 50014, 9, "ERROR: NRO DE DOCUMENTO INVALIDO", 'us_english'
exec sp_addmessage 50015, 9, "ERROR: CREACION DEL TICKET", 'us_english'
exec sp_addmessage 50016, 9, "ERROR: EL CLIENTE DEBE TENER NOMBRE Y APELLIDO", 'us_english'
exec sp_addmessage 50017, 10, "ERROR: USUARIO NO PERMITIDO PARA LA OPERACION", 'us_english'
exec sp_addmessage 50018, 10, "ERROR: TICKET INEXISTENTE", 'us_english'
exec sp_addmessage 50019, 10, "ERROR: NO SE PERMITE CERRAR EL TICKET", 'us_english'
exec sp_addmessage 50020, 12, "ERROR: EL ESTADO NO EXISTE", 'us_english'
exec sp_addmessage 50021, 17, "ERROR: MODIFICANDO EL ESTADO", 'us_english'
exec sp_addmessage 50022, 9, "ERROR: EL TICKET YA ESTA RESUELTO", 'us_english'
exec sp_addmessage 50023, 9, "ERROR: EL TICKET YA ESTA CERRADO", 'us_english'
exec sp_addmessage 50024, 9, "ERROR: CERRANDO EL TICKET", 'us_english'
exec sp_addmessage 50025, 9, "ERROR: EL USUARIO NO ESTA ACTIVO O NO EXISTE", 'us_english'
exec sp_addmessage 50026, 9, "ERROR: EL TICKET NO ESTA ABIERTO", 'us_english'
exec sp_addmessage 50027, 9, "ERROR: REASIGNADO EL TICKET", 'us_english'
exec sp_addmessage 50028, 9, "ERROR: EL USUARIO NO ES UN PROSPECTO", 'us_english'
exec sp_addmessage 50029, 11, "ERROR: ACTUALIZANDO LOS DATOS", 'us_english'
exec sp_addmessage 50030, 14, "ERROR: TRANSICION NO PERMITIDA", 'us_english'
exec sp_addmessage 50031, 10, "ERROR: EL TICKET DEBE ESTAR EN ESTADO 'RESUELTO'", 'us_english', @Replace = 'Replace';
exec sp_addmessage 50032, 12, "ERROR: EN EL CÁLCULO DEL SLA", 'us_english'
exec sp_addmessage 50033, 12, "ERROR: EL TELEFONO ES OBLIGATORIO PARA VOIP Y TELEFONIA FIJA", 'us_english'
exec sp_addmessage 50034, 9, "ERROR: EMAIL INVÁLIDO", 'us_english'
exec sp_addmessage 50035, 9, "ERROR: DEBE SER MAYOR DE 18 AÑOS", 'us_english'
exec sp_addmessage 50036, 9, "ERROR: CAMBIANDO EL DNI", 'us_english'
exec sp_addmessage 50037, 9, "ERROR: NO SE PERMITE CAMBIAR EL DNI A UN CLIENTE ACTIVO", 'us_english'
exec sp_addmessage 50038, 9, "ERROR: EL SERVICIO NO PERTENECE AL CLIENTE", 'us_english'

SELECT * from sys.messages order by message_id desc;

--STORE PROCEDURES:

CREATE OR ALTER PROCEDURE sp_ReporteError 
AS
    SELECT
	ERROR_NUMBER() AS ErrorNumber,
	ERROR_SEVERITY() AS ErrorSeverity,
	ERROR_PROCEDURE() AS ErrorProcedure,
	ERROR_MESSAGE() AS ErrorMessage;
GO

--Con todos los datos de un CLIENTE definidos en el DDL, hará las validaciones necesarias para intentar crearlo.
--Parámetros de salida error_code (int) y error_message (varchar) de acuerdo al punto 11 del TP.
CREATE OR ALTER PROCEDURE sp_InsertarCliente @TIPO_DNI VARCHAR(3), @NRO_DNI INT, @NOMBRE VARCHAR(30), @APELLIDO VARCHAR(30), @EMAIL VARCHAR(50) = NULL, @FECHA_NAC DATETIME = NULL, @error_code int = NULL output, @error_message nvarchar(100) = NULL  output
AS
	BEGIN TRY
		DECLARE @TIPO_DNIUPPER CHAR(3) = UPPER(@TIPO_DNI)
		DECLARE @ID_ESTADO_CLIENTE char(5) = 'PROSP'

		/* CHEQUEO DEL DNI*/
		IF ((@TIPO_DNI != 'DNI' and @TIPO_DNI != 'LC' and @TIPO_DNI != 'LE') or (@TIPO_DNI IS NULL OR @NRO_DNI IS NULL))
		BEGIN
			RAISError(50013, 9, 1);
			RETURN
		END
		/* CHEQUEO DEL NUMERO */
		IF (len(@NRO_DNI) > 8 or len(@NRO_DNI) < 7 or ISNUMERIC(@NRO_DNI)=0)
		BEGIN
			RAISError(50014, 9, 1);
			RETURN
		END
		/*CHEQUEO FORMATO EMAIL*/
		IF (@EMAIL IS NOT NULL and @EMAIL NOT LIKE '%[a-z,0-9]@[a-z,0-9]%.[A-Za-z]%[A-Za-z]')
		BEGIN
			RAISError(50034, 9, 1);
			RETURN
		END
		/*CHEQUEO EDAD*/
		IF (@FECHA_NAC IS NOT NULL and DATEDIFF(YEAR, @FECHA_NAC, GETDATE()) < 18)
		BEGIN
			RAISError(50035, 9, 1);
			RETURN
		END
		/*CHEQUEO NOMBRE Y APELLIDO*/
		IF ((@NOMBRE IS NOT NULL) AND (@APELLIDO IS NOT NULL))
		BEGIN
			INSERT INTO CLIENTES (TIPO_DNI, NRO_DNI, NOMBRE, APELLIDO, EMAIL, F_NACIMIENTO, id_estadoCliente)
			VALUES (@TIPO_DNIUPPER, @NRO_DNI, @NOMBRE, @APELLIDO, @EMAIL, @FECHA_NAC, @ID_ESTADO_CLIENTE)
			PRINT 'CLIENTE AGREGADO COMO PROSPECTO'
		END
		ELSE
			BEGIN
				--USAMOS EL ID DEL ERROR MESSAGE PERSONALIZADO
				RAISError(50016, 9, 1);
				RETURN
			END
	END TRY
	BEGIN CATCH
		RAISError(50007, 9, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		EXEC sp_ReporteError
	END CATCH
GO

CREATE OR ALTER PROCEDURE sp_CrearServicio @CALLE varchar(50), @NUM_DOM varchar(6), @DEPTO varchar(3), @PISO int, @TIPO_DNI char(3), @NRO_DNI int, @TELEFONO int = null, @ESTADO varchar(10), @ID_TIPO_SERVICIO char(5), @error_code int = NULL output, @error_message nvarchar(100) = NULL  output
AS
	BEGIN TRY
		DECLARE @EMAIL VARCHAR, @FECHA DATETIME, @FECHA_NACIMIENTO DATETIME, @ID_EST_CLIENTE char(5)
		
		SET @FECHA = GETDATE()
		SET @EMAIL = (SELECT EMAIL FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI)
		SET @FECHA_NACIMIENTO = (SELECT F_NACIMIENTO FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI)

		/* CHEQUEO SI EXISTE EL CLIENTE */
		IF (SELECT 1 FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI) IS NULL
		BEGIN
			RAISError(50008, 10, 1);
			RETURN
		END

		/* CHEQUEO SI ESTA EL EMAIL Y LA FECHA DE NACIMIENTO */
		IF (@EMAIL IS NULL or @FECHA_NACIMIENTO is NULL)
		BEGIN
			RAISError(50009, 10, 1);
			RETURN
		END

		IF ((@ID_TIPO_SERVICIO = 'VOIP' or @ID_TIPO_SERVICIO = 'TELEF') and @TELEFONO is null)
		BEGIN
			RAISError(50033, 12, 1);
			RETURN
		END
		BEGIN TRAN
		--/* INSERTO EL SERVICIO */
		IF (@ID_TIPO_SERVICIO = 'VOIP' or @ID_TIPO_SERVICIO = 'TELEF')
		BEGIN
			INSERT INTO SERVICIOS VALUES (@FECHA,@TELEFONO,@ESTADO,@CALLE,@NUM_DOM,@DEPTO,@PISO,@TIPO_DNI,@NRO_DNI,@ID_TIPO_SERVICIO)
		END
		ELSE
		BEGIN
			SET @TELEFONO = NULL
			INSERT INTO SERVICIOS VALUES (@FECHA, @TELEFONO, @ESTADO,@CALLE,@NUM_DOM,@DEPTO,@PISO,@TIPO_DNI,@NRO_DNI,@ID_TIPO_SERVICIO)
		END
		
		PRINT 'SERVICIO AGREGADO'

		SET @ID_EST_CLIENTE = (select id_estadoCliente from CLIENTES where TIPO_DNI = @TIPO_DNI AND NRO_DNI = @NRO_DNI)
		
		/* SI EL CLIENTE ES PROSPECTO, LO ACTIVO */
		IF (@ID_EST_CLIENTE = 'PROSP')
		BEGIN
			PRINT 'ACTUALIZO EL CLIENTE DE PROSPECTO A ACTIVO'
			UPDATE CLIENTES SET id_estadoCliente = 'ACTIV' WHERE TIPO_DNI = @TIPO_DNI AND NRO_DNI = @NRO_DNI
		END
		/* SI EL CLIENTE ES INACTIVO, LO ACTIVO */
		IF (@ID_EST_CLIENTE = 'INACT')
		BEGIN
			PRINT 'ACTUALIZO EL CLIENTE DE INACTIVO A ACTIVO'
			UPDATE CLIENTES SET id_estadoCliente = 'ACTIV' WHERE TIPO_DNI = @TIPO_DNI AND NRO_DNI = @NRO_DNI
		END
		COMMIT
	END TRY
	BEGIN CATCH
		RAISError(50010, 11, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		if @@TRANCOUNT>0
			ROLLBACK
		EXEC sp_ReporteError
	END CATCH
GO

CREATE OR ALTER PROCEDURE sp_InactivarServicio @NRO_SERVICIO int, @error_code int = NULL output, @error_message nvarchar(100) = NULL output
AS
BEGIN
	declare @TIPO_DNI CHAR(3)
	declare @NRO_DNI int
	SET @TIPO_DNI = (SELECT TIPO_DNI FROM SERVICIOS WHERE id_servicio = @NRO_SERVICIO)
	SET @NRO_DNI = (SELECT NRO_DNI FROM SERVICIOS WHERE id_servicio = @NRO_SERVICIO)

	/* CHEQUEO SI EXISTE EL SERVICIO A INACTIVAR */	
	IF (SELECT id_servicio FROM SERVICIOS WHERE id_servicio = @NRO_SERVICIO) IS NULL
	BEGIN
		RAISError(50011, 11, 1);
		RETURN
	END
	BEGIN TRY
		BEGIN TRAN
		/* CHEQUEO SI EL CLIENTE TIENE MAS DE UN SERVICIO ACTIVO */
		IF (SELECT COUNT(id_servicio) FROM SERVICIOS WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI and estado = 'ACTIVO') > 1
			BEGIN
				/*INACTIVO EL SERVICIO*/
				UPDATE SERVICIOS SET ESTADO = 'INACTIVO' WHERE id_servicio = @NRO_SERVICIO
				PRINT 'SE INACTIVA EL SERVICIO'
			END
		ELSE
			BEGIN
				/*INACTIVO EL SERVICIO Y EL CLIENTE */
				UPDATE SERVICIOS SET ESTADO = 'INACTIVO' WHERE id_servicio = @NRO_SERVICIO
				UPDATE CLIENTES SET id_estadoCliente = 'INACT' WHERE TIPO_DNI = @TIPO_DNI AND NRO_DNI = @NRO_DNI
				PRINT 'SE INACTIVA EL SERVICIO Y EL CLIENTE'
			END
		COMMIT
	END TRY
	BEGIN CATCH
		RAISError(50012, 11, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		EXEC sp_ReporteError
		if @@TRANCOUNT>0
			ROLLBACK
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_GenerarTicket @TIPO_DNI char(3), @NRO_DNI int,@NOMBRE varchar(30) = NULL, @APELLIDO varchar(30) = NULL, @EMAIL VARCHAR(50) = NULL, @FECHA_NAC DATETIME = NULL, @NROSERVICIO INT = NULL, @ID_EMPLEADO INT, @ID_TIPOLOGIA char(9), @error_code int = NULL output, @error_message nvarchar(100) = NULL output
AS
BEGIN
	DECLARE @ID_ESTADO_TICKET varchar(5)
	/* CHEQUEO DEL DNI*/
	IF (@TIPO_DNI != 'DNI' and @TIPO_DNI != 'LC' and @TIPO_DNI != 'LE')
	BEGIN
		RAISError(50013, 9, 1);
		RETURN
	END

	/* CHEQUEO DEL NUMERO */
	IF (len(@NRO_DNI) > 8 or len(@NRO_DNI) < 7 or ISNUMERIC(@NRO_DNI)=0)
	BEGIN
		RAISError(50014, 9, 1);
		RETURN
	END

	/* CHEQUEO SI EXISTE EL CLIENTE*/
	IF(SELECT 1 FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI) IS NULL
	BEGIN
		RAISError(50008, 9, 1);
		RETURN
	END	
		
	/* SI EL NUMERO DE SERVICIO ES PROPORCIONADO, CHEQUEO SI EXISTE */
	IF (@NROSERVICIO IS NOT NULL)
	BEGIN
		IF (SELECT id_servicio FROM SERVICIOS WHERE id_servicio = @NROSERVICIO) IS NULL
		BEGIN
			RAISError(50011, 11, 1);
			RETURN
		END
		ELSE
		BEGIN
			/* CHEQUEO SI EL SERVICIO PERTENECE AL CLIENTE*/
			IF (select s.id_servicio from servicios s, clientes c where s.id_servicio = @NROSERVICIO and ((c.tipo_dni = @TIPO_DNI) and (c.nro_dni = @NRO_DNI))) = 0
			BEGIN
				RAISError(50038, 11, 1);
				RETURN
			END
		END
	END
	/* INSERCION DE TICKET */
	BEGIN TRY
		BEGIN TRAN
		DECLARE @F_APERTURA datetime
		DECLARE @ID_TICKET INT
		SET @ID_ESTADO_TICKET = 'ABIER'
		SET @F_APERTURA = GETDATE()

		/* INSERTO EL TICKET */
		INSERT INTO TICKETS (F_APERTURA, TIPO_DNI, NRO_DNI, ID_ESTADOTICKET,ID_EMPLEADO, ID_TIPOLOGIA, id_servicio) VALUES (@F_APERTURA, @TIPO_DNI, @NRO_DNI, @ID_ESTADO_TICKET, @ID_EMPLEADO, @ID_TIPOLOGIA, @NROSERVICIO)
		
		/* AGREGAMOS AL HISTORIAL */
		SET @ID_TICKET = (select id_ticket from TICKETS where f_apertura = @F_APERTURA and id_estadoTicket = @ID_ESTADO_TICKET)
		INSERT INTO HISTORIALES (FECHA_HISTORIAL, ID_TICKET, ID_ESTADOTICKET) VALUES (@F_APERTURA, @ID_TICKET, @ID_ESTADO_TICKET)
		COMMIT
		PRINT 'TICKET CREADO Y AGREGADO AL HISTORIAL'
	END TRY
	BEGIN CATCH
		RAISError(50015, 9, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		exec sp_ReporteError
		if @@TRANCOUNT>0
			ROLLBACK
	END CATCH
END
GO

CREATE FUNCTION CheckTransicion (@ID_ESTADO_DESTINO varchar(5), @NROTICKET int) Returns bit
AS
BEGIN
	DECLARE @huboError bit
	SET @huboError = 0
	DECLARE @ESTADO_ACTUAL varchar(5)
	SET @ESTADO_ACTUAL = (select id_estadoTicket from TICKETS where id_ticket = @NROTICKET)

	IF (@ESTADO_ACTUAL = 'ABIER')
	BEGIN
		IF (@ID_ESTADO_DESTINO != 'PROGR')
		BEGIN
			SET @huboError = 1
		END
	END
	IF (@ESTADO_ACTUAL = 'PROGR')
	BEGIN
		IF (@ID_ESTADO_DESTINO != 'PENDI' AND @ID_ESTADO_DESTINO != 'RESUE')
		BEGIN
			SET @huboError = 1
		END
	END
	IF (@ESTADO_ACTUAL = 'PENDI')
	BEGIN
		IF (@ID_ESTADO_DESTINO != 'PROGR')
		BEGIN
			SET @huboError = 1
		END
	END
	IF (@ESTADO_ACTUAL = 'RESUE')
	BEGIN
		IF (@ID_ESTADO_DESTINO != 'CERRA')
		BEGIN
			SET @huboError = 1
		END
	END
	IF (@ESTADO_ACTUAL = 'CERRA')
	BEGIN
		SET @huboError = 1
	END
	RETURN @huboError
END
GO

CREATE OR ALTER PROCEDURE sp_ModificarEstado @ID_EMPLEADO int, @NROTICKET int, @ID_ESTADO varchar(5), @error_code int = NULL output, @error_message nvarchar(100) = NULL output
AS
BEGIN
	/*CHEQUEO SI EL USUARIO ES EL CORRESPONDIENTE PARA MODIFICARLO*/
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @NROTICKET AND ID_EMPLEADO = @ID_EMPLEADO) IS NULL
	BEGIN
		RAISError(50017, 10, 1);
		RETURN
	END
	/* CHEQUEO SI EXISTE EL TICKET */
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @NROTICKET) IS NULL
	BEGIN
		RAISError(50018, 10, 1);
		RETURN
	END
	/* CHEQUEO SI EL ESTADO DE TICKET EXISTE */
	IF(SELECT 1 FROM ESTADOS_TICKET WHERE ID_ESTADOTICKET = @ID_ESTADO) IS NULL
	BEGIN
		RAISError(50020, 12, 1);
		RETURN
	END
	/* CHEQUEO SI ES UNA TRANSICION VÁLIDA USANDO LA FUNCIÓN*/
	IF((select dbo.CheckTransicion (@ID_ESTADO, @NROTICKET)) = 1)
	BEGIN
		RAISError(50030, 12, 1);
		RETURN
	END
	BEGIN TRY
		IF (@ID_ESTADO = 'RESUE')
		BEGIN
			BEGIN TRAN
			/* ACTUALIZO EL ESTADO */
			UPDATE TICKETS SET ID_ESTADOTICKET = 'RESUE', f_resolucion = GETDATE() WHERE ID_TICKET = @NROTICKET
			/* AGREGO EL CAMBIO AL HISTORIAL DE CAMBIOS DE ESTADO */
			INSERT INTO HISTORIALES (FECHA_HISTORIAL, ID_TICKET, ID_ESTADOTICKET) VALUES (GETDATE(), @NROTICKET, 'RESUE')
			PRINT 'EL TICKET HA SIDO RESUELTO Y AGREGADO AL HISTORIAL'
			COMMIT
			RETURN
		END
		IF (@ID_ESTADO = 'CERRA')
		BEGIN
			BEGIN TRAN
			/* ACTUALIZO EL ESTADO */
			UPDATE TICKETS SET ID_ESTADOTICKET = 'CERRA', F_CIERRE = GETDATE() WHERE ID_TICKET = @NROTICKET
			/* AGREGO EL CAMBIO AL HISTORIAL DE CAMBIOS DE ESTADO */
			INSERT INTO HISTORIALES (FECHA_HISTORIAL, ID_TICKET, ID_ESTADOTICKET) VALUES (GETDATE(), @NROTICKET, 'CERRA')
			PRINT 'TICKET CERRADO Y AGREGADO AL HISTORIAL'
			COMMIT
			RETURN
		END
		ELSE
		BEGIN
			BEGIN TRAN
			/* ACTUALIZO EL ESTADO */
			UPDATE TICKETS SET ID_ESTADOTICKET = @ID_ESTADO WHERE ID_TICKET = @NROTICKET
			/* AGREGO EL CAMBIO AL HISTORIAL DE CAMBIOS DE ESTADO */
			INSERT INTO HISTORIALES (FECHA_HISTORIAL, ID_TICKET, ID_ESTADOTICKET) VALUES (GETDATE(), @NROTICKET, @ID_ESTADO)
			COMMIT
			PRINT 'ESTADO DEL TICKET MODIFICADO Y AGREGADO AL HISTORIAL'
			RETURN
		END
	END TRY
	BEGIN CATCH
		RAISError(50021, 17, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		EXEC sp_ReporteError
		if @@TRANCOUNT>0
			ROLLBACK
	END CATCH
END
GO

CREATE OR ALTER TRIGGER tg_EnvioMailsEstado on TICKETS after UPDATE
AS
IF UPDATE(ID_ESTADOTICKET)
BEGIN
	DECLARE @DESCRIPCION VARCHAR(500)
	DECLARE @ESTADO VARCHAR(5)
	DECLARE @ID_TICKET INT

	SET @ESTADO = (SELECT ID_ESTADOTICKET FROM inserted)
	SET @ID_TICKET = (SELECT ID_TICKET FROM inserted)
	SET @DESCRIPCION = concat('SE CAMBIO EL ESTADO A ', @ESTADO, ' AL TICKET NRO: ', @ID_TICKET)
	INSERT INTO EMAILS (MENSAJE, ENVIADO, ID_TICKET) VALUES (@DESCRIPCION, 1, @ID_TICKET)
END
GO

CREATE OR ALTER PROCEDURE sp_ReasignarTicket @NROTICKET int, @ID_EMPLEADO_DESTINO int, @ID_EMPLEADO_ACTUAL int, @error_code int = NULL output, @error_message nvarchar(100) = NULL output 
AS
BEGIN
	/* CHEQUE SI EXISTE EL TICKET */
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @NROTICKET) IS NULL
	BEGIN
		RAISError(50018, 10, 1);
		RETURN
	END
	/* CHEQUEO SI EXISTE EL EMPLEADO Y SI ESTA ACTIVO*/
	IF(SELECT 1 FROM EMPLEADOS WHERE ID_EMPLEADO = @ID_EMPLEADO_DESTINO AND ESTADO = 'ACTIVO') IS NULL
	BEGIN
		RAISError(50025, 9, 1);
		RETURN
	END
	/* CHEQUEO SI EL TICKET ESTA ABIERTO */
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @NROTICKET AND ID_ESTADOTICKET = 'ABIER') IS NULL
	BEGIN
		RAISError(50026, 9, 1);
		RETURN
	END
	/*CHEQUEO SI EL USUARIO ES EL CORRESPONDIENTE PARA MODIFICARLO*/
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @NROTICKET AND ID_EMPLEADO = @ID_EMPLEADO_ACTUAL) IS NULL
	BEGIN
		RAISError(50017, 10, 1);
		RETURN
	END
	BEGIN TRY
		/* REASIGNO TICKET */
		UPDATE TICKETS SET ID_EMPLEADO = @ID_EMPLEADO_DESTINO WHERE ID_TICKET = @NROTICKET
		PRINT 'TICKET REASIGNADO'
	END TRY
	BEGIN CATCH
		RAISError(50027, 9, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		EXEC sp_ReporteError
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_ActualizarInfoCliente @TIPO_DNI CHAR(3), @NRO_DNI INT, @NOMBRE VARCHAR(30) = NULL, @APELLIDO VARCHAR(30) = NULL, @FECHA_NAC DATETIME = NULL, @EMAIL varchar(50) = null, @error_code int = NULL output, @error_message nvarchar(100) = NULL output
AS
BEGIN
	/* CHEQUEO DEL DNI*/
	IF (@TIPO_DNI != 'DNI' and @TIPO_DNI != 'LC' and @TIPO_DNI != 'LE')
	BEGIN
		RAISError(50013, 9, 1);
		RETURN
	END
	/* CHEQUEO DEL NUMERO */
	IF (len(@NRO_DNI) > 8 or len(@NRO_DNI) < 7 or ISNUMERIC(@NRO_DNI)=0)
	BEGIN
		RAISError(50014, 9, 1);
		RETURN
	END
	/*CHEQUEO SI EL CLIENTE EXISTE*/
	IF(SELECT 1 FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI) IS NULL
	BEGIN
		RAISError(50008, 10, 1);
		RETURN
	END
	/*CHEQUEO FORMATO EMAIL*/
	IF (@EMAIL IS NOT NULL and @EMAIL NOT LIKE '%[a-z,0-9]@[a-z,0-9]%.[A-Za-z]%[A-Za-z]')
	BEGIN
		RAISError(50034, 9, 1);
		RETURN
	END
	/*CHEQUEO EDAD*/
	IF (@FECHA_NAC IS NOT NULL and DATEDIFF(YEAR, @FECHA_NAC, GETDATE()) < 18)
	BEGIN
		RAISError(50035, 9, 1);
		RETURN
	END
	/* CHEQUEO SI EL CLIENTE ES PROSPECTO*/
	IF(SELECT 1 FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI AND id_estadoCliente = 'PROSP') IS NULL
	BEGIN
		IF (@EMAIL IS NOT NULL)
		BEGIN
			UPDATE CLIENTES SET EMAIL = @EMAIL WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI
			PRINT 'EMAIL MODIFICADO'
		END
		ELSE
		BEGIN
			RAISError(50028, 9, 1);
			RETURN
		END
	END
	BEGIN TRY
		BEGIN TRAN
		IF (@NOMBRE IS NOT NULL)
		BEGIN
			UPDATE CLIENTES SET NOMBRE = @NOMBRE WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI
			PRINT 'NOMBRE MODIFICADO'
		END
		IF (@APELLIDO IS NOT NULL)
		BEGIN
			UPDATE CLIENTES SET APELLIDO = @APELLIDO WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI
			PRINT 'APELLIDO MODIFICADO'
		END
		IF (@FECHA_NAC IS NOT NULL)
		BEGIN
			UPDATE CLIENTES SET F_NACIMIENTO = @FECHA_NAC WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI
			PRINT 'FECHA DE NACIMIENTO MODIFICADA'
		END
		IF (@EMAIL IS NOT NULL)
		BEGIN
			UPDATE CLIENTES SET EMAIL = @EMAIL WHERE TIPO_DNI = @TIPO_DNI and NRO_DNI = @NRO_DNI
			PRINT 'EMAIL MODIFICADO'
		END
		COMMIT
	END TRY
	BEGIN CATCH
		RAISError(50029, 11, 1);
		SELECT @error_code=ERROR_NUMBER();
		SELECT @error_message=ERROR_MESSAGE();
		EXEC sp_ReporteError
		if @@TRANCOUNT>0
			ROLLBACK
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_CumplioSLA @id_ticket int, @cumplio bit = null output, @error_code int = NULL output, @error_message nvarchar(100) = NULL output
AS
BEGIN
	/* CHEQUEO SI EXISTE EL TICKET */
	IF(SELECT 1 FROM TICKETS WHERE ID_TICKET = @id_ticket) IS NULL
	BEGIN
		RAISError(50018, 9, 1);
		RETURN
	END
	/* CHEQUEO SI YA ESTA RESUELTO*/
	IF ((select id_estadoTicket from TICKETS where id_ticket = @id_ticket) != 'RESUE')
	BEGIN
		RAISError(50031, 9, 1);
		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
		DECLARE @SLA int
		/* USO DE LA VISTA CREADA EN EL DDL*/
		SET @SLA = (select sla from SLA_Tickets_Resueltos where id_ticket = @id_ticket)

		DECLARE @F_apertura datetime
		DECLARE @f_resolucion datetime
		select @f_apertura = (select f_apertura from tickets where id_ticket = @id_ticket)
		select @f_resolucion = (select f_resolucion from tickets where id_ticket = @id_ticket)

		DECLARE @diasEnPendiente int
		SET @diasEnPendiente = dbo.EstimarPendientes(@id_ticket)
		IF ((DATEDIFF(DAY, @f_apertura , @f_resolucion) - @diasEnPendiente) <= @SLA)
		BEGIN
			SET @CUMPLIO = 1
			PRINT 'CUMPLIÓ CON EL SLA'
		END
		ELSE
		BEGIN
			SET @CUMPLIO = 0
			PRINT 'NO CUMPLIÓ CON EL SLA'
		END
		END TRY
		BEGIN CATCH
			RAISError(50032, 9, 1);
			SELECT @error_code=ERROR_NUMBER();
			SELECT @error_message=ERROR_MESSAGE();
			EXEC sp_ReporteError
		END CATCH
	END
END
GO

--CREATE OR ALTER PROCEDURE sp_cambiarDni @TIPO_DNI_ORIGEN char(3), @NRO_DNI_ORIGEN int, @TIPO_DNI_DESTINO char(3), @NRO_DNI_DESTINO int,
--	@error_code int = NULL output,
--	@error_message nvarchar(100) = NULL output
--AS
--	/* CHEQUEO DEL DNI*/
--	IF ((@TIPO_DNI_ORIGEN != 'DNI' and @TIPO_DNI_ORIGEN != 'LC' and @TIPO_DNI_ORIGEN != 'LE') 
--	OR (@TIPO_DNI_DESTINO != 'DNI' and @TIPO_DNI_DESTINO != 'LC' and @TIPO_DNI_DESTINO != 'LE'))
--	BEGIN
--		SET @error_code = 50013
--		SET @error_message = (select s.text from sys.messages as s where message_id = @error_code)
--		PRINT @error_message
--		RETURN
--	END
--	/* CHEQUEO DEL NUMERO */
--	IF ((len(@NRO_DNI_ORIGEN) > 8 or len(@NRO_DNI_ORIGEN) < 7 or ISNUMERIC(@NRO_DNI_ORIGEN)=0)
--	OR (len(@NRO_DNI_DESTINO) > 8 or len(@NRO_DNI_DESTINO) < 7 or ISNUMERIC(@NRO_DNI_DESTINO)=0))
--	BEGIN
--		SET @error_code = 50014
--		SET @error_message = (select s.text from sys.messages as s where message_id = @error_code)
--		PRINT @error_message
--		RETURN
--	END
--	/*CHEQUEO SI EL USUARIO EXISTE*/
--	IF(SELECT 1 FROM CLIENTES WHERE TIPO_DNI = @TIPO_DNI_ORIGEN and NRO_DNI = @NRO_DNI_ORIGEN) IS NULL
--	BEGIN
--		SET @error_code = 50008
--		SET @error_message = (select s.text from sys.messages as s where message_id = @error_code)
--		PRINT @error_message
--		RETURN
--	END
--	IF(select descripcion from ESTADOS_CLIENTE ec, clientes c where c.TIPO_DNI = @TIPO_DNI_ORIGEN and c.NRO_DNI = @NRO_DNI_ORIGEN and ec.id_estadoCliente = c.estado) = 'PROSPECTO'
--	BEGIN
--		BEGIN TRAN
--		BEGIN TRY
--			/* REASIGNO TICKET */
--			UPDATE CLIENTES SET tipo_dni = @TIPO_DNI_DESTINO WHERE TIPO_DNI = @TIPO_DNI_ORIGEN and NRO_DNI = @NRO_DNI_ORIGEN
--			UPDATE CLIENTES SET nro_dni = @NRO_DNI_DESTINO WHERE TIPO_DNI = @TIPO_DNI_ORIGEN and NRO_DNI = @NRO_DNI_ORIGEN
--			PRINT 'DNI CAMBIADO'
--			COMMIT
--		END TRY
--		BEGIN CATCH
--			SET @error_code = 50036
--			SET @error_message = (select s.text from sys.messages as s where message_id = @error_code)
--			PRINT @error_message
--			if @@TRANCOUNT>0
--				ROLLBACK
--			EXEC sp_ReporteError
--		END CATCH
--	END
--	ELSE
--	BEGIN
--		SET @error_code = 50037
--		SET @error_message = (select s.text from sys.messages as s where message_id = @error_code)
--		PRINT @error_message
--	END
--GO

CREATE OR ALTER FUNCTION EstimarPendientes(@id_ticketSolicitado int) Returns int
AS
BEGIN
	DECLARE @tabla table (fecha_historial datetime, id_ticket int, id_estadoTicket char(5))
	insert into @tabla (fecha_historial, id_ticket, id_estadoTicket) select fecha_historial, id_ticket, id_estadoTicket from HISTORIALES
	declare @cont int = (select count(1) from @tabla)
	DECLARE @diasEnPendiente int = 0
	declare @pendiente1 datetime
	declare @enProgreso1 datetime
	declare @dias int
	declare @estado varchar(5)

	set @enProgreso1 = (select top(1) fecha_historial from @tabla where id_estadoTicket = 'PROGR')
	delete @tabla where fecha_historial = @enProgreso1

	while @cont > 0
	begin
		if 'PENDI' in (select id_estadoTicket from @tabla)
		begin
			set @pendiente1 = (select top(1) fecha_historial from @tabla where id_estadoTicket = 'PENDI')
			set @enProgreso1 = (select top(1) fecha_historial from @tabla where id_estadoTicket = 'PROGR')
			delete @tabla where fecha_historial = @enProgreso1
			set @dias = datediff(day, @pendiente1, @enProgreso1)
			set @diasEnPendiente = @diasEnPendiente + @dias
			delete @tabla where fecha_historial = @enProgreso1
			delete @tabla where fecha_historial = @pendiente1
			set @dias = 0
		end
		else
		begin
			delete top(1) from @tabla
		end
		set @cont = (select count(*) from @tabla)
	end
	RETURN @diasEnPendiente
END
GO