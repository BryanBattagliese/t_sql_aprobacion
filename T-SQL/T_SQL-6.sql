use [GD2015C1] go

/* Suponiendo que se aplican los siguientes cambios en el modelo de
datos:

Cambio 1) create table provincia (id 'int primary key, nómbre char(100)) ;
Cambio 2) alter table cliente add pcia_id int null:

Crear el/los objetos necesarios para implementar el concepto de foreign
key entre 2 cliente y provincia,

Nota: No se permite agregar una constraint de tipo FOREIGN KEY entre la
tabla y el campo agregado. */

create table provincia (
    id int primary key,
    nombre char(100)
)

alter table Cliente add pcia_id int null

-- La idea es esta:
alter table cliente
add constraint fk_cliente_provincia
foreign key (pcia_id) references provincia(id);
go

create trigger validar_clie_pcia_i on Cliente
instead of insert
as
begin
    if exists(
        select 1
        from inserted i
        where i.pcia_id is not null and 
        not exists (
            select 1
            from provincia p
            where p.id = i.pcia_id
        )
    )

    begin 
        rollback transaction 
    end

    else
    begin
        insert into Cliente
        select i.clie_codigo,i.clie_razon_social,i.clie_telefono,i.clie_domicilio,i.clie_limite_credito,i.clie_vendedor,i.pcia_id
		from inserted i 
    end

end
go

create trigger validar_clie_pcia_u on Cliente
instead of update
as
begin
    if exists(
        select 1
        from inserted i
        where i.pcia_id is not null and not exists (
            select 1
            from provincia p
            where p.id = i.pcia_id
        )
    )

    begin 
        rollback transaction 
    end

    else
    begin
        update Cliente
        set clie_codigo = i.clie_codigo , 
			clie_razon_social = i.clie_razon_social , 
			clie_telefono = i.clie_telefono , 
			clie_domicilio = i.clie_domicilio , 
			clie_limite_credito = i.clie_limite_credito , 
			clie_vendedor = i.clie_vendedor,
            pcia_id = i.pcia_id

		from inserted i 
        where Cliente.clie_codigo = i.clie_codigo
    end
end
go