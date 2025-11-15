use[GD2015C1] go

/* Actualmente el campo fact_vendedor representa al empleado que vendió
la factura. Implementar el/los objetos necesarios para respetar la
integridad referenciales de dicho campo suponiendo que no existe una
foreign key entre ambos.

NOTA: No se puede usar una foreign key para el ejercicio, deberá buscar
otro método */

create trigger validar_vendedor_i on Factura
instead of insert
as
begin
	
	if exists(
		select 1
		from inserted f
		where f.fact_vendedor is not null and
		not exists(
			select 1
			from Empleado e
			where e.empl_codigo = f.fact_vendedor 
		)	
	)
	begin 
        rollback transaction 
    end

	else
	begin
		insert into Factura
		select f.fact_cliente,f.fact_fecha,f.fact_numero,f.fact_sucursal,f.fact_tipo,f.fact_total,f.fact_total_impuestos,f.fact_vendedor
		from inserted f
	end
end
go

create trigger validar_vendedor_u on Factura
instead of update
as
begin
	
	if exists(
		select 1
		from inserted f
		where f.fact_vendedor is not null and
		not exists(
			select 1
			from Empleado e
			where e.empl_codigo = f.fact_vendedor 
		)	
	)
	begin 
        rollback transaction 
    end

	else
	begin
		update Factura
		set fact_cliente = f.fact_cliente,
			fact_fecha = f.fact_fecha,
			fact_numero = f.fact_numero,
			fact_sucursal = f.fact_sucursal,
			fact_tipo = f.fact_tipo,
			fact_total = f.fact_total,
			fact_total_impuestos = f.fact_total_impuestos,
			fact_vendedor = f.fact_vendedor
		from inserted f
		where factura.fact_tipo = f.fact_tipo and factura.fact_sucursal = f.fact_sucursal and factura.fact_numero = f.fact_numero
	end
end
go
