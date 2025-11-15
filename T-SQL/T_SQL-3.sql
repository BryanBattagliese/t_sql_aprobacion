use [GD2015C1]
go

/* Implementar una regla de negocio en línea donde nunca una factura
nueva tenga un precio de producto distinto al que figura en la tabla
PRODUCTO. Registrar en una estructura adicional todos los casos
donde se intenta guardar un precio distinto. */

create table item_factura_rechazados(
	item_tipo CHAR(1),
	item_sucursal CHAR(4),
	item_numero CHAR(8),
	item_producto CHAR(8),
	item_cantidad DECIMAL(12,2),
	item_precio DECIMAL(12,2)
) go

create trigger mismo_precio on item_factura
instead of insert
as
begin
	
	if exists(
		select 1
		from inserted i join Factura f on f.fact_numero+f.fact_sucursal+f.fact_tipo=i.item_numero+i.item_sucursal+i.item_tipo
		join Producto p on p.prod_codigo=i.item_producto
		where p.prod_precio <> i.item_precio
	)

	begin
		insert into item_factura_rechazados(item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
		select i.item_tipo, i.item_sucursal, i.item_numero,i.item_producto, i.item_cantidad, i.item_precio
		from inserted i join producto p on p.prod_codigo = i.item_producto
		where i.item_precio <> p.prod_precio
	end

    else
	begin
		insert into item_factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
		select i.item_tipo, i.item_sucursal, i.item_numero, i.item_producto, i.item_cantidad, i.item_precio
		from inserted i join producto p on p.prod_codigo = i.item_producto
		where i.item_precio = p.prod_precio
	end
end
go


