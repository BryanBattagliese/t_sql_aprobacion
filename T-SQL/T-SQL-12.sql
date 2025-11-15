/*2. Se requiere realizar una verificación de los precios de los COMBOS, para
ello se solicita que cree el o los objetos necesarios para realizar una
operación que actualice que el precio de un producto compuesto
(COMBO) es el 90% de la suma de los precios de sus componentes por
las cantidades que los componen. Se debe considerar que un producto
compuesto puede estar compuesto por otros productos compuestos.*/

/* =========================================================
   1) FUNCION: suma recursiva de precios de componentes
      (soporta productos compuestos dentro de productos compuestos)
   ========================================================= */
CREATE FUNCTION dbo.sumatoria_precio_componentes
(
    @codigo_producto CHAR(8)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @componente          CHAR(8),
            @precio_final        DECIMAL(12,2) = 0,
            @cantidad_componente INT,
            @precio_componente   DECIMAL(12,2);

    -- Solo entra si el producto es compuesto (aparece como comp_producto)
    IF EXISTS (
        SELECT 1
        FROM Composicion C
        WHERE C.comp_producto = @codigo_producto
    )
    BEGIN
        DECLARE el_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT C.comp_componente,
                   P.prod_precio,
                   C.comp_cantidad
            FROM Composicion C
            INNER JOIN Producto P
                ON P.prod_codigo = C.comp_componente
            WHERE C.comp_producto = @codigo_producto;

        OPEN el_cursor;
        FETCH NEXT FROM el_cursor
            INTO @componente, @precio_componente, @cantidad_componente;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Si el componente NO es un producto compuesto (no aparece como comp_producto)
            IF NOT EXISTS (
                SELECT 1
                FROM Composicion C1
                WHERE C1.comp_producto = @componente
            )
            BEGIN
                SET @precio_final = @precio_final
                                  + @precio_componente * @cantidad_componente;
            END
            -- El componente ES, a su vez, un producto compuesto: recursion
            ELSE
            BEGIN
                SET @precio_final = @precio_final
                                  + dbo.sumatoria_precio_componentes(@componente)
                                  * @cantidad_componente;
            END;

            FETCH NEXT FROM el_cursor
                INTO @componente, @precio_componente, @cantidad_componente;
        END;

        CLOSE el_cursor;
        DEALLOCATE el_cursor;
    END;

    RETURN @precio_final;
END;
GO


/* =========================================================
   2) PROCEDURE: actualiza precio de TODOS los combos
      Precio combo = 90% de la suma de componentes*cantidad
   ========================================================= */
CREATE PROCEDURE dbo.actualizar_precios_combos
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE P
    SET prod_precio = dbo.sumatoria_precio_componentes(P.prod_codigo) * 0.9
    FROM Producto P
    WHERE EXISTS (
        SELECT 1
        FROM Composicion C
        WHERE C.comp_producto = P.prod_codigo
    );
END;
GO


/* =========================================================
   3) TRIGGER sobre PRODUCTO:
      Cuando cambia un producto (por ej. precio de componente
      o alta/modificación de un combo), recalcula precios de combos
   ========================================================= */
CREATE TRIGGER trg_actualizar_combos_por_producto
ON Producto
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.actualizar_precios_combos;
END;
GO


/* =========================================================
   4) TRIGGER sobre COMPOSICION:
      Cuando cambia la composición (componentes/cantidades)
      recalcula precios de combos
   ========================================================= */
CREATE TRIGGER trg_actualizar_combos_por_composicion
ON Composicion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.actualizar_precios_combos;
END;
GO






