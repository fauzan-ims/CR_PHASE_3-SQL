create procedure [dbo].[xsp_document_tbo_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	dt.main_contract_no
			,mc.date
			,dt.status
			,mc.client_name
	from	dbo.document_tbo			   dt
			inner join dbo.master_contract mc on mc.main_contract_no = dt.main_contract_no
	where	code = @p_code ;
end ;
