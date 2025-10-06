CREATE procedure [dbo].[xsp_monitoring_gps_insert]
(
	@p_id					bigint output
	,@p_fa_code				nvarchar(50)
	,@p_vendor_code			nvarchar(50)
	,@p_vendor_name			nvarchar(250)	= ''
	,@p_total_paid			decimal(18,2)	= 0
	,@p_status				nvarchar(50)	= 'HOLD'
	,@p_unsubscribe_date	datetime
	,@p_grn_date			datetime

	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
    
		insert into dbo.monitoring_gps
		(
		    fa_code,
		    first_payment_date,
		    grn_date,
		    vendor_code,
		    vendor_name,
		    total_paid,
		    status,
		    unsubscribe_date,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(   @p_fa_code	
			,@p_cre_date
			,@p_grn_date
		    ,@p_vendor_code		
		    ,@p_vendor_name		
		    ,@p_total_paid		
		    ,@p_status			
		    ,@p_unsubscribe_date
		    --
		    ,@p_cre_date		
		    ,@p_cre_by			
		    ,@p_cre_ip_address	
		    ,@p_mod_date		
		    ,@p_mod_by			
		    ,@p_mod_ip_address	
		    
		    )

		set @p_id = @@identity ;

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
end ;
