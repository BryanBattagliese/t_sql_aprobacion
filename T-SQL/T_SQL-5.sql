use[GD2015C1] go

/* Implementar una regla de negocio en línea donde se valide que nunca
un producto compuesto pueda estar compuesto por componentes de
rubros distintos a el */

create trigger rubro_producto on composicion 
instead of insert 
as 
begin 
	if not exists ( 
		select 1 
		from inserted i 
		join Producto p on p.prod_codigo=i.comp_producto 
		join Producto p2 on p2.prod_codigo=i.comp_componente 
		where p.prod_rubro <> p2.prod_rubro 
	) 
	begin 
		insert into Composicion(comp_cantidad,comp_componente,comp_producto) 
		select i.comp_cantidad, i.comp_componente, i.comp_producto 
		from inserted i 
	end 
	else 
	print 'error' 
end 
go

--- --- ---

-------- FUNCION
create function productoComposicionTieneComponentesDeRubrosDistintos(@producto char(8))
RETURNS int 
AS
BEGIN 
	DECLARE @rubroIdCompProducto char(4),@rubroCompComponente char(4)

	-- “Guardame en @rubroIdCompProducto el rubro del producto cuyo código es @producto.” (@producto sera el "inserted" i)
	set @rubroIdCompProducto = (select P.prod_rubro 
								from Producto P 
								where P.prod_codigo = @producto)

	-- declaramos cursor para recorrer los componetes 
	-- este cursor va a devolver una tabla con todos los componentes de ese producto
	DECLARE cursor_composicion CURSOR FOR	 
		SELECT 
			P.prod_rubro
		 FROM Composicion C
			INNER JOIN Producto P 
				ON P.prod_codigo = C.comp_componente

		 WHERE C.comp_producto = @producto

	OPEN cursor_composicion
		FETCH NEXT FROM cursor_composicion INTO @rubroCompComponente
		WHILE(@@FETCH_STATUS = 0)
			BEGIN
				-- si el rubro que compone al producto es distinto , entonces termina la funcion
				IF(@rubroIdCompProducto <> @rubroCompComponente)
					BEGIN
						RETURN 1
					END

				FETCH NEXT FROM cursor_composicion INTO @rubroCompComponente
			END
	CLOSE cursor_composicion
	DEALLOCATE cursor_composicion
	
	-- NO TIENE COMPONENTES DE RUBROS DISTINTOS
	RETURN 0

END
go

-------- TRIGGER
CREATE TRIGGER triggerProductoComp ON Producto 
INSTEAD OF UPDATE,INSERT 
AS
BEGIN
	IF(select dbo.productoComposicionTieneComponentesDeRubrosDistintos(I.prod_codigo) from inserted I) = 1
		BEGIN 
			 
			RAISERROR ('PRODUCTO COMPUESTO NO PUEDE TENER COMPONENTES DE DISTINTO RUBRO', 16, 1)
		
			ROLLBACK TRANSACTION
		END
END