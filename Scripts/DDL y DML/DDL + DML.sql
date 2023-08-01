create database CallCenterDB

use CallCenterDB

/* DDL Y DML DE CREACIÓN DE DATOS INICIALES*/

/* DDL*/

create table ESTADOS_CLIENTE (
	id_estadoCliente char(5) not null PRIMARY KEY,
	descripcion varchar(10) not null UNIQUE
)

create table CLIENTES (
	tipo_dni char(3) not null,
	nro_dni int not null,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	email varchar(50),
	f_nacimiento datetime,
	id_estadoCliente char(5) not null FOREIGN KEY REFERENCES ESTADOS_CLIENTE(id_estadoCliente) on delete cascade on update cascade,
	CONSTRAINT PK_Clientes PRIMARY KEY (tipo_dni, nro_dni)
)

create table ESTADOS_TICKET (
	id_estadoTicket varchar(5) not null PRIMARY KEY,
	descripcion varchar(18) not null DEFAULT 'Abierto' UNIQUE
)

create table EMPLEADOS (
	id_empleado int not null identity(1,1) PRIMARY KEY,
	nombre varchar(30),
	apellido varchar(30),
	login int,
	estado varchar(9) not null DEFAULT 'Activo'
)

create table TIPOS_SERVICIO (
	id_tipoServicio char(5) not null PRIMARY KEY,
	descripcion varchar(15) not null
)

create table TIPOLOGIAS (
	id_tipologia char(9) not null PRIMARY KEY,
	descripcion varchar(35) not null,
	SLA int not null,
	id_tipoServicio char(5) not null FOREIGN KEY REFERENCES TIPOS_SERVICIO(id_tipoServicio) on update cascade
)

create table SERVICIOS (
	id_servicio int not null identity(1,1) PRIMARY KEY,
	f_inicio datetime not null,
	telefono int,
	estado varchar(10) not null,
	calle varchar(50) not null,
	numero varchar(6) not null,
	depto varchar(3) not null,
	piso int not null,
	tipo_dni char(3),
	nro_dni int,
	CONSTRAINT fk_serviciosCliente FOREIGN KEY (tipo_dni, nro_dni) REFERENCES CLIENTES on delete cascade on update cascade, /*si borro el cliente, se borra el servicio*/
	id_tipoServicio char(5) not null FOREIGN KEY REFERENCES TIPOS_SERVICIO(id_tipoServicio) on update cascade,
)

create table TICKETS (
	id_ticket int not null identity(1,1) PRIMARY KEY,
	f_apertura datetime not null,
	f_resolucion datetime,
	f_cierre datetime,
	id_empleado int not null FOREIGN KEY REFERENCES EMPLEADOS(id_empleado) on update cascade,
	id_estadoTicket varchar(5) not null FOREIGN KEY REFERENCES ESTADOS_TICKET(id_estadoTicket) on update cascade,
	tipo_dni char(3) not null,
	nro_dni int not null,
	CONSTRAINT fk_ticketsCliente FOREIGN KEY (tipo_dni, nro_dni) REFERENCES CLIENTES on update cascade,
	id_servicio int FOREIGN KEY REFERENCES SERVICIOS(id_servicio), --chequear, el ticket puede tener un servicio null
	id_tipologia char(9) not null FOREIGN KEY REFERENCES TIPOLOGIAS(id_tipologia) on update cascade,
)

create table HISTORIALES (
	fecha_historial datetime not null,
	id_ticket int not null FOREIGN KEY REFERENCES TICKETS(id_ticket),
	id_estadoTicket varchar(5) FOREIGN KEY REFERENCES ESTADOS_TICKET(id_estadoTicket) on update cascade,
	CONSTRAINT PK_HISTORIALES PRIMARY KEY (fecha_historial, id_ticket, id_estadoTicket)
)

create table EMAILS (
	id_email int not null identity(1,1) PRIMARY KEY,
	mensaje varchar(500) not null,
	enviado bit not null DEFAULT 0,
	id_ticket int not null FOREIGN KEY REFERENCES TICKETS (id_ticket) on update cascade on delete cascade
)

create table TICKETS_ACTIVIDADES (
	id_actividad int not null identity(1,1),
	id_ticket int not null FOREIGN KEY REFERENCES TICKETS(id_ticket) on delete cascade on update cascade,
	descripcion varchar(100),
	CONSTRAINT PK_TICKETS_ACTIVIDADES PRIMARY KEY (id_actividad, id_ticket)
)

/* DML DE CREACIÓN DE DATOS INICIALES */

/*ESTADOS DE LOS CLIENTES*/
INSERT INTO ESTADOS_CLIENTE(id_estadoCliente, descripcion) VALUES ('ACTIV', 'ACTIVO')
INSERT INTO ESTADOS_CLIENTE(id_estadoCliente, descripcion) VALUES ('INACT', 'INACTIVO')
INSERT INTO ESTADOS_CLIENTE(id_estadoCliente, descripcion) VALUES ('PROSP', 'PROSPECTO')

/* TIPOS DE SERVICIO */
INSERT INTO TIPOS_SERVICIO(id_tipoServicio, descripcion) VALUES ('INTER', 'INTERNET')
INSERT INTO TIPOS_SERVICIO(id_tipoServicio, descripcion) VALUES ('VOIP', 'VOIP')
INSERT INTO TIPOS_SERVICIO(id_tipoServicio, descripcion) VALUES ('TELEF', 'TELEFONIA FIJA')

/* ESTADOS TICKET */
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('ABIER', 'ABIERTO')
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('PROGR', 'EN PROGRESO')
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('PENDI', 'PENDIENTE CLIENTE')
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('RESUE', 'RESUELTO')
INSERT INTO ESTADOS_TICKET (id_estadoTicket, descripcion) VALUES ('CERRA', 'CERRADO')

/* TIPOLOGIAS */
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('REIMP_FAC', 'REIMPRESION DE FACTURA', 5, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('SERV_DEG', 'SERVICIO DEGRADADO', 15, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('BAJA', 'BAJA DE SERVICIO', 2, 'VOIP')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('CARG_ERR', 'FACTURACION DE CARGOS ERRONEOS', 20, 'TELEFONIA FIJA')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('CAMB_VEL', 'CAMBIO DE VELOCIDAD', 20, 'INTER')
INSERT INTO TIPOLOGIAS (id_tipologia, descripcion, sla, id_tipoServicio) VALUES ('MUDANZ', 'MUDANZA DE SERVICIO', 10, 'INTER')

/* USUARIOS*/
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Federico','Mercurio')
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Juan','Pagina')
INSERT INTO EMPLEADOS (nombre, apellido) VALUES ('Rogelio','Aguas')

/* VISTAS */
--1)
CREATE VIEW ClientesActivos AS
select cli.tipo_dni, cli.nro_dni, cli.nombre, cli.apellido from CLIENTES cli, ESTADOS_CLIENTE ec
where ec.id_estadoCliente = cli.id_estadoCliente
--Prueba
select * from ClientesActivos

--2)
CREATE VIEW Servicios_Sin_Direccion AS
select id_servicio, f_inicio, telefono, estado, tipo_dni, nro_dni, id_tipoServicio from SERVICIOS
--Prueba
select * from Servicios_Sin_Direccion

--3)
CREATE OR ALTER VIEW SLA_Tickets_Resueltos AS
select tic.id_ticket, tic.id_empleado, ts.id_tipoServicio, tip.SLA
from TICKETS tic, SERVICIOS s, TIPOS_SERVICIO ts, TIPOLOGIAS tip
where tic.id_servicio = s.id_servicio
and s.id_tipoServicio = ts.id_tipoServicio 
and tic.id_tipologia = tip.id_tipologia
and tic.id_estadoTicket = 'RESUE'
--Prueba
select * from SLA_Tickets_Resueltos