CREATE PROCEDURE [dbo].[xsp_maintenence_check_identity_table_interface]
AS
   begin
   
	   SELECT 
		IDENT_SEED(TABLE_NAME) AS Seed,
		IDENT_INCR(TABLE_NAME) AS Increment,
		IDENT_CURRENT(TABLE_NAME) AS Current_Identity,
		--object_id(TABLE_NAME),
		TABLE_NAME,
		'DBCC CHECKIDENT(' + TABLE_NAME + ', RESEED, ' + CAST(IDENT_SEED(TABLE_NAME) AS VARCHAR(10)) + ')' 
	FROM 
		INFORMATION_SCHEMA.TABLES	
	WHERE 
		OBJECTPROPERTY(OBJECT_ID(TABLE_NAME), 'TableHasIdentity') = 1
		AND TABLE_TYPE = 'BASE TABLE'
		AND TABLE_NAME like '%interface%'
	order by Current_Identity desc

   end 
