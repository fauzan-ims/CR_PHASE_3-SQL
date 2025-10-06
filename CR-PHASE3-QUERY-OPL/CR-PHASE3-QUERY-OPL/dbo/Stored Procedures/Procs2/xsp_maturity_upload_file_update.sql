--created by, Rian at 01/03/2023 

CREATE procedure dbo.xsp_maturity_upload_file_update
(
	@p_code			nvarchar(50)
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	dbo.maturity
	set		file_name		= upper(@p_file_name)
			,file_paths		= upper(@p_file_paths)
	where	code				= @p_code;
end ;

