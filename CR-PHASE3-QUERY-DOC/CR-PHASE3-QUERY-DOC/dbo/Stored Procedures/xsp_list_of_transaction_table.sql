
CREATE PROCEDURE dbo.xsp_list_of_transaction_table
(
	@type nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@type = 'list')
		begin
			select		(schema_name(a.schema_id) + '.' + a.name) as tablename
						,sum(b.rows) as recordcount
			from		sys.objects a
						inner join sys.partitions b on a.object_id = b.object_id
			where		a.type = 'u'
						and a.name not like '%SYS_%'
						and a.name not like '%MASTER_%'
						and a.name not like 'JOURNAL_GL_LINK'
			group by	a.schema_id
						,a.name
			order by	tablename desc ;

			select		A.TABLE_CATALOG as CATALOG
						,A.TABLE_SCHEMA as "SCHEMA"
						,A.TABLE_NAME as "TABLE"
						,B.COLUMN_NAME as "COLUMN"
						,ident_seed(A.TABLE_NAME) as Seed
						,ident_incr(A.TABLE_NAME) as Increment
						,ident_current(A.TABLE_NAME) as Curr_Value
			from		INFORMATION_SCHEMA.TABLES A
						,INFORMATION_SCHEMA.COLUMNS B
			where		A.TABLE_CATALOG															 = B.TABLE_CATALOG
						and A.TABLE_SCHEMA														 = B.TABLE_SCHEMA
						and A.TABLE_NAME														 = B.TABLE_NAME
						and columnproperty(object_id(B.TABLE_NAME), B.COLUMN_NAME, 'IsIdentity') = 1
						and objectproperty(object_id(A.TABLE_NAME), 'TableHasIdentity')			 = 1
						and A.TABLE_TYPE														 = 'BASE TABLE'
						and A.TABLE_NAME not like '%SYS_%'
						and A.TABLE_NAME not like '%MASTER_%'
						and A.TABLE_NAME not like 'JOURNAL_GL_LINK'
			order by	A.TABLE_SCHEMA
						,A.TABLE_NAME ;
		end ;
		else
		begin
			select		'delete ' + (schema_name(a.schema_id) + '.' + a.name) as tablename
			from		sys.objects a
						inner join sys.partitions b on a.object_id = b.object_id
			where		a.type = 'u'
						and a.name not like '%SYS_%'
						and a.name not like '%MASTER_%'
						and a.name not like 'JOURNAL_GL_LINK'
			group by	a.schema_id
						,a.name
			order by	tablename desc ;

			select		'dbcc checkident(''' + A.TABLE_NAME + ''', reseed, 0)'
			from		INFORMATION_SCHEMA.TABLES A
						,INFORMATION_SCHEMA.COLUMNS B
			where		A.TABLE_CATALOG															 = B.TABLE_CATALOG
						and A.TABLE_SCHEMA														 = B.TABLE_SCHEMA
						and A.TABLE_NAME														 = B.TABLE_NAME
						and columnproperty(object_id(B.TABLE_NAME), B.COLUMN_NAME, 'IsIdentity') = 1
						and objectproperty(object_id(A.TABLE_NAME), 'TableHasIdentity')			 = 1
						and A.TABLE_TYPE														 = 'BASE TABLE'
						and A.TABLE_NAME not like '%SYS_%'
						and A.TABLE_NAME not like '%MASTER_%'
						and A.TABLE_NAME not like 'JOURNAL_GL_LINK'
			order by	A.TABLE_SCHEMA
						,A.TABLE_NAME ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
