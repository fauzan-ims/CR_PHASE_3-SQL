
--created by, Rian at 22.05.2023 

CREATE PROCEDURE dbo.xsp_application_extention_getrow
(
	@p_application_no nvarchar(50)
)
as
begin
	declare @is_exists nvarchar(1) = '0' ;

	if exists
	(
		select	1
		from	dbo.realization
		where	application_no = @p_application_no
				and status	   = 'post'
	)
	begin
		set @is_exists = N'1' ;
	end ;

	select	id
			,application_no
			,main_contract_status
			,isnull(main_contract_no, '') main_contract_no
			,main_contract_file_name
			,main_contract_file_path
			,client_no
			,remarks
			,main_contract_date
			,isnull(is_valid, '0') is_valid
			,isnull(memo_file_name, '') memo_file_name
			,isnull(memo_file_path, '') memo_file_path
			,isnull(is_standart, '0') is_standart
			--,case
			--	 when isnull(@agreement_no, '') = '' then '0'
			--	 else '1'
			-- end 'agreement_exists'
			,@is_exists 'agreement_exists'
	from	dbo.application_extention
	where	application_no = @p_application_no ;
end ;
