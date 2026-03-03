use GD2015C1
go

/* Suponiendo que se aplican los siguientes cambios en el modelo de
datos:

Cambio 1) create table provincia (id 'int primary key, nómbre char(100)) ;
Cambio 2) alter table cliente add pcia_id int null:

Crear el/los objetos necesarios para implementar el concepto de foreign
key entre 2 cliente y provincia,

Nota: No se permite agregar una constraint de tipo FOREIGN KEY entre la
tabla y el campo agregado. */

create trigger git6 on Cliente after insert, update
as
begin
	
	if exists (
		select 1
		from Inserted i
		where (i.pcia_id is not null) and (not exists (
			select pcia_id
			from Provincia p
			where p.id = i.pcia_id)
	))

	begin
		print 'La provincia no existe'
		rollback tran
	end

end
go

create trigger git66 on Provincia after delete, update
as
begin
	
	-- Solo rechazo el update si modifica el ID, si no no.
	if exists(
		select 1
		from deleted d
		where d.id = (select c.pcia_id from Cliente c where c.pcia_id = d.id) and
		not exists (select 1 from inserted i where i.id = d.id)
	)

	begin
		print 'la pcia esta siendo utilizada por al menos 1 cliente => no se puede modificar u eliminar'
		rollback tran
	end

end
go
