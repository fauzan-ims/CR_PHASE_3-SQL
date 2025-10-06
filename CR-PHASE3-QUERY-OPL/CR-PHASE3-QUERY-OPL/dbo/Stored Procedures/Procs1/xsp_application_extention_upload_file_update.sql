
--created by, Rian at 22/05/2023 

CREATE PROCEDURE [dbo].[xsp_application_extention_upload_file_update]
(
	@p_id			   bigint
	,@p_file_name	   nvarchar(250)
	,@p_file_paths	   nvarchar(250)
	,@p_is_standart	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @main_contract_no  nvarchar(50)	= N''
			,@memo_file_name nvarchar(250)  = null
			,@memo_file_path nvarchar(250)  = null ;

	select	@main_contract_no = main_contract_no
	from	dbo.application_extention
	where	id = @p_id ;

	if (@p_is_standart = '1')
	begin
		set @memo_file_name = null ;
		set @memo_file_path = null ;
	end ;
	else
	begin
		select	@memo_file_name = memo_file_name
				,@memo_file_path = memo_file_path
		from	dbo.application_extention
		where	id = @p_id ;
	end ;

	update	dbo.application_extention
	set		main_contract_file_name		= upper(@p_file_name)
			,main_contract_file_path	= upper(@p_file_paths)
			,is_valid					= '0'
			,is_standart				= @p_is_standart
			,memo_file_name				= @memo_file_name
			,memo_file_path				= @memo_file_path
			--
			,mod_date					= @p_mod_date
			,mod_by						= @p_mod_by
			,mod_ip_address				= @p_mod_ip_address
	where	id							= @p_id ;

	update	dbo.main_contract_main
	set		main_contract_file_name		= upper(@p_file_name)
			,main_contract_file_path	= upper(@p_file_paths)
			,is_standart				= @p_is_standart 
			--
			,mod_date					= @p_mod_date
			,mod_by						= @p_mod_by
			,mod_ip_address				= @p_mod_ip_address
	where	main_contract_no			= @main_contract_no ;
end ;
