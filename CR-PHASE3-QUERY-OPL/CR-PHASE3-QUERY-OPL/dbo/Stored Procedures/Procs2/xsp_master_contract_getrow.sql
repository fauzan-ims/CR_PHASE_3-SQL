CREATE PROCEDURE [dbo].[xsp_master_contract_getrow]
(
	@p_main_contract_no nvarchar(50)
)
as
begin
	select	main_contract_no
			,client_code
			,client_name
			,date
			,contract_standart
			,remark
			,file_name
			,file_path
			,memo_file_name
			,memo_file_path
			,status
	from	dbo.master_contract
	where	main_contract_no = @p_main_contract_no ;
end ;
