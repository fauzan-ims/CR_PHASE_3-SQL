CREATE procedure [dbo].[xsp_test_masking]
(
	@p_user_id nvarchar(50)
)
as
begin
	if (@p_user_id <> 'ADMIN')
	begin
		create user MaskingTestUser without login ;

		--grant select
		--on schema::dbo
		--to	MaskingTestUser ;

		GRANT SELECT ON SCHEMA::CustomerData TO MaskingTestUser;

		execute as user = 'MaskingTestUser' ;
	end ;

	insert into dbo.rpt_CustomerData
	(
		FullName
		,Email
		,CreditCard
		,BirthDate
	)
	select	FullName
			,Email
			,CreditCard
			,BirthDate
	from	CustomerData ;

	if (@p_user_id <> 'ADMIN')
	begin
		revert ;

		drop user MaskingTestUser ;
	end ;

	SELECT * FROM dbo.rpt_CustomerData
end ;
