CREATE procedure [dbo].[xsp_masking_getrow]
(
	@p_id		int
	,@p_user_id nvarchar(50)
)
as
begin
	declare @privilege nvarchar(3) ;

	if (@p_user_id <> 'ADMIN')
	begin
		create user MaskingTestUser without login ;

		grant select
		on schema::dbo
		to	MaskingTestUser ;

		execute as user = 'MaskingTestUser' ;

		set @privilege = N'YES' ;
	end ;

	select	id
			,name
			,nik
			,religion
			,phone_no
			,email
			,birthday_date
			,@privilege 'previlege'
	from	dbo.masking
	where	id = @p_id ;

	if (@p_user_id <> 'ADMIN')
	begin
		revert ;

		drop user MaskingTestUser ;
	end ;
end ;
