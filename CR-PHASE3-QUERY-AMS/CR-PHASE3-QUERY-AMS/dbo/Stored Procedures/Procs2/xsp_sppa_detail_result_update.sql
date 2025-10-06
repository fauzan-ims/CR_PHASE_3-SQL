/*
	alterd : Nia, 26 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_sppa_detail_result_update
(
	@p_id						  bigint
	,@p_sppa_code				  nvarchar(50)
	,@p_result_status			  nvarchar(20)
	,@p_result_date				  datetime
	,@p_result_total_buy_amount   decimal(18, 2)
	,@p_result_policy_no		  nvarchar(50)
	,@p_result_reason			  nvarchar(4000)
	--
	,@p_cre_date		          datetime
	,@p_cre_by			          nvarchar(15)
	,@p_cre_ip_address	          nvarchar(15)
	,@p_mod_date		          datetime
	,@p_mod_by			          nvarchar(15)
	,@p_mod_ip_address	          nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@sppa_date					  DATETIME;

	begin try			
		
		IF (@p_result_date < @sppa_date)
		BEGIN
			set @msg = 'Result Date must be greater than SPPA Date' ;

			raiserror(@msg, 16, -1) ;
		END

		IF (@p_result_date > dbo.xfn_get_system_date() )
		BEGIN
			set @msg = 'Result Date must be less than SPPA Date' ;

			raiserror(@msg, 16, -1) ;
		END

				UPDATE dbo.sppa_detail
				SET	   sppa_code				 = @p_sppa_code
					   ,result_status            = upper(@p_result_status)
					   ,result_date              = @p_result_date
					   ,result_total_buy_amount  = @p_result_total_buy_amount
					   ,result_policy_no		 = upper(@p_result_policy_no)
					   ,result_reason            = @p_result_reason
					   -----
					   ,mod_date		         = @p_mod_date		
					   ,mod_by			         = @p_mod_by			
					   ,mod_ip_address	         = @p_mod_ip_address
				
				WHERE  id	= @p_id
			
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

