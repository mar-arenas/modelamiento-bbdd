-- ============================================================
-- Modelamiento de Bases de Datos
-- Experiencia 3 - Semana 8
-- Script: Construccion de la Base de Datos Relacional
-- Estudiante: Mariana Arenas Vergara
-- ============================================================

-- ============================================================
-- LIMPIEZA: Eliminar objetos existentes (si existen)
-- ============================================================
DROP TABLE DETALLE_SERVICIO CASCADE CONSTRAINTS;
DROP TABLE PREMIUM CASCADE CONSTRAINTS;
DROP TABLE ESTANDAR CASCADE CONSTRAINTS;
DROP TABLE MANTENCION CASCADE CONSTRAINTS;
DROP TABLE AUTOMOVIL CASCADE CONSTRAINTS;
DROP TABLE MODELO CASCADE CONSTRAINTS;
DROP TABLE MARCA CASCADE CONSTRAINTS;
DROP TABLE TIPO_AUTOMOVIL CASCADE CONSTRAINTS;
DROP TABLE CLIENTE CASCADE CONSTRAINTS;
DROP TABLE MECANICO CASCADE CONSTRAINTS;
DROP TABLE SUCURSAL CASCADE CONSTRAINTS;
DROP TABLE CIUDAD CASCADE CONSTRAINTS;
DROP TABLE PAIS CASCADE CONSTRAINTS;
DROP TABLE SERVICIO CASCADE CONSTRAINTS;
DROP SEQUENCE SEQ_SERVICIO;
DROP SEQUENCE SEQ_CIUDAD;

-- ============================================================
-- CASO 1: IMPLEMENTACION DEL MODELO - SENTENCIAS DDL
-- ============================================================

-- Tablas fuertes (sin dependencias de FK)

-- PAIS: id inicia en 9, incrementa en 3 (identity)
CREATE TABLE PAIS (
    id_pais   NUMBER(3)     GENERATED ALWAYS AS IDENTITY (START WITH 9 INCREMENT BY 3),
    nom_pais  VARCHAR2(30)  NOT NULL,
    CONSTRAINT PAIS_PK PRIMARY KEY (id_pais)
);

-- CIUDAD
CREATE TABLE CIUDAD (
    id_ciudad   NUMBER(3)     NOT NULL,
    nom_ciudad  VARCHAR2(30)  NOT NULL,
    cod_pais    NUMBER(3)     NOT NULL,
    CONSTRAINT CIUDAD_PK         PRIMARY KEY (id_ciudad),
    CONSTRAINT CIUDAD_FK_PAIS    FOREIGN KEY (cod_pais) REFERENCES PAIS(id_pais)
);

-- SUCURSAL
CREATE TABLE SUCURSAL (
    id_sucursal   CHAR(3)       NOT NULL,
    nom_sucursal  VARCHAR2(20)  NOT NULL,
    calle         VARCHAR2(20)  NOT NULL,
    num_calle     NUMBER(4)     NOT NULL,
    cod_ciudad    NUMBER(3)     NOT NULL,
    CONSTRAINT SUCURSAL_PK         PRIMARY KEY (id_sucursal),
    CONSTRAINT SUCURSAL_FK_CIUDAD  FOREIGN KEY (cod_ciudad) REFERENCES CIUDAD(id_ciudad)
);

-- MECANICO: id inicia en 460, incrementa en 7 (identity)
CREATE TABLE MECANICO (
    cod_mecanico    NUMBER(5)     GENERATED ALWAYS AS IDENTITY (START WITH 460 INCREMENT BY 7),
    pnombre         VARCHAR2(20)  NOT NULL,
    snombre         VARCHAR2(20),
    apaterno        VARCHAR2(20)  NOT NULL,
    amaterno        VARCHAR2(20),
    bono_jefatura   NUMBER(10),
    sueldo          NUMBER(10)    NOT NULL,
    monto_impuestos NUMBER(10),
    cod_supervisor  NUMBER(5),
    CONSTRAINT MECANICO_PK           PRIMARY KEY (cod_mecanico),
    CONSTRAINT MECANICO_FK_MECANICO  FOREIGN KEY (cod_supervisor) REFERENCES MECANICO(cod_mecanico)
);

-- CLIENTE
CREATE TABLE CLIENTE (
    rut      NUMBER(8)     NOT NULL,
    dv       CHAR(1)       NOT NULL,
    pnombre  VARCHAR2(20)  NOT NULL,
    snombre  VARCHAR2(20),
    apaterno VARCHAR2(20)  NOT NULL,
    amaterno VARCHAR2(20),
    telefono VARCHAR2(12),
    email    VARCHAR2(40),
    tipo_cli CHAR(1)       NOT NULL,
    CONSTRAINT CLIENTE_PK PRIMARY KEY (rut)
);

-- TIPO_AUTOMOVIL
CREATE TABLE TIPO_AUTOMOVIL (
    id_tipo     CHAR(3)       NOT NULL,
    descripcion VARCHAR2(20)  NOT NULL,
    CONSTRAINT TIPO_AUTOMOVIL_PK PRIMARY KEY (id_tipo)
);

-- MARCA
CREATE TABLE MARCA (
    id_marca    NUMBER(2)     NOT NULL,
    descripcion VARCHAR2(20)  NOT NULL,
    CONSTRAINT MARCA_PK PRIMARY KEY (id_marca)
);

-- MODELO
CREATE TABLE MODELO (
    id_modelo   NUMBER(5)     NOT NULL,
    marca_id    NUMBER(2)     NOT NULL,
    annio       NUMBER(4),
    descripcion VARCHAR2(20)  NOT NULL,
    CONSTRAINT MODELO_PK       PRIMARY KEY (id_modelo, marca_id),
    CONSTRAINT MODELO_FK_MARCA FOREIGN KEY (marca_id) REFERENCES MARCA(id_marca)
);

-- AUTOMOVIL
CREATE TABLE AUTOMOVIL (
    patente       CHAR(8)       NOT NULL,
    annio         NUMBER(4),
    cant_puertas  NUMBER(1),
    km            NUMBER(6),
    color         VARCHAR2(30),
    cod_tipo_auto CHAR(3)       NOT NULL,
    cod_modelo    NUMBER(5)     NOT NULL,
    cod_marca     NUMBER(2)     NOT NULL,
    cl_rut        NUMBER(8)     NOT NULL,
    CONSTRAINT AUTOMOVIL_PK          PRIMARY KEY (patente),
    CONSTRAINT AUTOMOVIL_FK_CLIENTE  FOREIGN KEY (cl_rut)                        REFERENCES CLIENTE(rut),
    CONSTRAINT AUTOMOVIL_FK_MODELO   FOREIGN KEY (cod_modelo, cod_marca)         REFERENCES MODELO(id_modelo, marca_id),
    CONSTRAINT AUTOMOVIL_FK_TIPO     FOREIGN KEY (cod_tipo_auto)                 REFERENCES TIPO_AUTOMOVIL(id_tipo)
);

-- SERVICIO
CREATE TABLE SERVICIO (
    id_servicio NUMBER(3)     NOT NULL,
    descripcion VARCHAR2(100) NOT NULL,
    costo       NUMBER(7)     NOT NULL,
    CONSTRAINT SERVICIO_PK PRIMARY KEY (id_servicio)
);

-- MANTENCION (con costo_total incluido inicialmente, se elimina en Caso 2)
CREATE TABLE MANTENCION (
    num_mantencion NUMBER(4)     NOT NULL,
    cod_sucursal   CHAR(3)       NOT NULL,
    fecha_ingreso  DATE          NOT NULL,
    fecha_salida   DATE,
    patente_auto   CHAR(8),
    cod_mecanico   NUMBER(5)     NOT NULL,
    costo_total    NUMBER(7),
    estado         VARCHAR2(15)  NOT NULL,
    CONSTRAINT MANTENCION_PK          PRIMARY KEY (num_mantencion),
    CONSTRAINT MANT_FK_AUTOMOVIL      FOREIGN KEY (patente_auto)   REFERENCES AUTOMOVIL(patente),
    CONSTRAINT MANT_FK_MECANICO       FOREIGN KEY (cod_mecanico)   REFERENCES MECANICO(cod_mecanico),
    CONSTRAINT MANT_FK_SUCURSAL       FOREIGN KEY (cod_sucursal)   REFERENCES SUCURSAL(id_sucursal)
);

-- DETALLE_SERVICIO
CREATE TABLE DETALLE_SERVICIO (
    mantencion_num NUMBER(4)   NOT NULL,
    cod_servicio   NUMBER(3)   NOT NULL,
    descuento_serv NUMBER(4,3),
    cantidad       NUMBER(3)   NOT NULL,
    CONSTRAINT DETALLE_SERVICIO_PK       PRIMARY KEY (mantencion_num, cod_servicio),
    CONSTRAINT DET_SERV_FK_MANTENCION    FOREIGN KEY (mantencion_num) REFERENCES MANTENCION(num_mantencion),
    CONSTRAINT DET_SERV_FK_SERVICIO      FOREIGN KEY (cod_servicio)   REFERENCES SERVICIO(id_servicio)
);

-- ESTANDAR (subtipo de CLIENTE)
CREATE TABLE ESTANDAR (
    cl_rut          NUMBER(8)   NOT NULL,
    puntaje_fidelidad NUMBER(10),
    CONSTRAINT NORMAL_PK       PRIMARY KEY (cl_rut),
    CONSTRAINT NORMAL_FK_CLIENTE FOREIGN KEY (cl_rut) REFERENCES CLIENTE(rut)
);

-- PREMIUM (subtipo de CLIENTE)
CREATE TABLE PREMIUM (
    cl_rut         NUMBER(8)   NOT NULL,
    pesos_clientes NUMBER(10),
    monto_credito  NUMBER(10),
    CONSTRAINT PREMIUM_PK       PRIMARY KEY (cl_rut),
    CONSTRAINT PREMIUM_FK_CLIENTE FOREIGN KEY (cl_rut) REFERENCES CLIENTE(rut)
);


-- ============================================================
-- CASO 2: MODIFICACION DEL MODELO - ALTER TABLE
-- ============================================================

-- 1. Eliminar atributo derivado costo_total de MANTENCION
ALTER TABLE MANTENCION DROP COLUMN costo_total;

-- 2. Cambiar PK de MANTENCION a compuesta (num_mantencion + cod_sucursal)
--    y ajustar la FK en DETALLE_SERVICIO

-- Eliminar FK que referencia la PK actual en DETALLE_SERVICIO
ALTER TABLE DETALLE_SERVICIO DROP CONSTRAINT DET_SERV_FK_MANTENCION;

-- Eliminar PK actual de MANTENCION
ALTER TABLE MANTENCION DROP CONSTRAINT MANTENCION_PK;

-- Crear nueva PK compuesta en MANTENCION
ALTER TABLE MANTENCION ADD CONSTRAINT MANTENCION_PK PRIMARY KEY (num_mantencion, cod_sucursal);

-- Agregar columna cod_sucursal en DETALLE_SERVICIO para la nueva FK
ALTER TABLE DETALLE_SERVICIO ADD cod_sucursal CHAR(3);

-- Actualizar la nueva columna con los datos existentes
UPDATE DETALLE_SERVICIO DS
SET DS.cod_sucursal = (
    SELECT M.cod_sucursal
    FROM MANTENCION M
    WHERE M.num_mantencion = DS.mantencion_num
);

-- Agregar NOT NULL a la nueva columna
ALTER TABLE DETALLE_SERVICIO MODIFY cod_sucursal CHAR(3) NOT NULL;

-- Rehacer la PK de DETALLE_SERVICIO incluyendo cod_sucursal
ALTER TABLE DETALLE_SERVICIO DROP CONSTRAINT DETALLE_SERVICIO_PK;
ALTER TABLE DETALLE_SERVICIO ADD CONSTRAINT DETALLE_SERVICIO_PK PRIMARY KEY (mantencion_num, cod_sucursal, cod_servicio);

-- Agregar nueva FK en DETALLE_SERVICIO hacia la PK compuesta de MANTENCION
ALTER TABLE DETALLE_SERVICIO ADD CONSTRAINT DET_SERV_FK_MANTENCION
    FOREIGN KEY (mantencion_num, cod_sucursal) REFERENCES MANTENCION(num_mantencion, cod_sucursal);

-- 3. UNIQUE en email de CLIENTE (opcional, pero unico si se registra)
ALTER TABLE CLIENTE ADD CONSTRAINT CLIENTE_UN_EMAIL UNIQUE (email);

-- 4. CHECK en dv de CLIENTE
ALTER TABLE CLIENTE ADD CONSTRAINT CLIENTE_CK_DV
    CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- 5. CHECK sueldo minimo mecánico >= 510000
ALTER TABLE MECANICO ADD CONSTRAINT MECANICO_CK_SUELDO
    CHECK (sueldo >= 510000);

-- 6. CHECK estados validos de MANTENCION
ALTER TABLE MANTENCION ADD CONSTRAINT MANTENCION_CK_ESTADO
    CHECK (estado IN ('Reserva','Ingresado','Entregado','Anulado'));


-- ============================================================
-- CASO 3: POBLAMIENTO DEL MODELO - SENTENCIAS DML
-- ============================================================

-- Secuencia para SERVICIO: inicia en 400, incrementa en 2
CREATE SEQUENCE SEQ_SERVICIO START WITH 400 INCREMENT BY 2;

-- Secuencia para CIUDAD: inicia en 165, incrementa en 5
CREATE SEQUENCE SEQ_CIUDAD START WITH 165 INCREMENT BY 5;

-- -------------------------------------------------------
-- PAIS (identity: inicia en 9, incrementa en 3)
-- -------------------------------------------------------
INSERT INTO PAIS (nom_pais) VALUES ('Chile');
INSERT INTO PAIS (nom_pais) VALUES ('Peru');
INSERT INTO PAIS (nom_pais) VALUES ('Colombia');

-- -------------------------------------------------------
-- CIUDAD (secuencia SEQ_CIUDAD: 165, 170, 175)
-- -------------------------------------------------------
INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Santiago', 9);
INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Lima',     12);
INSERT INTO CIUDAD (id_ciudad, nom_ciudad, cod_pais) VALUES (SEQ_CIUDAD.NEXTVAL, 'Bogota',   15);

-- -------------------------------------------------------
-- SUCURSAL
-- -------------------------------------------------------
INSERT INTO SUCURSAL (id_sucursal, nom_sucursal,    calle,         num_calle, cod_ciudad)
    VALUES ('S01', 'Providencia',   'Av. A. Varas',  234,  165);
INSERT INTO SUCURSAL (id_sucursal, nom_sucursal,    calle,         num_calle, cod_ciudad)
    VALUES ('S02', 'Las 4 esquinas','Av. Latina',    669,  170);
INSERT INTO SUCURSAL (id_sucursal, nom_sucursal,    calle,         num_calle, cod_ciudad)
    VALUES ('S03', 'El Cafetero',   'Av. El Faro',   900,  175);

-- -------------------------------------------------------
-- MECANICO (identity: inicia en 460, incrementa en 7)
-- -------------------------------------------------------

-- Insertar todos sin supervisor primero, para luego actualizar
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Jorge',    'Pablo',    'Soto',      'Sierpe',  5400000, 2759000, 223580, NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Pedro',    'Jose',     'Manriquez', 'Corral',  NULL,    759000,  23980,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Sandra',   'Josefa',   'Letelier',  'S.',      0,       659000,  22358,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Felipe',   'M.',       'Vidal',     'A.',      NULL,    759000,  23580,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Jose',     'Miguel',   'Troncoso',  'B.',      NULL,    659000,  44580,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Juan',     'Pablo',    'Sanchez',   'R.',      NULL,    859000,  23380,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Carlos',   'Felipe',   'Soto',      'J.',      0,       597000,  23580,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Alberto',  'P.',       'Cerda',     'Ramirez', NULL,    559000,  22380,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Alejandra','Gabriela', 'Infanti',   'R.',      NULL,    659000,  22380,  NULL);
INSERT INTO MECANICO (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
    VALUES ('Roberto',  'Patricio', 'Gutierrez', 'Sosa',    NULL,    859000,  22380,  NULL);

-- Actualizar supervisores
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 474;
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 481;
UPDATE MECANICO SET cod_supervisor = 474 WHERE cod_mecanico = 488;
UPDATE MECANICO SET cod_supervisor = 474 WHERE cod_mecanico = 495;
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 502;
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 509;
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 516;
UPDATE MECANICO SET cod_supervisor = 460 WHERE cod_mecanico = 523;

-- -------------------------------------------------------
-- SERVICIO (secuencia SEQ_SERVICIO)
-- -------------------------------------------------------
INSERT INTO SERVICIO (id_servicio, descripcion,           costo)
    VALUES (SEQ_SERVICIO.NEXTVAL, 'Cambio Luces',          45000);
INSERT INTO SERVICIO (id_servicio, descripcion,           costo)
    VALUES (SEQ_SERVICIO.NEXTVAL, 'Desabolladura',         67000);
INSERT INTO SERVICIO (id_servicio, descripcion,           costo)
    VALUES (SEQ_SERVICIO.NEXTVAL, 'Revision Frenos',       30000);
INSERT INTO SERVICIO (id_servicio, descripcion,           costo)
    VALUES (SEQ_SERVICIO.NEXTVAL, 'Cambio Puerta Trasera', 50000);

-- -------------------------------------------------------
-- TIPO_AUTOMOVIL
-- -------------------------------------------------------
INSERT INTO TIPO_AUTOMOVIL (id_tipo, descripcion) VALUES ('SUV', 'SUV');
INSERT INTO TIPO_AUTOMOVIL (id_tipo, descripcion) VALUES ('SED', 'Sedan');
INSERT INTO TIPO_AUTOMOVIL (id_tipo, descripcion) VALUES ('HAT', 'Hatchback');

-- -------------------------------------------------------
-- MARCA
-- -------------------------------------------------------
INSERT INTO MARCA (id_marca, descripcion) VALUES (1, 'Toyota');
INSERT INTO MARCA (id_marca, descripcion) VALUES (2, 'Hyundai');

-- -------------------------------------------------------
-- MODELO
-- -------------------------------------------------------
INSERT INTO MODELO (id_modelo, marca_id, annio, descripcion) VALUES (1, 1, 2020, 'Corolla');
INSERT INTO MODELO (id_modelo, marca_id, annio, descripcion) VALUES (2, 2, 2019, 'Tucson');

-- -------------------------------------------------------
-- CLIENTE
-- -------------------------------------------------------
INSERT INTO CLIENTE (rut, dv, pnombre, apaterno, tipo_cli)
    VALUES (12345678, '9', 'Cliente',  'Uno',  'E');
INSERT INTO CLIENTE (rut, dv, pnombre, apaterno, tipo_cli)
    VALUES (23456789, '0', 'Cliente',  'Dos',  'P');

-- -------------------------------------------------------
-- AUTOMOVIL
-- -------------------------------------------------------
INSERT INTO AUTOMOVIL (patente, cod_tipo_auto, cod_modelo, cod_marca, cl_rut)
    VALUES ('ABCD1234', 'SUV', 1, 1, 12345678);
INSERT INTO AUTOMOVIL (patente, cod_tipo_auto, cod_modelo, cod_marca, cl_rut)
    VALUES ('EFGH5678', 'SED', 2, 2, 23456789);

-- -------------------------------------------------------
-- MANTENCION (sin costo_total, con PK compuesta)
-- -------------------------------------------------------
INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
    VALUES (101, 'S01', TO_DATE('12-04-2023','DD-MM-YYYY'), NULL,                              NULL,        481, 'Reserva');
INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
    VALUES (102, 'S01', TO_DATE('21-02-2023','DD-MM-YYYY'), TO_DATE('21-02-2023','DD-MM-YYYY'), NULL,        502, 'Entregado');
INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
    VALUES (103, 'S02', TO_DATE('09-10-2023','DD-MM-YYYY'), NULL,                              NULL,        502, 'Anulado');
INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
    VALUES (104, 'S03', TO_DATE('11-08-2023','DD-MM-YYYY'), TO_DATE('18-08-2023','DD-MM-YYYY'), NULL,        509, 'Entregado');
INSERT INTO MANTENCION (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
    VALUES (105, 'S03', TO_DATE('03-12-2023','DD-MM-YYYY'), NULL,                              NULL,        509, 'Ingresado');

-- Confirmar los cambios
COMMIT;


-- ============================================================
-- CASO 4: RECUPERACION DE DATOS - INFORMES
-- ============================================================

-- -------------------------------------------------------
-- INFORME 1: Mecanicos con bono_jefatura nulo y monto_impuestos < 40000
-- Ordenado por monto_impuestos DESC, apaterno ASC
-- -------------------------------------------------------
SELECT
    cod_mecanico                                        AS "ID MECANICO",
    pnombre || ' ' || apaterno                          AS "NOMBRE MECANICO",
    sueldo                                              AS "SALARIO",
    monto_impuestos                                     AS "IMPUESTO ACTUAL",
    ROUND(monto_impuestos * 0.80)                       AS "IMPUESTO REBAJADO",
    sueldo - ROUND(monto_impuestos * 0.80)              AS "SUELDO CON REBAJA IMPUESTOS"
FROM MECANICO
WHERE bono_jefatura IS NULL
  AND monto_impuestos < 40000
ORDER BY monto_impuestos DESC, apaterno ASC;


-- -------------------------------------------------------
-- INFORME 2: Mecanicos con sueldo entre 600000 y 900000 O sin supervisor
-- Ajuste salarial del 5%
-- Ordenado por sueldo ASC, nombre completo DESC
-- -------------------------------------------------------
SELECT
    cod_mecanico                                        AS "IDENTIFICADOR",
    pnombre || ' ' || snombre || ' ' || apaterno        AS "MECANICO",
    sueldo                                              AS "SALARIO ACTUAL",
    ROUND(sueldo * 0.05)                                AS "AJUSTE",
    sueldo + ROUND(sueldo * 0.05)                       AS "SUELDO_REAJUSTADO"
FROM MECANICO
WHERE (sueldo BETWEEN 600000 AND 900000)
   OR cod_supervisor IS NULL
ORDER BY sueldo ASC, (pnombre || ' ' || snombre || ' ' || apaterno) DESC;