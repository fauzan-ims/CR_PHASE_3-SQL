CREATE PROCEDURE [dbo].[xsp_tbo_document_getrow]
(
	@p_id nvarchar(50)
)
as
begin
	select	td.id
			--,td.application_no
			,am.application_external_no 'application_no'
			,cm.client_name
			,td.agreement_external_no
			,td.branch_name
			,am.branch_code
			,am.branch_name
			,td.transaction_name
			,td.transaction_no
			,td.transaction_date
			,td.cre_date 'date'
			,rz.file_memo
			,rz.file_path_memo
			,rz.remark 'realization_remark'
			,td.remarks 'remark'
			,rz.exp_date
			,td.status 
			,ae.main_contract_status
			,ae.main_contract_date
			,ae.remarks'main_contract_remarks'
			,ae.is_standart
			,ae.main_contract_file_name
			,ae.main_contract_file_path
	from	dbo.tbo_document td
			inner join dbo.application_main am on (am.application_no = td.application_no)
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
			outer apply 
			(
				select  file_memo
						,file_path_memo
						,exp_date
						,remark
				from dbo.realization where code = td.transaction_no
			)rz
			outer apply
			(
				select	main_contract_status
						,main_contract_date
						,remarks
						,main_contract_file_name
						,main_contract_file_path
						,is_standart
				from	dbo.application_extention
				where	application_no = td.application_no
			)ae
	where	td.id = @p_id ;
end ;
