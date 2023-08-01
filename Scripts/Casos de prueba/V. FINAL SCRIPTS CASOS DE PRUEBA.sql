/* VERSIÓN FINAL DE SCRIPTS CON CASOS DE PRUEBA */

/* CASO 1.
Condición: Alta de un nuevo Cliente
Resultado Esperado: El cliente se debe generar como Prospecto
*/
--A) Precondiciones (ejecutar antes los DML en el archivo 'DDL + DML'):
INSERT INTO ESTADOS_CLIENTE(id_estadoCliente, descripcion) VALUES ('PROSP', 'PROSPECTO')
--B)
/* ALTA DE CLIENTES DE PRUEBA */
EXEC sp_InsertarCliente @tipo_dni = 'DNI' , @nro_dni = 11111111, @nombre = 'Marcelo', @apellido = 'Araujo', @fecha_nac = '06-01-2003'

--EXEC sp_InsertarCliente @tipo_dni = 'DNI' , @nro_dni = 45562333, @nombre = 'Laura', @apellido = 'Gomez', @fecha_nac = '06-01-2000' 
--EXEC sp_InsertarCliente @tipo_dni = 'LE' , @nro_dni = 45459263, @nombre = 'Diego', @apellido = 'Capussotto', @email = 'diego@hotmail.com'
--EXEC sp_InsertarCliente @tipo_dni = 'LE' , @nro_dni = 45459265, @nombre = 'Juan', @apellido = 'De los Palotes', @fecha_nac = '06-01-1990',@email = 'diego@hotmail.com'
--C)
select c.tipo_dni, c.nro_dni, ec.descripcion from CLIENTES c, ESTADOS_CLIENTE ec where c.tipo_dni = 'DNI' and c.nro_dni = 11111111 and ec.id_estadoCliente = c.id_estadoCliente

/* CASO 2.
Condición: Intentar dar de alta un cliente (prospecto) sin datos mínimos requeridos o erróneos (probar las distintas alternativas de campos)
Resultado Esperado: Se debe devolver el error correspondiente
*/
--A) (ya ejecutado en el DML)
INSERT INTO ESTADOS_CLIENTE(id_estadoCliente, descripcion) VALUES ('PROSP', 'PROSPECTO')
--B)
EXEC sp_InsertarCliente @tipo_dni = 'LC' , @nro_dni = 45, @nombre = 'Diego', @apellido = 'Maradona', @fecha_nac = '06-01-1990'
EXEC sp_InsertarCliente @tipo_dni = 'LC', @nro_dni = 45459265, @nombre = null, @apellido = 'Capussotto', @fecha_nac = '06-01-1990',@email = 'diego@hotmail.com'
EXEC sp_InsertarCliente @tipo_dni = 'LC', @nro_dni = 45459265, @nombre = 'Diego', @apellido = null, @fecha_nac = '06-01-1990',@email = 'diego@hotmail.com'
EXEC sp_InsertarCliente @tipo_dni = 'ASD' , @nro_dni = 45226553, @nombre = 'Diego', @apellido = 'Maradona', @fecha_nac = '06-01-1990'
--C)
select * from CLIENTES where nro_dni = 45
select * from CLIENTES where nro_dni = 45459265

/* CASO 3.
Condición: Crear un nuevo servicio a un Prospecto
Resultado Esperado: Debe crearse el servicio y cambiarse el cliente a Activo. Se debe crear el servicio activo
*/
--A) (cliente ya insertado y estados cliente ejecutados en el DML)
EXEC sp_InsertarCliente @tipo_dni = 'DNI' , @nro_dni = 11111111, @nombre = 'Marcelo', @apellido = 'Araujo', @fecha_nac = '06-01-2003'
INSERT INTO ESTADOS_CLIENTE(descripcion) VALUES ('ACTIVO')
INSERT INTO ESTADOS_CLIENTE(descripcion) VALUES ('PROSPECTO')
INSERT INTO TIPOS_SERVICIO(descripcion) VALUES ('INTERNET')
--agregamos email, requerido (junto con la fecha de nacimiento, que ya la tenia) para clientes activos
EXEC sp_ActualizarInfoCliente @TIPO_DNI = 'DNI', @NRO_DNI = 11111111, @NOMBRE = NULL, @APELLIDO = NULL, @FECHA_NAC = NULL, @EMAIL = 'marcelo@hotmail.com'
--B) (el teléfono no se guarda, ya que el tipo de servicio es Internet)
EXEC sp_CrearServicio @CALLE='Loyola', @NUM_DOM='1200', @DEPTO='A', @PISO=2, @TIPO_DNI='DNI', @NRO_DNI=11111111, @TELEFONO=47935124, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO='VOIP'
--C)
select * from SERVICIOS where nro_dni = 11111111

/* CASO 4.
Condición: Crear un nuevo servicio a un Cliente Inactivo
Resultado Esperado: Debe crearse el servicio y cambiarse el cliente a Activo. Se debe crear el servicio activo
*/
--A)
EXEC sp_InactivarServicio @NRO_SERVICIO = 1
--B)
EXEC sp_CrearServicio @CALLE='Loyola', @NUM_DOM='1200', @DEPTO='B', @PISO=2, @TIPO_DNI='DNI', @NRO_DNI=11111111, @TELEFONO=47935124, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO='TELEF'
--C)
select * from SERVICIOS where nro_dni = 11111111 and id_servicio = 2

/* CASO 5.
Condición: Intentar crear un servicio a un prospecto que no tiene email o fecha de nacimiento.
Resultado Esperado: Debe devolver un error
*/
--A)
EXEC sp_InsertarCliente @tipo_dni = 'DNI' , @nro_dni = 22222222, @nombre = 'Elba', @apellido = 'Calao'
--B)
EXEC sp_CrearServicio @CALLE='Callao', @NUM_DOM='252', @DEPTO='10', @PISO=0, @TIPO_DNI='DNI', @NRO_DNI=22222222, @TELEFONO=47935124, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO= 'TELEF'
--C)
select * from SERVICIOS where nro_dni = 22222222

/* CASO 6.
Condición: Inactivar un Servicio a un cliente con un solo servicio activo
Resultado Esperado: Se inactiva el servicio y el cliente
*/
--A) (ya hecho)
EXEC sp_CrearServicio @CALLE='Loyola', @NUM_DOM='1200', @DEPTO='A', @PISO=2, @TIPO_DNI='DNI', @NRO_DNI=11111111, @TELEFONO=47935124, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO='TELEF'
--B)
EXEC sp_InactivarServicio @NRO_SERVICIO = 2
--C)
select s.id_servicio, c.nro_dni as cliente, ec.id_estadoCliente as estado 
from CLIENTES as c, ESTADOS_CLIENTE as ec, SERVICIOS s
where c.nro_dni = 11111111
and c.id_estadoCliente = ec.id_estadoCliente
and s.id_servicio = 2

/* CASO 7.
Condición: Inactivar un Servicio a un cliente con más de un servicio activo
Resultado Esperado: Se inactiva el servicio
*/
--A) creamos nuevo cliente y 2 servicios
EXEC sp_InsertarCliente @tipo_dni = 'LE', @nro_dni = 22222222, @nombre = 'Aitor', @apellido = 'Tilla', @fecha_nac = '06-01-1978',@email = 'Aitor@gmail.com'
EXEC sp_CrearServicio @CALLE='Directorio', @NUM_DOM='2556', @DEPTO='5', @PISO=1, @TIPO_DNI='LE', @NRO_DNI=22222222,  @TELEFONO=47935126, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO='VOIP'
EXEC sp_CrearServicio @CALLE='Directorio', @NUM_DOM='2556', @DEPTO='5', @PISO=1, @TIPO_DNI='LE', @NRO_DNI=22222222, @TELEFONO=47935126, @ESTADO='ACTIVO', @ID_TIPO_SERVICIO='INTER'
--B)
EXEC sp_InactivarServicio @NRO_SERVICIO = 3
--C)
select s.id_servicio, s.estado
from SERVICIOS s
where NRO_DNI = 22222222
and id_servicio = 3

/* CASO 8.
Condición: Generar un nuevo ticket
Resultado Esperado: Ticket Creado en estado Abierto con el usuario creador como dueño
*/
--A) 
--ya hecho
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('REIMP_FAC', 'REIMPRESION DE FACTURA', 5, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('SERV_DEG', 'SERVICIO DEGRADADO', 15, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('BAJA', 'BAJA DE SERVICIO', 2, 'VOIP')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('CARG_ERR', 'FACTURACION DE CARGOS ERRONEOS', 20, 'TELEFONIA FIJA')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('CAMB_VEL', 'CAMBIO DE VELOCIDAD', 20, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('MUDANZ', 'MUDANZA DE SERVICIO', 10, 'INTER')
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Federico','Mercurio')
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Juan','Pagina')
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Rogelio','Aguas')
--
--B) ticket para user activo con 1 servicio activo
EXEC sp_GenerarTicket @TIPO_DNI = 'LE',@NRO_DNI =22222222, @NOMBRE = NULL, @APELLIDO = NULL, @EMAIL = NULL, @FECHA_NAC = NULL, @NROSERVICIO = 4, @ID_EMPLEADO = 1, @ID_TIPOLOGIA = 'REIMP_FAC'
--ticket para cliente (prospecto) no registrado, sin servicios, sin nombre ni apellido (requeridos)
EXEC sp_GenerarTicket @TIPO_DNI = 'DNI',@NRO_DNI =99999998, @NOMBRE = NULL, @APELLIDO = NULL, @EMAIL = NULL, @FECHA_NAC = NULL, @ID_EMPLEADO = 2, @ID_TIPOLOGIA = 'REIMP_FAC'
--ticket para cliente (prospecto) no registrado, sin servicios, con nombre y apellido. Da error
EXEC sp_GenerarTicket @TIPO_DNI = 'DNI',@NRO_DNI =99999998, @NOMBRE = 'Pepe', @APELLIDO = 'Mujica', @EMAIL = NULL, @FECHA_NAC = NULL, @ID_EMPLEADO = 2, @ID_TIPOLOGIA = 'REIMP_FAC'
--C)
select * from tickets

/* CASO 9.
Condición: Cambiar el estado de un Ticket a un estado diferente de resuelto (transición permitida)
Resultado Esperado: Se debe cambiar el estado del ticket. Debe generarse un registro en la tabla de emails
*/
--A) ya hecho
EXEC sp_GenerarTicket @TIPO_DNI = 'DNI',@NRO_DNI =99999998, @NOMBRE = 'Pepe', @APELLIDO = 'Mujica', @EMAIL = NULL, @FECHA_NAC = NULL, @ID_EMPLEADO = 2, @ID_TIPOLOGIA = 'BAJA'
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Federico','Mercurio')
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('PROGR', 'EN PROGRESO')
exec sp_addmessage 50017, 10, "ERROR: USUARIO NO PERMITIDO PARA LA OPERACION", 'us_english'
exec sp_addmessage 50018, 10, "ERROR: TICKET INEXISTENTE", 'us_english'
exec sp_addmessage 50019, 10, "ERROR: NO SE PERMITE CERRAR EL TICKET", 'us_english'
exec sp_addmessage 50020, 12, "ERROR: EL ESTADO NO EXISTE", 'us_english'
--B)
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 1, @ID_ESTADO = 'PROGR'
--C)
select id_ticket, id_estadoTicket from TICKETS where id_Ticket = 1
select * from HISTORIALES where id_Ticket = 1
select * from EMAILS where id_ticket = 1

/* CASO 10.
Condición: Cambiar el estado de un Ticket a Resuelto
Resultado Esperado: Se debe cambiar el estado del ticket con fecha de resolución. 
Debe generarse un registro en la tabla de emails
*/
--A) ya ejecutado en el dml
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('RESUE', 'RESUELTO')
--B)
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 1, @ID_ESTADO = 'RESUE'
--C)
select id_ticket, id_estadoTicket from TICKETS where id_Ticket = 1
select id_ticket, f_resolucion from TICKETS where id_ticket = 1
select * from EMAILS where id_ticket = 1

/* CASO 11.
Condición: Intentar realizar un cambio a un estado no permitido
Resultado Esperado: Se debe devolver error
*/
--A)
--B) intentamos cerrar un ticket en 'abierto'
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 1, @ID_ESTADO = 'ABIER'
--C)
select id_ticket, id_estadoTicket from tickets where id_ticket = 1

/* CASO 12.
Condición: Reasignar un Ticket abierto a un usuario activo
Resultado Esperado: Ticket reasignado al nuevo usuario
*/
--A)
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Juan','Pagina')
EXEC sp_GenerarTicket @TIPO_DNI = 'DNI',@NRO_DNI =22222222, @NOMBRE = null, @APELLIDO = null, @EMAIL = NULL, @FECHA_NAC = NULL, @ID_EMPLEADO = 2, @ID_TIPOLOGIA = 'BAJA'
--B)
EXEC sp_ReasignarTicket @NROTICKET = 2, @ID_EMPLEADO_DESTINO = 1, @ID_EMPLEADO_ACTUAL = 2
--C)
select t.id_ticket, t.id_empleado from TICKETS t where id_ticket = 2

/* CASO 13.
Condición: Intentar reasignar un Ticket a un usuario Inactivo
Resultado Esperado: Se devuelve un error
*/
--A) Inactivo a un empleado
UPDATE EMPLEADOS SET ESTADO = 'Inactivo' WHERE id_empleado = 3
--B)
EXEC sp_ReasignarTicket @NROTICKET = 2, @ID_EMPLEADO_DESTINO = 3, @ID_EMPLEADO_ACTUAL = 1
--C)
select t.id_ticket, t.id_empleado from TICKETS t where id_ticket = 2

/* CASO 14.
Condición: Cambiar el estado de un Ticket a Cerrado
Resultado Esperado: Se cambiar el estado y registrar la fecha y hora del cambio.
*/
--A)
--B) cerramos el ticket en estado 'resuelto'
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 1, @ID_ESTADO = 'CERRA'
--C)
select t.id_ticket, t.id_estadoTicket, h.fecha_historial from tickets t, historiales h where t.id_ticket = 1 and t.id_estadoTicket = h.id_estadoTicket

/* CASO 15.
Condición: Intentar hacer cualquier cambio del ticket con un usuario diferente al dueño
Resultado Esperado: Devolver un error
*/
--A)
--B) abro ticket
EXEC sp_ModificarEstado @ID_EMPLEADO = 2, @NROTICKET = 2, @ID_ESTADO = 'PROGR'
--C)
select id_ticket, id_empleado from tickets where id_ticket = 2
select id_ticket, id_estadoTicket from tickets where id_ticket = 2

/* CASO 16.
Condición: Intentar modificar el nombre o apellido para un cliente activo
Resultado Esperado: Devolver un error
*/
--A)
--B)
EXEC sp_ActualizarInfoCliente @TIPO_DNI = 'LE', @NRO_DNI = 22222222, @NOMBRE = 'Joaquín', @APELLIDO = 'Robles'
--C)
select tipo_dni, nro_dni, nombre, apellido from CLIENTES where tipo_dni = 'LE' and nro_dni = 22222222

/* CASO 17.
Condición: Modificar el nombre, apellido o fecha de nacimiento para un prospecto
Resultado Esperado: Se debe modificar el dato
*/
--A) creamos un cliente nuevo
EXEC sp_InsertarCliente @tipo_dni = 'LC', @nro_dni = 88888889, @nombre = 'Pedro', @apellido = 'Picapiedra', @fecha_nac = '06-01-1758', @email = 'pedrito@yahoo.com'
--B)
EXEC sp_ActualizarInfoCliente @TIPO_DNI = 'LC', @NRO_DNI = 88888889, @NOMBRE = 'Joaquín'
--C)
select tipo_dni, nro_dni, nombre from CLIENTES where tipo_dni = 'LC' and nro_dni = 88888889

/* CASO 18.
Condición: Intentar modificar la fecha de nacimiento de un cliente Activo
Resultado Esperado: Debe dar un error
*/
--A)
--B)
EXEC sp_ActualizarInfoCliente @TIPO_DNI = 'LE', @NRO_DNI = 22222222, @FECHA_NAC = '02-05-1991'
--C)
select tipo_dni, nro_dni, f_nacimiento from clientes where tipo_dni = 'LE' and nro_dni = 22222222

/* CASO 19.
Condición: Intentar crear un cliente con un email inválido
Resultado Esperado: Debe dar un error
*/
--A)
--B)
EXEC sp_InsertarCliente @tipo_dni = 'LE', @nro_dni = 99999998, @nombre = 'Roberto', @apellido = 'Ruiz', @fecha_nac = '06-01-1952',@email = 'rob@hotmailcom'
--C)

/* Prueba SLA para un ticket RESUELTO
*/
--A) Pasamos de abierto a en progreso y de ahi a cerrado si hace falta
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 2, @ID_ESTADO = 'RESUE'
EXEC sp_ModificarEstado @ID_EMPLEADO = 1, @NROTICKET = 2, @ID_ESTADO = 'PENDI'
--crear la Vista SLA_Tickets_Resueltos y el SP sp_cumplioSLA
--B)
--para ticket resuelto. dice si cumplio o no.
EXEC sp_cumplioSLA @id_ticket = 3
--para ticket cerrado. da error
EXEC sp_cumplioSLA @id_ticket = 10
--para ticket inexistente. da error
EXEC sp_cumplioSLA @id_ticket = 50