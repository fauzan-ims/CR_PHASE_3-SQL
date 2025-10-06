CREATE PROCEDURE [dbo].[xsp_rpt_invoice_penagihan_group_insert]
(
	@p_user_id							nvarchar(50)
	,@p_invoice_no						nvarchar(50)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
BEGIN
	declare @msg			nvarchar(max)

	begin try

		insert into dbo.rpt_invoice_penagihan_group
		(
			user_id
			,invoice_no
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		VALUES
		(   
			@p_user_id
		    ,@p_invoice_no
			--
		    ,@p_cre_date		
			,@p_cre_by			
			,@p_cre_ip_address	
			,@p_mod_date		
			,@p_mod_by			
			,@p_mod_ip_address	
		) ;

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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end  


