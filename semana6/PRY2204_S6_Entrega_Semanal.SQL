-- ======================================================
-- CASO 1: CREACIÓN DE TABLAS
-- Sistema de gestión de recetas médicas
-- Consultorio Médico Municipalidad Santa Gema
-- ======================================================

-- Borrado de tablas existentes (orden inverso por dependencias)
DROP TABLE PAGO CASCADE CONSTRAINTS;
DROP TABLE RECETA_MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE RECETA CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE TIPO_MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE TIPO_RECETA CASCADE CONSTRAINTS;
DROP TABLE DIGITADOR CASCADE CONSTRAINTS;
DROP TABLE MEDICO CASCADE CONSTRAINTS;
DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS;
DROP TABLE PACIENTE CASCADE CONSTRAINTS;
DROP TABLE CIUDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;

-- Regiones del país
CREATE TABLE REGION (
    id_region NUMBER(2) PRIMARY KEY,
    nombre_region VARCHAR2(100) NOT NULL
);

-- Comunas con ID auto-incremental desde 1101
CREATE TABLE COMUNA (
    id_comuna NUMBER(6) GENERATED ALWAYS AS IDENTITY (START WITH 1101 INCREMENT BY 1) PRIMARY KEY,
    nombre_comuna VARCHAR2(100) NOT NULL,
    id_region NUMBER(2) NOT NULL,
    CONSTRAINT fk_comuna_region FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

-- Ciudades asociadas a comunas
CREATE TABLE CIUDAD (
    id_ciudad NUMBER(6) PRIMARY KEY,
    nombre_ciudad VARCHAR2(100) NOT NULL,
    id_comuna NUMBER(6) NOT NULL,
    CONSTRAINT fk_ciudad_comuna FOREIGN KEY (id_comuna) REFERENCES COMUNA(id_comuna)
);

-- Especialidades médicas con ID auto-incremental
CREATE TABLE ESPECIALIDAD (
    id_especialidad NUMBER(6) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_especialidad VARCHAR2(100) NOT NULL
);

-- Catálogo de tipos de recetas
CREATE TABLE TIPO_RECETA (
    id_tipo_receta NUMBER(2) PRIMARY KEY,
    nombre_tipo_receta VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_tipo_receta CHECK (nombre_tipo_receta IN ('DIGITAL', 'MAGISTRAL', 'RETENIDA', 'GENERAL', 'VETERINARIA'))
);

-- Catálogo de tipos de medicamentos
CREATE TABLE TIPO_MEDICAMENTO (
    id_tipo_medicamento NUMBER(2) PRIMARY KEY,
    nombre_tipo_medicamento VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_tipo_medicamento CHECK (nombre_tipo_medicamento IN ('GENERICO', 'MARCA'))
);

-- Pacientes del consultorio con dirección completa
CREATE TABLE PACIENTE (
    rut_paciente NUMBER(8) PRIMARY KEY,
    dv_paciente VARCHAR2(1) NOT NULL,
    nombres_paciente VARCHAR2(100) NOT NULL,
    apellidos_paciente VARCHAR2(100) NOT NULL,
    edad NUMBER(3),
    telefono_paciente VARCHAR2(15),
    email_paciente VARCHAR2(100),
    id_ciudad NUMBER(6) NOT NULL,
    CONSTRAINT fk_paciente_ciudad FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad),
    CONSTRAINT chk_dv_paciente CHECK (dv_paciente IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

-- Médicos del consultorio con teléfono único
CREATE TABLE MEDICO (
    rut_medico NUMBER(8) PRIMARY KEY,
    dv_medico VARCHAR2(1) NOT NULL,
    nombres_medico VARCHAR2(100) NOT NULL,
    apellidos_medico VARCHAR2(100) NOT NULL,
    telefono_medico VARCHAR2(15) NOT NULL,
    email_medico VARCHAR2(100),
    id_especialidad NUMBER(6) NOT NULL,
    CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad),
    CONSTRAINT chk_dv_medico CHECK (dv_medico IN ('0','1','2','3','4','5','6','7','8','9','K')),
    CONSTRAINT uk_telefono_medico UNIQUE (telefono_medico)
);

-- Digitadores que ingresan recetas al sistema
CREATE TABLE DIGITADOR (
    rut_digitador NUMBER(8) PRIMARY KEY,
    dv_digitador VARCHAR2(1) NOT NULL,
    nombres_digitador VARCHAR2(100) NOT NULL,
    apellidos_digitador VARCHAR2(100) NOT NULL,
    telefono_digitador VARCHAR2(15),
    email_digitador VARCHAR2(100),
    CONSTRAINT chk_dv_digitador CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

-- Medicamentos disponibles con stock
CREATE TABLE MEDICAMENTO (
    id_medicamento NUMBER(8) PRIMARY KEY,
    nombre_medicamento VARCHAR2(200) NOT NULL,
    dosis_recomendada VARCHAR2(100) NOT NULL,
    stock_disponible NUMBER(10) NOT NULL,
    id_tipo_medicamento NUMBER(2) NOT NULL,
    CONSTRAINT fk_medicamento_tipo FOREIGN KEY (id_tipo_medicamento) REFERENCES TIPO_MEDICAMENTO(id_tipo_medicamento),
    CONSTRAINT chk_stock_positivo CHECK (stock_disponible >= 0)
);

-- Recetas médicas emitidas por médicos
CREATE TABLE RECETA (
    id_receta NUMBER(10) PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    observaciones VARCHAR2(500),
    fecha_expiracion DATE,
    diagnostico VARCHAR2(500) NOT NULL,
    rut_paciente NUMBER(8) NOT NULL,
    rut_medico NUMBER(8) NOT NULL,
    rut_digitador NUMBER(8) NOT NULL,
    id_tipo_receta NUMBER(2) NOT NULL,
    CONSTRAINT fk_receta_paciente FOREIGN KEY (rut_paciente) REFERENCES PACIENTE(rut_paciente),
    CONSTRAINT fk_receta_medico FOREIGN KEY (rut_medico) REFERENCES MEDICO(rut_medico),
    CONSTRAINT fk_receta_digitador FOREIGN KEY (rut_digitador) REFERENCES DIGITADOR(rut_digitador),
    CONSTRAINT fk_receta_tipo FOREIGN KEY (id_tipo_receta) REFERENCES TIPO_RECETA(id_tipo_receta),
    CONSTRAINT chk_fecha_expiracion CHECK (fecha_expiracion IS NULL OR fecha_expiracion >= fecha_emision)
);

-- Detalle de medicamentos por receta (relación N:N)
CREATE TABLE RECETA_MEDICAMENTO (
    id_receta NUMBER(10) NOT NULL,
    id_medicamento NUMBER(8) NOT NULL,
    cantidad NUMBER(5) NOT NULL,
    instrucciones VARCHAR2(300),
    CONSTRAINT pk_receta_medicamento PRIMARY KEY (id_receta, id_medicamento),
    CONSTRAINT fk_rm_receta FOREIGN KEY (id_receta) REFERENCES RECETA(id_receta),
    CONSTRAINT fk_rm_medicamento FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO(id_medicamento),
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0)
);

-- Pagos asociados a recetas médicas
CREATE TABLE PAGO (
    id_pago NUMBER(10) PRIMARY KEY,
    monto_pago NUMBER(10,2) NOT NULL,
    fecha_pago DATE NOT NULL,
    id_receta NUMBER(10) NOT NULL,
    CONSTRAINT fk_pago_receta FOREIGN KEY (id_receta) REFERENCES RECETA(id_receta),
    CONSTRAINT chk_monto_positivo CHECK (monto_pago > 0)
);

-- ======================================================
-- CASO 2: MODIFICACIONES CON ALTER TABLE
-- Reglas adicionales detectadas posterior a implementación
-- ======================================================

-- Agregar precio unitario a medicamentos
ALTER TABLE MEDICAMENTO ADD (precio_unitario NUMBER(10,2));

-- Validar rango de precio entre $1.000 y $2.000.000
ALTER TABLE MEDICAMENTO ADD CONSTRAINT chk_precio_unitario CHECK (precio_unitario BETWEEN 1000 AND 2000000);

-- Agregar método de pago
ALTER TABLE PAGO ADD (metodo_pago VARCHAR2(20));

-- Validar métodos de pago permitidos
ALTER TABLE PAGO ADD CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));

-- Agregar fecha de nacimiento para optimizar cálculo de edad
ALTER TABLE PACIENTE ADD (fecha_nacimiento DATE);

-- Validar que la fecha de nacimiento sea anterior a hoy
ALTER TABLE PACIENTE ADD CONSTRAINT chk_fecha_nacimiento CHECK (fecha_nacimiento < SYSDATE);

-- Eliminar columna edad (reemplazada por fecha_nacimiento)
ALTER TABLE PACIENTE DROP COLUMN edad;
