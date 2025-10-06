CREATE PROCEDURE dbo.xsp_sale_detail_fee_insert
(
	@p_id			   bigint = 0 output
	,@p_sale_detail_id bigint
	,@p_fee_code	   nvarchar(50)
	,@p_fee_name	   nvarchar(250)
	,@p_fee_amount	   decimal(18, 2)	= 0
	,@p_pph_amount	   decimal(18, 2)	= 0
	,@p_ppn_amount	   decimal(18, 2)	= 0
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into sale_detail_fee
		(
			sale_detail_id
			,fee_code
			,fee_name
			,fee_amount
			,pph_amount
			,ppn_amount
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
			@p_sale_detail_id
			,@p_fee_code
			,@p_fee_name
			,@p_fee_amount
			,@p_pph_amount
			,@p_ppn_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
