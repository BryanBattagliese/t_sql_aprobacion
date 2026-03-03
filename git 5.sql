use GD2015C1
go

/* GIT 5: trigger de control */

/* Implementar una regla de negocio en línea donde se valide 
que nunca un producto compuesto pueda estar compuesto por 
componentes de rubros distintos a el */

CREATE TRIGGER validar_rubro_composicion ON Composicion 
AFTER INSERT, UPDATE
AS
BEGIN
    
    IF EXISTS(
        SELECT 1
        FROM inserted i 
        JOIN Producto p_padre ON p_padre.prod_codigo = i.comp_producto
        JOIN Producto p_hijo ON p_hijo.prod_codigo = i.comp_componente
        WHERE p_padre.prod_rubro <> p_hijo.prod_rubro
    )
    BEGIN
        PRINT 'El componente no puede ser de un rubro distinto al producto principal.'
        ROLLBACK TRANSACTION
    END
END
GO