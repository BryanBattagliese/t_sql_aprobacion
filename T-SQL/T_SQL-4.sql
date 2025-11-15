use[GD2015C1] go

/* Implementar una regla de negocio de validación en línea que permita validar el STOCK al realizarse una venta. 
Cada venta se debe descontar sobre el depósito 00. En caso de que se venda un producto compuesto, el descuento de stock se debe realizar 
por sus componentes. Si no hay STOCK para ese artículo, no se deberá guardar ese artículo, pero si los otros en los cuales hay stock 
positivo.

Es decir, solamente se deberán guardar aquellos para los cuales si hay
stock, sin guardarse los que no poseen cantidades suficientes. 

1)  - Evaluar si es producto con composicion o producto normal
2N) - Evaluar si hay stock de ese producto
3N) - Descontar stock
2C) - Evaluar para cada producto, si hay stock
3C) - Descontar para cada producto el stock

*/

create trigger validar_stock on Item_Factura
instead of insert
as
begin
	
	-- Productos NO compuestos
	if not exists(
		select 1 
		from inserted i 
		join Composicion c on c.comp_producto = i.item_producto	
	)
	begin
	begin tran
		-- Verifico y descuento el stock
		update s
		set s.stoc_cantidad = s.stoc_cantidad - i.item_cantidad
		from inserted i
		join STOCK s on s.stoc_producto=i.item_producto
		where s.stoc_cantidad >= i.item_cantidad and s.stoc_deposito = '00'

		-- Inserto en item factura
		insert into Item_Factura(item_cantidad,item_numero,item_precio,item_producto,item_sucursal,item_tipo)
		select i2.item_cantidad, i2.item_numero, i2.item_precio, i2.item_producto, i2.item_sucursal, i2.item_tipo
		from inserted i2
		join STOCK s on s.stoc_producto=i2.item_producto
		where s.stoc_cantidad >= i2.item_cantidad and s.stoc_deposito = '00'

	commit
	end
	
	-- Productos compuestos
	else
    begin
    begin tran
        -- Verifico que haya stock para TODOS los componentes ("...si no existe alguno sin stock...")
		if not exists (
            select 1
            from inserted i
            join composicion c on c.comp_producto = i.item_producto 
            join stock s on s.stoc_producto = c.comp_componente and s.stoc_deposito = '00'
            where s.stoc_cantidad is null or s.stoc_cantidad < (i.item_cantidad * c.comp_cantidad)
        )
	
	begin
		-- Hago el update en stock
        update s
        set s.stoc_cantidad = s.stoc_cantidad - (i.item_cantidad * c.comp_cantidad)
        from inserted i
        join composicion c on c.comp_producto = i.item_producto
        join stock s on s.stoc_producto = c.comp_componente and s.stoc_deposito = '00'

		-- Inserto en item factura
		insert into item_factura (item_cantidad, item_numero, item_precio, item_producto, item_sucursal, item_tipo)
        select i.item_cantidad,i.item_numero,i.item_precio,i.item_producto,i.item_sucursal,i.item_tipo
        from inserted i
	end
	commit
    end
end
go