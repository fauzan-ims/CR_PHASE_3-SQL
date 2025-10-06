create PROCEDURE [dbo].[xsp_rpt_ext_vendor_insert]
(
	 @p_id						bigint
	,@p_entry_date				datetime
	,@p_entry_time				nvarchar(6)
	,@p_system_id				nvarchar(50)
	,@p_bukrs					nvarchar(4)
	,@p_ktokd					nvarchar(4)
	,@p_fe_vendor_code			nvarchar(50)
	,@p_doc_number				nvarchar(50)
	,@p_title					nvarchar(50)
	,@p_name1					nvarchar(250)
	,@p_name2					nvarchar(250)
	,@p_name3					nvarchar(250)
	,@p_name4					nvarchar(250)
	,@p_pstlz					nvarchar(50)
	,@p_stras					nvarchar(250)
	,@p_sort1					nvarchar(50)
	,@p_tel_number				nvarchar(50)
	,@p_stceg					nvarchar(50)
	,@p_akont					nvarchar(50)
	,@p_waers					nvarchar(50)
	,@p_zindicator				nvarchar(1)
	,@p_sap_extract_date		datetime
	,@p_sap_extract_time		nvarchar(6)
	,@p_sap_post_message		nvarchar(4000)
	,@p_ktp_id					nvarchar(50)
	--	
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		insert into dbo.rpt_ext_vendor
		(
			entry_date
			,entry_time
			,system_id
			,bukrs
			,ktokd
			,fe_vendor_code
			,doc_number
			,title
			,name1
			,name2
			,name3
			,name4
			,pstlz
			,stras
			,sort1
			,tel_number
			,stceg
			,akont
			,waers
			,zindicator
			,sap_extract_date
			,sap_extract_time
			,sap_post_message
			,ktp_id
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_entry_date				
			,@p_entry_time				
			,@p_system_id				
			,@p_bukrs					
			,@p_ktokd					
			,@p_fe_vendor_code			
			,@p_doc_number				
			,@p_title					
			,@p_name1					
			,@p_name2					
			,@p_name3					
			,@p_name4					
			,@p_pstlz					
			,@p_stras					
			,@p_sort1					
			,@p_tel_number				
			,@p_stceg					
			,@p_akont					
			,@p_waers					
			,@p_zindicator				
			,@p_sap_extract_date		
			,@p_sap_extract_time		
			,@p_sap_post_message		
			,@p_ktp_id					
			--
			,@p_cre_date				
			,@p_cre_by					
			,@p_cre_ip_address			
			,@p_mod_date				
			,@p_mod_by					
			,@p_mod_ip_address
		)
		set @p_id = @@identity
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
