USE GD2015C1
GO

/* Se creo una tabla ventas cuyos campos son:
- Periodo (YYYYMM)
- Producto
- Cliente
- Cantidad unidades
- Precio promedio

Por error se ejecuo un update sobre ventas y dejo los años impares con las cantidades incorrectas
Arreglar dicha informacion e implementar una logica para que siempre quede actualizada con la info pertinente
*/

-- Creo la tabla
create table Ventas(

	periodo datetime,
	producto char(8),
	cliente numeric(6),
	unidades decimal(12,2), 
	precio_prom decimal(12,2)

)

-- Arreglar información: procedimiento // hacer consistente los registros existentes
UPDATE v SET v.unidades = (
	
	SELECT isnull(sum(i.item_cantidad),0)
	FROM Factura f join Item_Factura i on i.item_numero+i.item_sucursal+i.item_tipo=f.fact_numero+f.fact_sucursal+f.fact_tipo
	WHERE	(f.fact_cliente = v.cliente) and 
			(i.item_producto = v.producto) and
			(YEAR(f.fact_fecha) = YEAR(v.periodo)) and 
			(MONTH(f.fact_fecha) = MONTH(v.periodo))

)
FROM Ventas v
WHERE (YEAR(v.periodo) % 2 <> 0)
GO

-- Evitar que vuelva a suceder TRIGGER
CREATE TRIGGER GIT8 ON Item_Factura AFTER INSERT, UPDATE
AS
BEGIN

	-- Si existen registros para ese periodo
	IF EXISTS (
		SELECT 1 
		FROM inserted i join factura f on i.item_numero+i.item_sucursal+i.item_tipo=f.fact_numero+f.fact_sucursal+f.fact_tipo
		WHERE YEAR(f.fact_fecha)  = (SELECT YEAR(v.periodo) FROM Ventas v) and
			  MONTH(f.fact_fecha) = (SELECT MONTH(v.periodo) FROM Ventas v)
	)
	
	BEGIN
		-- UPDATE DE LOS CAMPOS DE VENTAS . . .
	END

	-- Si no existen registros para ese periodo
	--ELSE
	--BEGIN
		-- CREO EL REGISTRO EN VENTAS PARA ESE PERIODO Y CARGO LOS DATOS ...
	--END
END
GO