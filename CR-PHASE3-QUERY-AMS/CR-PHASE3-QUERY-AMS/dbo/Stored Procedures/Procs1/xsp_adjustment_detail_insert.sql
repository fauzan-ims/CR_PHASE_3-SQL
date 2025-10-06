CREATE PROCEDURE dbo.xsp_adjustment_detail_insert
(
	@p_id							bigint output
	,@p_adjustment_code				nvarchar(50)
	,@p_adjusment_transaction_code  nvarchar(50)
	,@p_adjustment_description		nvarchar(250)	= ''
	,@p_amount					    decimal(18,2)	= 0
	,@p_uom							nvarchar(15) = 'Unit'
	,@p_quantity					INT = 1
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
    
		insert into dbo.adjustment_detail
		        ( 
				  adjustment_code 
		          ,adjusment_transaction_code
				  ,adjustment_description
		          ,amount
				  ,uom
				  ,quantity
		          ,cre_date 
		          ,cre_by 
		          ,cre_ip_address 
		          ,mod_date 
		          ,mod_by 
		          ,mod_ip_address
		        )
		values  ( 
				  @p_adjustment_code
		          ,@p_adjusment_transaction_code
				  ,@p_adjustment_description
		          ,@p_amount
				  ,@p_uom
				  ,@p_quantity
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
