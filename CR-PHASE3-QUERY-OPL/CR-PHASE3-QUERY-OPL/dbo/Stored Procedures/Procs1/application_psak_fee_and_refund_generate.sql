CREATE PROCEDURE dbo.application_psak_fee_and_refund_generate
(
	@p_application_no  nvarchar(50)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)

	begin try
	
		set nocount on ;

		-- process generate amortisasi fee yang di PSAK 
		begin
			declare @fee_code	 nvarchar(50)
					,@fee_amount decimal(18, 2) ;

			declare curr_fee_psak cursor fast_forward read_only for
			select	af.fee_code
					,af.fee_amount
			from	dbo.application_fee af
					inner join dbo.master_fee mf on af.fee_code = mf.code
			where	af.application_no		 = @p_application_no
					and mf.is_calculate_psak = 1 ;

			open curr_fee_psak ;

			fetch next from curr_fee_psak
			into @fee_code
				 ,@fee_amount ;

			while @@fetch_status = 0
			begin
				if (@fee_code = 'LINS') -- untuk life insance menggunakan angka diskon untuk di refund
				begin
					select	@fee_amount = sum(aco.initial_discount_amount)
					from	dbo.application_insurance aco
					where	aco.application_no = @p_application_no ;
				end ;

				exec dbo.xsp_application_fee_amortization_generate @p_application_no	= @p_application_no
																   ,@p_fee_code			= @fee_code
																   ,@p_fee_amount		= @fee_amount
																   ,@p_cre_date			= @p_cre_date
																   ,@p_cre_by			= @p_cre_by
																   ,@p_cre_ip_address	= @p_cre_ip_address

				fetch next from curr_fee_psak
				into @fee_code
					 ,@fee_amount ;
			end ;

			close curr_fee_psak ;
			deallocate curr_fee_psak ;
		end ;

		-- process generate amortisasi refund yang di psak 
		begin
			declare @refund_code	nvarchar(50)
					,@refund_amount decimal(18, 2) ;

			declare curr_refund_psakk cursor fast_forward read_only for
			select		refund_code
						,sum(rd.distribution_amount)
			from		dbo.application_refund arr
						inner join dbo.application_refund_distribution rd on rd.application_refund_code = arr.code
						inner join dbo.master_refund mr on mr.code										= arr.refund_code
			where		application_no = @p_application_no
						and mr.is_psak = '1'
			group by	refund_code ;

			open curr_refund_psakk ;

			fetch next from curr_refund_psakk
			into @refund_code
				 ,@refund_amount ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_application_refund_amortization_generate @p_application_no = @p_application_no
																	  ,@p_refund_code = @refund_code
																	  ,@p_refund_amount = @refund_amount
																	  ,@p_cre_date = @p_cre_date
																	  ,@p_cre_by = @p_cre_by
																	  ,@p_cre_ip_address = @p_cre_ip_address ;

				fetch next from curr_refund_psakk
				into @refund_code
					 ,@refund_amount ;
			end ;

			close curr_refund_psakk ;
			deallocate curr_refund_psakk ;
		end ;

		set nocount off ;
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


