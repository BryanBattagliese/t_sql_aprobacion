use[GD2015C1] go

/* Se agregó recientemente un campo CUIT a la tabla de clientes. Debido a un
error, se generaron múltiples registros de clientes con el mismo CUIT.
Se deberá desarrollar un algoritmo de depuración de datos que identifique y corrija
estos duplicados, manteniendo un único registro por CUIT. Será necesario definir un
criterio de selección para determinar qué registro conservar y cuáles eliminar.
Adicionalmente, se deberá implementar una restricción que impida la creación futura
de registros con CUIT duplicado. */

-- Agrego el cuit en la tabla cliente
alter table cliente add clie_cuit char(13)

-- Creo una tabla de clientes AUX 
create table cliente_aux(cuit char(13), codigo char(6))

-- Inserto en esta tabla auxiliar, el codigo de cliente MENOR con ese cuit (el primero al que se le asigno...)
insert into cliente_aux
select
	min(clie_codigo),
	clie_cuit
from cliente
group by clie_cuit

-- Seteo como NULLS todos los cuits en la tabla original
update cliente set clie_cuit = null

-- Seteo los cuits en base a la tabla auxiliar
update cliente set clie_cuit = (select cuit from cliente_aux where codigo = clie_codigo)

-- Añado una restriccion para que no vuelva a ocurrir
alter table cliente add constrain unica unique(clie_cuit)
 