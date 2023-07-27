USE [Paypre_common_Framework]
GO
/****** Object:  StoredProcedure [dbo].[Changepassword]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Changepassword](@UserId INT,
								@Newpassword NVARCHAR(500))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
		Update [User] SET Password=@Newpassword WHERE UserId=@UserId
		IF @@ROWCOUNT > 0
			BEGIN
				SELECT 'Data Updated Successfully', 1
				IF @@TRANCOUNT > 0
					BEGIN
						COMMIT
					END
			END
		ELSE
			BEGIN
				SELECT 'Data Not Updated', 0
				IF @@TRANCOUNT > 0
					BEGIN
						ROLLBACK
					END
			END

IF @@TRANCOUNT > 0
	COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[deleteAppAccess]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteAppAccess](@UserId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE AppAccess SET ActiveStatus='D' WHERE UserId=@UserId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteAppImage]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteAppImage](@ImageId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE AppImage SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  ImageId = @ImageId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteApplication]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteApplication](@AppId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Application SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  AppId = @AppId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteAppMenu]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteAppMenu](@MenuId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE AppMenu SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  MenuId = @MenuId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteBranch]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteBranch](@BrId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Branch SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  BrId = @BrId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteBranchAppAccess]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteBranchAppAccess](@UserId INT,@BranchId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE AppAccess SET ActiveStatus='D' WHERE UserId=@UserId AND BranchId=@BranchId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteCarousel]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteCarousel](@CarouselId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Carousel SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  CarouselId = @CarouselId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteCompany]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteCompany](@CompId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Company SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  CompId = @CompId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteCompAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteCompAppMap](@UniqueId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE CompAppMap SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  UniqueId = @UniqueId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteConfigMaster]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteConfigMaster](@ConfigId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE ConfigMaster SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  ConfigId = @ConfigId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteConfigType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteConfigType](@TypeId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE ConfigType SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  TypeId = @TypeId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteCurrency]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteCurrency](@CurrId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Currency SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  CurrId = @CurrId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteFeature]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteFeature](@FeatId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE Feature SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  FeatId = @FeatId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deletePaymentUPIDetails]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deletePaymentUPIDetails]
(
  @PaymentUPIDetailsId INT,
  @ActiveStatus CHAR(1),
  @UpdatedBy INT,
  @CompId INT=NULL ,
  @BranchId INT=NULL
)

AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE PaymentUPIDetails SET ActiveStatus = @ActiveStatus, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId = @PaymentUPIDetailsId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END






--AS
--BEGIN
--  SET NOCOUNT ON;
--  BEGIN TRAN

--  -- Deactivate all records if @CompId and @BranchId are both NULL
--  IF (@CompId IS NULL AND @BranchId IS NULL)
--	  BEGIN
--		 UPDATE PaymentUPIDetails SET ActiveStatus = @ActiveStatus, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId = @PaymentUPIDetailsId AND @CompId IS NULL AND @BranchId IS NULL AND type='I';
--		 IF @@TRANCOUNT > 0
--			BEGIN
--				UPDATE PaymentUPIDetails SET ActiveStatus = 'D',UpdatedBy = @UpdatedBy,UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId <> @PaymentUPIDetailsId AND @CompId IS NULL AND @BranchId IS NULL AND type='I';
--				IF @@ROWCOUNT > 0
--					  BEGIN
--						SELECT 'Data Updated Successfully', 1
--						IF @@TRANCOUNT > 0
--						  COMMIT
--					  END
--				ELSE
--					  BEGIN
--						UPDATE PaymentUPIDetails SET ActiveStatus = @ActiveStatus, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId = @PaymentUPIDetailsId AND @CompId IS NULL AND @BranchId IS NULL AND type='I';
--						IF @@ROWCOUNT > 0
--							  BEGIN
--								SELECT 'Data Updated Successfully', 1
--								IF @@TRANCOUNT > 0
--								  COMMIT
--							  END
--						ELSE
--							  BEGIN
--								SELECT 'Data Not Updated', 0
--								IF @@TRANCOUNT > 0
--									ROLLBACK
--							  END
--					  END
--			 END
--		 ELSE
--			  BEGIN
--				SELECT 'Data Not Updated', 0
--				IF @@TRANCOUNT > 0
--					ROLLBACK
--			  END
		  
--		 END
 
-- ELSE IF(@CompId IS NOT NULL AND @BranchId IS NOT NULL)
--	BEGIN
--		 UPDATE PaymentUPIDetails SET ActiveStatus = @ActiveStatus, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId = @PaymentUPIDetailsId AND CompId=@CompId AND BranchId=@BranchId AND type='O' ;
--		 IF @@TRANCOUNT > 0
--			BEGIN
--				UPDATE PaymentUPIDetails SET ActiveStatus = 'D',UpdatedBy = @UpdatedBy,UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId <> @PaymentUPIDetailsId AND CompId=@CompId AND BranchId=@BranchId AND type='O';
--				IF @@ROWCOUNT > 0
--					  BEGIN
--						SELECT 'Data Updated Successfully', 1
--						IF @@TRANCOUNT > 0
--						  COMMIT
--					  END
--				ELSE
--					 BEGIN
--						 UPDATE PaymentUPIDetails SET ActiveStatus = @ActiveStatus, UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE() WHERE PaymentUPIDetailsId = @PaymentUPIDetailsId AND CompId=@CompId AND BranchId=@BranchId AND type='O' ;
--						IF @@ROWCOUNT > 0
--								BEGIN
--									SELECT 'Data Updated Successfully', 1
--									IF @@TRANCOUNT > 0
--										COMMIT
--								END
--						ELSE
--								BEGIN
--									SELECT 'Data Not Updated', 0
--									IF @@TRANCOUNT > 0
--										ROLLBACK
--								END
--					   END
--			 END
--		 ELSE
--			  BEGIN
--				SELECT 'Data Not Updated', 0
--				IF @@TRANCOUNT > 0
--					ROLLBACK
--			  END
		  
--		 END

--  IF @@TRANCOUNT > 0
--    COMMIT
--END
GO
/****** Object:  StoredProcedure [dbo].[deletePricingAppFeatMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deletePricingAppFeatMap](@AppId INT,@PricingId INT,@ActiveStatus CHAR(1) , @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE PricingAppFeatMap SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE PricingId=@PricingId and AppId=@AppId
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deletePricingType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deletePricingType](@PricingId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE PricingType SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  PricingId = @PricingId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteUser]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[deleteUser](@UserId INT,@ActiveStatus CHAR(1), @UpdatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE [User] SET ActiveStatus = @ActiveStatus, UpdatedBy= @UpdatedBy, UpdatedDate=GETDATE() WHERE  UserId = @UserId	
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Deleted Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Deleted', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[forgotPassword]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[forgotPassword](@password NVARCHAR(50),
								@userName  NVARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF EXISTS(SELECT MailId,MobileNo FROM [User] WHERE (MailId=@userName OR MobileNo=@userName))
		BEGIN
			IF len(@userName)>10						
					BEGIN
						UPDATE [User] SET Password=@password WHERE MailId=@userName
						IF @@ROWCOUNT > 0
							BEGIN
								SELECT 'Data Updated Successfully', 1
								IF @@TRANCOUNT > 0
									BEGIN
										COMMIT
									END
							END
						ELSE
							BEGIN
								SELECT 'Data Not Updated', 0
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
					END
			ELSE
				BEGIN
					UPDATE [User] SET Password=@password WHERE MobileNo=@userName
					IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
						END
					ELSE
						BEGIN
							SELECT 'Data Not Updated', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END

END


GO
/****** Object:  StoredProcedure [dbo].[getAdminTax]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getAdminTax] (@TaxId INT=NULL, @ActiveStatus CHAR(1)=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- TaxId
				WHEN @TaxId IS NOT NULL AND @ActiveStatus IS NULL
					THEN (SELECT * 
							FROM adminTaxView
							WHERE TaxId=@TaxId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @TaxId IS NULL AND @ActiveStatus IS NOT NULL  
					THEN (SELECT * 
							FROM adminTaxView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--All Null
			    WHEN @TaxId IS NULL AND @ActiveStatus IS NULL  
					THEN (SELECT * 
							FROM adminTaxView  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getAppAccess]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getAppAccess] (@UserId INT=NULL,@AppId INT=NULL,@CompId INT=NULL,@Type CHAR(2)=NULL,@ActiveStatus CHAR(1)=NULL)
AS
BEGIN
SELECT CAST((CASE 

			--UserId & Type AD(App DropDown)
				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type='AD' AND @ActiveStatus IS NULL
					THEN (SELECT aa.AppId,(SELECT av.AppName
												FROM applicationView AS av
												WHERE av.AppId=aa.AppId) AS AppName
							FROM AppAccess AS aa
							WHERE aa.UserId=@UserId
							GROUP BY aa.AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--UserId & Type AD(App DropDown) & Activestatus
				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type='AD' AND @ActiveStatus IS NOT NULL
					THEN (SELECT aa.AppId,(SELECT av.AppName
												FROM applicationView AS av
												WHERE av.AppId=aa.AppId) AS AppName
							FROM AppAccess AS aa
							WHERE aa.UserId=@UserId AND aa.ActiveStatus=@ActiveStatus
							GROUP BY aa.AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--AppId & UserId & Type=DB(Default Branch)
				WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type='DB'
					THEN(SELECT a.* FROM AppAccess as a
							WHERE a.AppId=@AppId 
							AND a.UserId=@UserId 
							AND a.DefaultBranch='Y'
							AND a.ActiveStatus='A'
							FOR JSON PATH, INCLUDE_NULL_VALUES)

		--UserId & Type UserCheckLogin(UC)
				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type='UC'
					THEN (SELECT aa.AppId,aa.CompId,aa.BranchId,(SELECT av.AppName
												FROM applicationView AS av
												WHERE av.AppId=aa.AppId) AS AppName
							FROM AppAccess AS aa
							WHERE aa.UserId=@UserId and aa.ActiveStatus='A'
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			-- UserId
				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type IS NULL
					THEN (
					--SELECT e.* ,a.SubCateId as ConfigId,a.SubCategoryName as ConfigName, a.AppLogo,a.AppName,
					--	ISNULL((SELECT ai.ImageLink FROM AppImage  as ai WHERE ai.AppId=e.AppId FOR JSON PATH),'[]')as ImageLink,
					--	(SELECT cy.CompName FROM Company AS cy WHERE cy.CompId=e.CompId) AS CompName
					--		FROM AppAccess as e 
					--		inner join applicationView as a on a.AppId=e.AppId
					--		inner join ConfigMaster as cm on cm.ConfigId=a.SubCateId
					--		WHERE e.UserId=@UserId  
					SELECT * FROM(
							SELECT DISTINCT e.* ,a.SubCateId as ConfigId,a.SubCategoryName as ConfigName, a.AppLogo,a.AppName,
							ISNULL((SELECT ai.ImageLink FROM AppImage AS ai WHERE ai.AppId = e.AppId FOR JSON PATH), '[]') AS ImageLink,
							(SELECT cy.CompName FROM Company AS cy WHERE cy.CompId = e.CompId) AS CompName,
							ROW_NUMBER() OVER (PARTITION BY UserId,e.AppId ORDER By e.AppAccessId DESC) AS 'Row' 
							FROM AppAccess AS e
							INNER JOIN applicationView AS a ON a.AppId = e.AppId
							INNER JOIN ConfigMaster AS cm ON cm.ConfigId = a.SubCateId
							WHERE e.UserId = @UserId) AS A
							WHERE Row=1
							FOR JSON PATH, INCLUDE_NULL_VALUES)


							

			--AppId
			    WHEN @UserId IS NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL
					THEN (select aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((select * from Branch as b where aa.CompId=b.CompId for json path),'[]') as BranchDeatils 
								from AppAccess as aa 
								inner join Company as c on c.CompId=aa.CompId AND c.ActiveStatus='A'
								inner join Application as app on app.AppId=aa.AppId
								where aa.AppId=@AppId group by aa.CompId,aa.AppId,c.CompName,app.AppName
							  FOR JSON PATH, INCLUDE_NULL_VALUES)


			--AppId & UserId
			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL
					THEN (SELECT aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((SELECT * 
																						FROM Branch AS b 
																						WHERE aa.CompId=b.CompId 
																					FOR JSON PATH),'[]') AS BranchDeatils 
								FROM AppAccess AS aa 
								INNER JOIN Company AS c 
								ON c.CompId=aa.CompId AND c.ActiveStatus='A'
								INNER JOIN Application AS app 
								ON app.AppId=aa.AppId
								WHERE aa.AppId=@AppId 
								AND aa.UserId=@UserId
								GROUP BY aa.CompId,aa.AppId,c.CompName,app.AppName
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--AppId & UserId & ActiveStatus
			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL AND @ActiveStatus IS NOT NULL
					THEN (SELECT aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((SELECT * 
																						FROM Branch AS b 
																						WHERE aa.CompId=b.CompId and aa.ActiveStatus = @ActiveStatus
																					FOR JSON PATH),'[]') AS BranchDeatils 
								FROM AppAccess AS aa 
								INNER JOIN Company AS c 
								ON c.CompId=aa.CompId AND c.ActiveStatus='A'
								INNER JOIN Application AS app 
								ON app.AppId=aa.AppId
								WHERE aa.AppId=@AppId 
								AND aa.UserId=@UserId and aa.ActiveStatus = @ActiveStatus
								GROUP BY aa.CompId,aa.AppId,c.CompName,app.AppName ,aa.ActiveStatus
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--compId & AppId
			    WHEN @UserId IS NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type IS NULL AND @ActiveStatus IS NULL
					THEN (select (aa.BranchId) AS BrId,aa.CompId,b.BrName,c.CompName,aa.AppId,app.AppName from AppAccess as aa
							inner join Company as c on c.CompId=aa.CompId
							inner join Branch as b on b.BrId=aa.BranchId
							inner join Application as app on app.AppId=aa.AppId
							where aa.CompId=@CompId and aa.AppId=@AppId 
							group by aa.BranchId,aa.CompId,b.BrName,c.CompName,aa.AppId,app.AppName
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

		--AppId,UserId,CompId
			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type IS NULL AND @ActiveStatus IS NOT NULL
					THEN (SELECT (aa.BranchId) AS BrId,aa.CompId,b.BrName,c.CompName,app.AppName,app.AppId
							FROM AppAccess AS aa
							INNER JOIN Company AS c 
							ON c.CompId=aa.CompId
							INNER JOIN Branch AS b 
							ON b.BrId=aa.BranchId
							INNER JOIN Application AS app 
							ON app.AppId=aa.AppId
							WHERE aa.CompId=@CompId 
							AND aa.AppId=@AppId 
							AND aa.UserId=@UserId AND aa.ActiveStatus=@ActiveStatus
						FOR JSON PATH, INCLUDE_NULL_VALUES)

		--AppId,UserId,CompId
			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type IS NULL AND @ActiveStatus IS NULL
					THEN (SELECT (aa.BranchId) AS BrId,aa.CompId,b.BrName,c.CompName,app.AppName,app.AppId
							FROM AppAccess AS aa
							INNER JOIN Company AS c 
							ON c.CompId=aa.CompId
							INNER JOIN Branch AS b 
							ON b.BrId=aa.BranchId
							INNER JOIN Application AS app 
							ON app.AppId=aa.AppId
							WHERE aa.CompId=@CompId 
							AND aa.AppId=@AppId 
							AND aa.UserId=@UserId
						FOR JSON PATH, INCLUDE_NULL_VALUES)
		--AppId,UserId,CompId,Type='T
				 WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type='T'
					THEN(SELECT TOP 1*
								FROM ( 
									SELECT uav.*,(a.CompId) as CompanyId,
										CASE
											WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
											THEN 'Y'
											ELSE 'N'
										END AS Status,
										ISNULL((SELECT COUNT(a.BranchId) FROM AppAccess AS a WHERE a.UserId = @UserId AND  a.AppId = @AppId and a.ActiveStatus='A'),0) AS BranchCount,
										ISNULL((SELECT f.FeatName, f.FeatConstraint
											FROM Feature AS f
											INNER JOIN PricingType as p ON p.PricingId=uav.PricingId AND p.AppId=uav.AppId
											INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = p.PricingId AND pm.AppId = p.AppId AND pm.ActiveStatus = 'A'
											WHERE f.FeatId = pm.FeatId 									
											FOR JSON PATH),'[]') AS 'FeatureDetails',
										ROW_NUMBER() OVER (PARTITION BY uav.UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
									FROM userAppMapView AS uav
									INNER JOIN AppAccess as a ON a.AppId=uav.AppId AND a.UserId=uav.UserId
									WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND a.CompId=@CompId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
								) AS A 
								WHERE Row = 1
								ORDER BY UniqueId DESC
					
					
					--SELECT TOP 1*
					--		FROM ( 
					--			SELECT uav.*,
					--				CASE
					--					WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
					--					THEN 'Y'
					--					ELSE 'N'
					--				END AS Status,
					--				(SELECT COUNT(a.BranchId) FROM AppAccess AS a WHERE a.UserId = @UserId AND a.AppId = @AppId AND a.CompId=@CompId) AS BranchCount,
					--				ROW_NUMBER() OVER (PARTITION BY uav.UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
					--			FROM userAppMapView AS uav
					--			INNER JOIN PricingType as p ON p.AppId=uav.AppId
					--			INNER JOIN AppAccess as a ON a.AppId=uav.AppId AND a.UserId=uav.UserId
					--			WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND a.CompId=@CompId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
					--		) AS A 
					--		WHERE Row = 1
					--		ORDER BY UniqueId DESC 
							
							FOR JSON PATH, INCLUDE_NULL_VALUES)
				 --WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type='T'
					--THEN(SELECT TOP 1*
					--		FROM ( 
					--			SELECT uav.*,
					--				CASE
					--					WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
					--					THEN 'Y'
					--					ELSE 'N'
					--				END AS Status,
					--				(SELECT COUNT(a.BranchId) FROM AppAccess AS a WHERE a.UserId = @UserId AND a.AppId = @AppId AND a.CompId=@CompId) AS BranchCount,
					--				ROW_NUMBER() OVER (PARTITION BY uav.UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
					--			FROM userAppMapView AS uav
					--			INNER JOIN PricingType as p ON p.AppId=uav.AppId
					--			INNER JOIN AppAccess as a ON a.AppId=uav.AppId AND a.UserId=uav.UserId
					--			WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND a.CompId=@CompId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
					--		) AS A 
					--		WHERE Row = 1
					--		ORDER BY UniqueId DESC FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @UserId IS NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type IS NULL
					THEN (SELECT * 
							FROM AppAccessView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



--USE [Paypre_common_Framework]
--GO
--/****** Object:  StoredProcedure [dbo].[getAppAccess]    Script Date: 7/25/2023 5:59:54 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


----EXEC getAppAccess @UserId=37,@Type='UC'

--ALTER PROCEDURE [dbo].[getAppAccess] (@UserId INT=NULL,@AppId INT=NULL,@CompId INT=NULL,@Type CHAR(2)=NULL,@ActiveStatus CHAR(2)=NULL)
--AS
--BEGIN
--SELECT CAST((CASE 



--			--UserId & Type AD(App DropDown)
--				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type='AD' AND @ActiveStatus IS NULL
--					THEN (SELECT aa.AppId,(SELECT av.AppName
--												FROM applicationView AS av
--												WHERE av.AppId=aa.AppId) AS AppName
--							FROM AppAccess AS aa
--							WHERE aa.UserId=@UserId and aa.ActiveStatus='A'
--							GROUP BY aa.AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
--			--UserId & Type UserCheckLogin(UC)
--				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type='UC'
--					THEN (SELECT aa.AppId,aa.CompId,aa.BranchId,(SELECT av.AppName
--												FROM applicationView AS av
--												WHERE av.AppId=aa.AppId) AS AppName
--							FROM AppAccess AS aa
--							WHERE aa.UserId=@UserId and aa.ActiveStatus='A'
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)

							 
			
--			-- UserId
--				WHEN @UserId IS NOT NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type IS NULL AND @ActiveStatus IS  NULL
--					THEN (
--						--SELECT e.* ,a.SubCateId as ConfigId,a.SubCategoryName as ConfigName, a.AppLogo,a.AppName,
--						--ISNULL((SELECT ai.ImageLink FROM AppImage  as ai WHERE ai.AppId=e.AppId FOR JSON PATH),'[]')as ImageLink,
--						--(SELECT cy.CompName FROM Company AS cy WHERE cy.CompId=e.CompId) AS CompName
--						--	FROM AppAccess as e 
--						--	inner join applicationView as a on a.AppId=e.AppId
--						--	inner join ConfigMaster as cm on cm.ConfigId=a.SubCateId
--						--	WHERE e.UserId=@UserId
--						SELECT * FROM(
--							SELECT DISTINCT e.* ,a.SubCateId as ConfigId,a.SubCategoryName as ConfigName, a.AppLogo,a.AppName,
--							ISNULL((SELECT ai.ImageLink FROM AppImage AS ai WHERE ai.AppId = e.AppId FOR JSON PATH), '[]') AS ImageLink,
--							(SELECT cy.CompName FROM Company AS cy WHERE cy.CompId = e.CompId) AS CompName,
--							ROW_NUMBER() OVER (PARTITION BY UserId,e.AppId ORDER By e.AppAccessId DESC) AS 'Row' 
--							FROM AppAccess AS e
--							INNER JOIN applicationView AS a ON a.AppId = e.AppId
--							INNER JOIN ConfigMaster AS cm ON cm.ConfigId = a.SubCateId
--							WHERE e.UserId = @UserId) AS A
--							WHERE Row=1
--							FOR JSON PATH, INCLUDE_NULL_VALUES)
							
--			--AppId
--			    WHEN @UserId IS NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL AND @ActiveStatus IS NULL
--					THEN (select aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((select * from Branch as b where aa.CompId=b.CompId for json path),'[]') as BranchDeatils 
--								from AppAccess as aa 
--								inner join Company as c on c.CompId=aa.CompId AND c.ActiveStatus='A'
--								inner join Application as app on app.AppId=aa.AppId
--								where aa.AppId=@AppId group by aa.CompId,aa.AppId,c.CompName,app.AppName
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)


--			--AppId & UserId
--			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL
--					THEN (SELECT aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((SELECT * 
--																						FROM Branch AS b 
--																						WHERE aa.CompId=b.CompId 
--																					FOR JSON PATH),'[]') AS BranchDeatils 
--								FROM AppAccess AS aa 
--								INNER JOIN Company AS c 
--								ON c.CompId=aa.CompId AND c.ActiveStatus='A'
--								INNER JOIN Application AS app 
--								ON app.AppId=aa.AppId
--								WHERE aa.AppId=@AppId 
--								AND aa.UserId=@UserId AND aa.ActiveStatus='A'
--								GROUP BY aa.CompId,aa.AppId,c.CompName,app.AppName
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)




--			--AppId & UserId & ActiveStatus
--			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type IS NULL AND @ActiveStatus IS NOT NULL
--					THEN (SELECT aa.CompId,aa.AppId,c.CompName,app.AppName,ISNULL((SELECT * 
--																						FROM Branch AS b 
--																						WHERE aa.CompId=b.CompId and aa.ActiveStatus = @ActiveStatus
--																					FOR JSON PATH),'[]') AS BranchDeatils 
--								FROM AppAccess AS aa 
--								INNER JOIN Company AS c 
--								ON c.CompId=aa.CompId AND c.ActiveStatus='A'
--								INNER JOIN Application AS app 
--								ON app.AppId=aa.AppId
--								WHERE aa.AppId=@AppId 
--								AND aa.UserId=@UserId and aa.ActiveStatus = @ActiveStatus
--								GROUP BY aa.CompId,aa.AppId,c.CompName,app.AppName ,aa.ActiveStatus
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)

--			--AppId & UserId & Type=DB(Default Branch)
--				WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NULL AND @Type='DB' AND @ActiveStatus IS  NULL
--					THEN(SELECT a.* FROM AppAccess as a
--							WHERE a.AppId=@AppId AND a.UserId=@UserId AND a.DefaultBranch='Y' AND a.ActiveStatus='A'
--							FOR JSON PATH, INCLUDE_NULL_VALUES)


--			--compId & AppId
--			    WHEN @UserId IS NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type IS NULL AND @ActiveStatus IS NULL
--					THEN (select (aa.BranchId) AS BrId,aa.CompId,b.BrName,c.CompName,aa.AppId,app.AppName from AppAccess as aa
--							inner join Company as c on c.CompId=aa.CompId
--							inner join Branch as b on b.BrId=aa.BranchId
--							inner join Application as app on app.AppId=aa.AppId
--							where aa.CompId=@CompId and aa.AppId=@AppId 
--							group by aa.BranchId,aa.CompId,b.BrName,c.CompName,aa.AppId,app.AppName
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)

--		--AppId,UserId,CompId
--			    WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type IS NULL AND @ActiveStatus IS  NULL
--					THEN (SELECT (aa.BranchId) AS BrId,aa.CompId,b.BrName,c.CompName,app.AppName,app.AppId
--							FROM AppAccess AS aa
--							INNER JOIN Company AS c 
--							ON c.CompId=aa.CompId
--							INNER JOIN Branch AS b 
--							ON b.BrId=aa.BranchId
--							INNER JOIN Application AS app 
--							ON app.AppId=aa.AppId
--							WHERE aa.CompId=@CompId 
--							AND aa.AppId=@AppId 
--							AND aa.UserId=@UserId  and  aa.ActiveStatus='A'
--						FOR JSON PATH, INCLUDE_NULL_VALUES)

--		--AppId,UserId,CompId,Type='T'
--				 WHEN @UserId IS NOT NULL AND @AppId IS NOT NULL AND @CompId IS NOT NULL AND @Type='T' AND @ActiveStatus IS NULL
--					THEN(SELECT TOP 1*
--								FROM ( 
--									SELECT uav.*,(a.CompId) as CompanyId,
--										CASE
--											WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
--											THEN 'Y'
--											ELSE 'N'
--										END AS Status,
--										ISNULL((SELECT COUNT(a.BranchId) FROM AppAccess AS a WHERE  a.UserId=@UserId AND a.AppId = @AppId AND a.ActiveStatus='A'),0) AS BranchCount,
--										ISNULL((SELECT f.FeatName, f.FeatConstraint
--											FROM Feature AS f
--											INNER JOIN PricingType as p ON p.PricingId=uav.PricingId AND p.AppId=uav.AppId
--											INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = p.PricingId AND pm.AppId = p.AppId AND pm.ActiveStatus = 'A'
--											WHERE f.FeatId = pm.FeatId 									
--											FOR JSON PATH),'[]') AS 'FeatureDetails',
--										ROW_NUMBER() OVER (PARTITION BY uav.UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
--									FROM userAppMapView AS uav
--									INNER JOIN AppAccess as a ON a.AppId=uav.AppId AND a.UserId=uav.UserId
--									WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND a.CompId=@CompId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
--								) AS A 
--								WHERE Row = 1
--								ORDER BY UniqueId DESC
					
					
--					--SELECT TOP 1*
--					--		FROM ( 
--					--			SELECT uav.*,
--					--				CASE
--					--					WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
--					--					THEN 'Y'
--					--					ELSE 'N'
--					--				END AS Status,
--					--				(SELECT COUNT(a.BranchId) FROM AppAccess AS a WHERE a.UserId = @UserId AND a.AppId = @AppId AND a.CompId=@CompId) AS BranchCount,
--					--				ROW_NUMBER() OVER (PARTITION BY uav.UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
--					--			FROM userAppMapView AS uav
--					--			INNER JOIN PricingType as p ON p.AppId=uav.AppId
--					--			INNER JOIN AppAccess as a ON a.AppId=uav.AppId AND a.UserId=uav.UserId
--					--			WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND a.CompId=@CompId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
--					--		) AS A 
--					--		WHERE Row = 1
--					--		ORDER BY UniqueId DESC 
							
--							FOR JSON PATH, INCLUDE_NULL_VALUES)



--			--AllNull
--			    WHEN @UserId IS NULL AND @AppId IS NULL AND @CompId IS NULL AND @Type IS NULL AND @ActiveStatus IS NULL
--					THEN (SELECT * 
--							FROM AppAccessView
--							  FOR JSON PATH, INCLUDE_NULL_VALUES)

--				ELSE
--					NULL

--					END)AS NVARCHAR(MAX)) AS mainData
--END
GO
/****** Object:  StoredProcedure [dbo].[getAppImage]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE Paypre_common_Framework;
CREATE PROCEDURE [dbo].[getAppImage] (@ImageId INT=NULL, @ActiveStatus CHAR(1)=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- ImageId
				WHEN @ImageId IS NOT NULL AND @ActiveStatus IS NULL 
					THEN (SELECT * 
							FROM appimageView
							WHERE ImageId=@ImageId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @ImageId IS NULL AND @ActiveStatus IS NOT NULL 
					THEN (SELECT * 
							FROM appimageView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--All Null
			    WHEN @ImageId IS NULL AND @ActiveStatus IS NULL 
					THEN (SELECT * 
							FROM appimageView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getApplication]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC getApplication @AppId=None, @ActiveStatus=None, @UserId=None, @Type=None,@subId=92 (None, None, None, None, 92)

CREATE PROCEDURE [dbo].[getApplication] (@AppId INT=NULL, @ActiveStatus CHAR(1)=NULL, @UserId INT=NULL, @Type CHAR(1)=NULL,@subId int=NULL,@CateId int=NULL,@subIds nvarchar(max)=null,@BranchId INT=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- AppId
				WHEN @AppId IS NOT NULL AND @ActiveStatus IS NULL AND @UserId IS NULL AND @Type IS NULL AND @subId IS NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (SELECT * 
							FROM applicationView
							WHERE AppId=@AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- SubId & UserId & Type='S' (selected Apps)
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NOT NULL AND @Type='S' AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (
					SELECT av.*,(SELECT Top 1 'Y' FROM AppAccess AS aa WHERE aa.UserId = @UserId AND aa.AppId=av.AppId) AS AppAccess 
							FROM applicationView AS av
							WHERE av.SubCateId=@subId
							AND av.AppId IN (SELECT AppId FROM AppAccess)
							FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- SubId & UserId & Type='B' (Branch Apps)
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NOT NULL AND @Type='B' AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (
					SELECT av.*,(SELECT Top 1 'Y' FROM AppAccess AS aa WHERE aa.UserId = @UserId AND aa.AppId=av.AppId) AS AppAccess
							FROM applicationView AS av
							WHERE av.SubCateId=@subId
							AND av.AppId IN (SELECT AppId FROM AppAccess WHERE UserId=@UserId)
							FOR JSON PATH, INCLUDE_NULL_VALUES)

			WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NOT NULL AND @Type IS NULL AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NOT NULL
				THEN (SELECT ai.*,(SELECT Top 1 'Y' FROM AppAccess AS aa WHERE aa.UserId = @UserId AND aa.BranchId=@BranchId AND aa.ActiveStatus='A' ) AS AppAccess
							FROM applicationView as ai
							--INNER JOIN UserAppMap as u
							--on u.AppId= ai.AppId
							where ai.SubCateId=@subId and ai.ActiveStatus='A' and ai.AppId IN (SELECT AppId FROM UserAppMap as u WHERE u.UserId=@UserId)
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--ActiveStatus
			    WHEN @AppId IS NULL AND @ActiveStatus IS NOT NULL AND @UserId IS NULL AND @Type IS NULL AND @subId IS NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (SELECT a.*,ISNULL((SELECT ai.ImageLink FROM AppImage  as ai WHERE ai.AppId=a.AppId FOR JSON PATH),'[]')as ImageLink 
							FROM applicationView as a
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
		
			

		--userId and Type
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NOT NULL AND @Type='H' AND @subId IS NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (
					SELECT an.CateId,
							an.SubCateId,
							cm.ConfigName AS CategoryName,
							cm.SmallIcon AS CategoryImage,
							cm2.ConfigName AS SubCategoryName,
							cm2.SmallIcon AS SubCategoryImage,
						JSON_QUERY(
						ISNULL((
							SELECT *  FROM (
						SELECT *  FROM (
							SELECT  * FROM(
							SELECT DISTINCT
									ai.AppId,
									ai.AppName,
									ai.AppLogo,
									ai.AppDescription,
									ai.BannerImage,
									ai.ActiveStatus,
									ai.CreatedBy,
									ai.CreatedDate,
									ai.UpdatedBy,
									ai.UpdatedDate,
									u.UserId,
									CASE
									    WHEN u.AppId IS  NULL THEN  'N'
										WHEN u.AppId IS NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  AND u.PaymentStatus = 'S'
										AND u.LicenseStatus = 'A'  AND ai.ActiveStatus='A' AND u.PaymentStatus = 'S'
										THEN 'Y' 						
										ELSE CASE																	 
										WHEN u.PaymentStatus != 'S' AND u.AppId IS  NOT NULL 
										AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
									    THEN  'N' END 
										END  AS subscribed,
									CASE
										WHEN u.AppId IS NOT NULL
										AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
										AND u.PaymentStatus = 'S' 
										AND u.LicenseStatus = 'A' AND ai.ActiveStatus='A'
										THEN 'Extend'
										WHEN u.AppId IS  NULL  THEN  'Open'								   
										WHEN u.PaymentStatus != 'S' THEN  'Open'
										END  AS Status
							FROM Application AS ai
							LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId   AND ai.ActiveStatus='A'
							WHERE ai.CateId = an.CateId AND ai.SubCateId = an.SubCateId  
								) AS A 
						WHERE  A.subscribed IN ( CASE WHEN   A.subscribed IN ( 'Y','N') AND AppId=A.AppId   THEN 'Y' 
						                      END ) )AS A  
					                 UNION 
						    SELECT *  FROM (
							SELECT   * FROM(
							SELECT DISTINCT
									ai.AppId,
									ai.AppName,
									ai.AppLogo,
									ai.AppDescription,
									ai.BannerImage,
									ai.ActiveStatus,
									ai.CreatedBy,
									ai.CreatedDate,
									ai.UpdatedBy,
									ai.UpdatedDate,
									u.UserId,
								   
									 CASE																	 
										 WHEN u.PaymentStatus != 'S' 
									     THEN  'N'  
										 WHEN u.AppId IS  NULL THEN  'N'
										END  AS subscribed,
									CASE
										WHEN u.AppId IS NOT NULL
										AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
										AND u.PaymentStatus = 'S' 
										AND u.LicenseStatus = 'A' AND ai.ActiveStatus='A'
										THEN 'Extend'
										WHEN u.AppId IS  NULL  THEN  'Open'								   
										WHEN u.PaymentStatus != 'S' THEN  'Open'
										END  AS Status
							FROM Application AS ai
							LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId   AND ai.ActiveStatus='A'
							WHERE ai.CateId = an.CateId AND ai.SubCateId = an.SubCateId  
								) AS A 
						WHERE  A.subscribed IN ( CASE WHEN   A.subscribed IN ( 'Y','N') AND AppId=A.AppId   THEN 'N' 
						                    END ) AND AppId NOT IN (
																	SELECT *  FROM (
							SELECT  AppId FROM(
							SELECT DISTINCT
									ai.AppId,
									ai.AppName,
									ai.AppLogo,
									ai.AppDescription,
									ai.BannerImage,
									ai.ActiveStatus,
									ai.CreatedBy,
									ai.CreatedDate,
									ai.UpdatedBy,
									ai.UpdatedDate,
									u.UserId,
								    u.PaymentStatus,

									CASE
									    WHEN u.AppId IS  NULL THEN  'N'
										WHEN u.AppId IS NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  AND u.PaymentStatus = 'S'
										AND u.LicenseStatus = 'A'  AND ai.ActiveStatus='A' AND u.PaymentStatus = 'S'
										THEN 'Y' 						
										ELSE CASE																	 
										WHEN u.PaymentStatus != 'S' AND u.AppId IS  NOT NULL 
										AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
									    THEN  'N' END 
										END  AS subscribed,
									CASE
										WHEN u.AppId IS NOT NULL
										AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
										AND u.PaymentStatus = 'S' 
										AND u.LicenseStatus = 'A' AND ai.ActiveStatus='A'
										THEN 'Extend'
										WHEN u.AppId IS  NULL  THEN  'Open'								   
										WHEN u.PaymentStatus != 'S' THEN  'Open'
										END  AS Status
							FROM Application AS ai
							LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId   AND ai.ActiveStatus='A'
							WHERE ai.CateId = an.CateId AND ai.SubCateId = an.SubCateId  
								) AS A 
						WHERE  A.subscribed IN ( CASE WHEN   A.subscribed IN ( 'Y','N') AND AppId=A.AppId   THEN 'Y' 
						                    ELSE CASE WHEN   A.subscribed IN ( 'N') THEN 'N' END   END ) )AS A  ) )AS A  
											) AS B

							FOR JSON PATH 
					),'[]')) AS AppDetails
						FROM Application AS an

						LEFT JOIN ConfigMaster AS cm ON cm.ConfigId = an.CateId
						LEFT JOIN ConfigMaster AS cm2 ON cm2.ConfigId = an.SubCateId
						WHERE An.ActiveStatus='A'
						GROUP BY
							an.CateId,
							an.SubCateId,
							an.CateId,
							cm.ConfigName,
							cm.SmallIcon,
							cm2.ConfigName,
							cm2.SmallIcon


					--SELECT an.CateId,
					--		an.SubCateId,
					--		cm.ConfigName AS CategoryName,
					--		cm.SmallIcon AS CategoryImage,
					--		cm2.ConfigName AS SubCategoryName,
					--		cm2.SmallIcon AS SubCategoryImage,
					--	JSON_QUERY(
					--	ISNULL((
					--	SELECT * FROM (
					--		SELECT  * FROM(
					--		SELECT DISTINCT
					--				ai.AppId,
					--				ai.AppName,
					--				ai.AppLogo,
					--				ai.AppDescription,
					--				ai.BannerImage,
					--				ai.ActiveStatus,
					--				ai.CreatedBy,
					--				ai.CreatedDate,
					--				ai.UpdatedBy,
					--				ai.UpdatedDate,
					--				u.PaymentStatus,
					--				u.UserId,
					--				u.ValidityStart,
					--				u.ValidityEnd,
							       
					--				CASE
					--					WHEN u.AppId IS NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  AND u.PaymentStatus = 'S'
					--					AND u.LicenseStatus = 'A'  AND ai.ActiveStatus='A'
					--					THEN 'Y'																	 
					--					WHEN u.PaymentStatus = 'S' AND u.AppId IS  NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  THEN  'Y' 
					--					WHEN u.PaymentStatus != 'S' AND u.AppId IS  NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  THEN  'N'
					--					WHEN u.AppId IS  NULL    THEN  'N'
					--					END  AS subscribed,
					--				CASE
					--					WHEN u.AppId IS NOT NULL
					--					AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
					--					AND u.PaymentStatus = 'S' 
					--					AND u.LicenseStatus = 'A' AND ai.ActiveStatus='A'
					--					THEN 'Extend'
					--					WHEN u.AppId IS  NULL  THEN  'Open'								   
					--					WHEN u.PaymentStatus != 'S' THEN  'Open'
					--					END  AS Status
					--		FROM Application AS ai
					--		LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId   AND ai.ActiveStatus='A'
					--		WHERE ai.CateId = an.CateId AND ai.SubCateId = an.SubCateId  
					--			) AS A 
					--	WHERE A.subscribed IN ('N','Y') )AS A   									
					--		FOR JSON PATH 
					--),'[]')) AS AppDetails
					--	FROM Application AS an
					--	LEFT JOIN ConfigMaster AS cm ON cm.ConfigId = an.CateId
					--	LEFT JOIN ConfigMaster AS cm2 ON cm2.ConfigId = an.SubCateId
					--	WHERE An.ActiveStatus='A'
					--	GROUP BY
					--		an.CateId,
					--		an.SubCateId,
					--		an.CateId,
					--		cm.ConfigName,
					--		cm.SmallIcon,
					--		cm2.ConfigName,
					--		cm2.SmallIcon 
					
					--SELECT an.CateId,
					--		an.SubCateId,
					--		cm.ConfigName AS CategoryName,
					--		cm.SmallIcon AS CategoryImage,
					--		cm2.ConfigName AS SubCategoryName,
					--		cm2.SmallIcon AS SubCategoryImage,
					--	JSON_QUERY(
					--	ISNULL((
					--		SELECT  * FROM(
					--		SELECT DISTINCT
					--				ai.AppId,
					--				ai.AppName,
					--				ai.AppLogo,
					--				ai.AppDescription,
					--				ai.BannerImage,
					--				ai.ActiveStatus,
					--				ai.CreatedBy,
					--				ai.CreatedDate,
					--				ai.UpdatedBy,
					--				ai.UpdatedDate,
					--				u.PaymentStatus,
					--				u.UserId,
																		       
					--				CASE
					--					WHEN u.AppId IS NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)  AND u.PaymentStatus = 'S'
					--					AND u.LicenseStatus = 'A'  AND ai.ActiveStatus='A'
					--					THEN 'Y'																	 
					--					WHEN u.PaymentStatus != 'S' THEN  'P'
					--					WHEN u.AppId IS  NULL  THEN  'N'
					--					END  AS subscribed,
					--				CASE
					--					WHEN u.AppId IS NOT NULL
					--					AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
					--					AND u.PaymentStatus = 'S'
					--					AND u.LicenseStatus = 'A' AND ai.ActiveStatus='A'
					--					THEN 'Extend'
					--					WHEN u.AppId IS  NULL  THEN  'Open'								   
					--					WHEN u.PaymentStatus != 'S' THEN  'Open'
					--					END  AS Status
					--		FROM Application AS ai
					--		LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId   AND ai.ActiveStatus='A'
					--		WHERE ai.CateId = an.CateId AND ai.SubCateId = an.SubCateId  
					--			) AS A 
					--		WHERE A.subscribed IN ('N','Y','P')
																		
					--		FOR JSON PATH 
					--),'[]')) AS AppDetails
					--	FROM Application AS an
					--	LEFT JOIN ConfigMaster AS cm ON cm.ConfigId = an.CateId
					--	LEFT JOIN ConfigMaster AS cm2 ON cm2.ConfigId = an.SubCateId
					--	WHERE An.ActiveStatus='A'
					--	GROUP BY
					--		an.CateId,
					--		an.SubCateId,
					--		an.CateId,
					--		cm.ConfigName,
					--		cm.SmallIcon,
					--		cm2.ConfigName,
					--		cm2.SmallIcon 
					
					
					--SELECT an.CateId,an.SubCateId,
					--		(SELECT cm.ConfigName FROM ConfigMaster AS cm WHERE cm.ConfigId=an.CateId AND an.ActiveStatus='A') AS CategoryName,
					--		(SELECT cm.SmallIcon FROM ConfigMaster AS cm WHERE cm.ConfigId=an.CateId AND an.ActiveStatus='A') AS CategoryImage,
					--		(SELECT cm.ConfigName FROM ConfigMaster AS cm WHERE cm.ConfigId=an.SubCateId AND an.ActiveStatus='A') AS SubCategoryName,
					--		(SELECT cm.SmallIcon FROM ConfigMaster AS cm WHERE cm.ConfigId=an.SubCateId AND an.ActiveStatus='A') as subCategoryImage ,
					--		ISNULL((SELECT DISTINCT ai.AppId,ai.AppName,ai.AppLogo,ai.AppDescription,ai.BannerImage,ai.ActiveStatus,
					--				ai.CreatedBy,ai.CreatedDate,ai.UpdatedBy,ai.UpdatedDate,u.UserId,(
					--			CASE
					--				WHEN u.AppId IS NOT NULL AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date) AND u.PaymentStatus='S' AND u.LicenseStatus='A'
					--				THEN 'Y'
					--				ELSE 'N'
					--			END) AS subscribed,

					--			CASE
					--				  WHEN u.AppId IS NOT NULL
					--					   AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date)
					--					   AND u.PaymentStatus = 'S'
					--					   AND u.LicenseStatus = 'A'
					--					   THEN 'Extend'
					--					   ELSE 'Open'
					--			  END AS Status

					--		FROM Application AS ai
					--		LEFT JOIN UserAppMap AS u ON u.AppId = ai.AppId AND u.UserId = @UserId
					--		WHERE an.AppId = ai.AppId and an.ActiveStatus='A' and ai.ActiveStatus='A' FOR JSON PATH),'[]') AS AppDetails
					--		FROM Application AS an
					    
						FOR JSON PATH, INCLUDE_NULL_VALUES)

			--subId
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NULL AND @Type IS NULL AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
				THEN (SELECT * 
							FROM applicationView 
							WHERE SubCateId=@subId
							AND AppId IN (SELECT AppId FROM AppAccess)
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--subIds
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NULL AND @Type IS NULL AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NOT NULL AND @BranchId IS NULL
				THEN (SELECT * 
							FROM applicationView where SubCateId in (@subIds)
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--subId AND UserId
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NOT NULL AND @Type IS NULL AND @subId IS NOT NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
				THEN (SELECT ai.*,u.UserId 
							FROM applicationView as ai
							INNER JOIN UserAppMap as u
							on u.AppId= ai.AppId
							where ai.SubCateId=@subId and u.UserId=@UserId
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--CateId
				WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NULL AND @Type IS NULL AND @subId IS NULL AND @CateId IS NOT NULL AND @subIds IS NULL AND @BranchId IS NULL
				THEN (SELECT distinct SubCateId,SubCategoryName,SubCategoryImage,ActiveStatus FROM applicationView where CateId=@CateId
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--Category ALL data
			WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @UserId IS NULL AND @Type='A' AND @subId IS NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
				THEN (SELECT distinct apv.CateId,apv.CategoryName,apv.CategoryImage FROM applicationView as apv 
						inner join Application as a on a.CateId=apv.CateId and a.ActiveStatus='A'
						where apv.ActiveStatus='A'
							  FOR JSON PATH, INCLUDE_NULL_VALUES)


			--AllNull
			    WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND  @UserId IS NULL AND @Type IS NULL AND @subId IS NULL AND @CateId IS NULL AND @subIds IS NULL AND @BranchId IS NULL
					THEN (SELECT * 
							FROM applicationView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getAppMenu]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getAppMenu] (@MenuId INT=NULL, @ActiveStatus CHAR(1)=NULL,@AppId int=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- MenuId
				WHEN @MenuId IS NOT NULL AND @ActiveStatus IS NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM appMenuView
							WHERE MenuId=@MenuId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @MenuId IS NULL AND @ActiveStatus IS NOT NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM appMenuView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
		   --AppId
				WHEN @MenuId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NOT NULL
					THEN (SELECT * 
							FROM appMenuView
							WHERE AppId=@AppId FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @MenuId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NULL 
					THEN (SELECT * 
							FROM appMenuView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getBranch]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getBranch] (@BrId INT=NULL, @ActiveStatus CHAR(1)=NULL,@CompId int=NULL, @UserId int=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- BrId
				WHEN @BrId IS NOT NULL AND @ActiveStatus IS NULL and @CompId IS NULL AND @UserId IS NULL
					THEN (SELECT * 
							FROM branchView
							WHERE BrId=@BrId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @BrId IS NULL AND @ActiveStatus IS NOT NULL and @CompId IS NULL AND @UserId IS NULL
					THEN (SELECT b.BrId,b.BrName,b.CompId 
							FROM branchView as b
						
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--CompId
			    WHEN @BrId IS NULL AND @ActiveStatus IS NULL and @CompId IS NOT NULL AND @UserId IS NULL
					THEN (SELECT b.*
							FROM branchView as b
							WHERE ActiveStatus='A' and CompId=@CompId FOR JSON PATH, INCLUDE_NULL_VALUES)

			--UserId
				WHEN @BrId IS NULL AND @ActiveStatus IS NULL and @CompId IS NULL AND @UserId IS NOT NULL
					THEN (SELECT b.*,a.UserId,(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=c.CompId group by a.AppId) as AppId
							FROM branchView as b
							INNER JOIN Company as c on c.CompId=b.CompId
							LEFT JOIN AppAccess as a on a.CompId=b.CompId AND a.BranchId=b.BrId
							WHERE a.UserId=@UserId 
							FOR JSON PATH, INCLUDE_NULL_VALUES)
				

			 --All Null
			  WHEN @BrId IS NULL AND @ActiveStatus IS NULL and @CompId IS NULL AND @UserId IS NULL
					THEN (
					--SELECT b.*,c.UserId,c.CompName,(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=c.CompId group by a.AppId) as AppId 
					--		FROM branchView as b
					--		INNER JOIN Company as c
					--		on c.CompId=b.CompId
					--SELECT b.*,a.UserId,c.CompName,(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=a.CompId group by a.AppId) as AppId 
					--		FROM branchView as b
					--		LEFT JOIN AppAccess as a
					--		on a.CompId=b.CompId
					--		LEFT JOIN Company as c
					--		on c.CompId= a.CompId
					SELECT DISTINCT bv.CompId,bv.BrId,bv.BrName,bv.BrShName,bv.BrAddId,bv.BrGSTIN,bv.BrInCharge,bv.BrMobile,bv.BrEmail,bv.BrRegnNo,bv.WorkingFrom,bv.WorkingTo,bv.ActiveStatus,bv.CreatedBy,bv.CreatedDate,bv.UpdatedBy,
							bv.UpdatedDate,bv.AddId,bv.Address1,bv.Address2,bv.City,bv.Dist,bv.Latitude,bv.Longitude,bv.State,
							bv.Zip,
							(SELECT top 1 a.UserId from AppAccess as a WHERE a.CompId=bv.CompId group by a.UserId) as UserId,
							(SELECT TOP 1 CompName FROM Company AS a WHERE a.CompId=bv.CompId) AS CompName,
							(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=bv.CompId group by a.AppId) as AppId
					FROM branchview AS bv
							FOR JSON PATH, INCLUDE_NULL_VALUES)
				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getCarousel]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getCarousel] (@ScreenId INT=NULL, @ActiveStatus CHAR(1)=NULL,@CarouselId INT=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- ScreenId
				WHEN @ScreenId IS NOT NULL AND @ActiveStatus IS NULL AND @CarouselId IS NULL 
					THEN (SELECT * 
							FROM carouselView
							WHERE ScreenId=@ScreenId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- CarouselId
				WHEN @ScreenId IS NULL AND @ActiveStatus IS NULL AND @CarouselId IS NOT NULL 
					THEN (SELECT * 
							FROM carouselView
							WHERE CarouselId=@CarouselId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @ScreenId IS NULL AND @ActiveStatus IS NOT NULL AND @CarouselId IS NULL 
					THEN (SELECT * 
							FROM carouselView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @ScreenId IS NULL AND @ActiveStatus IS NULL AND @CarouselId IS NULL 
					THEN (SELECT * 
							FROM carouselView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getCompany]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getCompany] (@CompId INT=NULL, @ActiveStatus CHAR(1)=NULL, @Type CHAR(1)=NULL,@UserId int =NULL)
AS
BEGIN
SELECT CAST((CASE 
			-- CompId
				WHEN @CompId IS NOT NULL AND @ActiveStatus IS NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT * 
							FROM companyView
							WHERE CompId=@CompId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @CompId IS NULL AND @ActiveStatus IS NOT NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT c.* 
							FROM companyView as c
							WHERE c.ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			

			--UserId
			    WHEN @CompId IS NULL AND @ActiveStatus IS NULL AND @Type IS NULL AND @UserId IS NOT NULL
					THEN (SELECT DISTINCT c.*,(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=c.CompId group by a.AppId) as AppId,a.UserId as AdminId 
							FROM companyView as c
							INNER JOIN AppAccess as a ON a.CompId=c.CompId
							where a.UserId=@UserId
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @CompId IS NULL AND @ActiveStatus IS NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT DISTINCT c.CompId,c.AddId,c.Address1,c.Address2,c.BusiBrief,c.City,c.CompAddId,c.CompEmail,c.CompGSTIN,c.CompLogo,c.CompMobile,
					c.CompName,c.CompPOC,c.CompRegnNo,c.CompShName,c.CreatedBy,c.CreatedDate,c.Dist,c.Latitude,c.Longitude,c.Proprietor,c.State,c.Zip,
					c.UpdatedBy,c.UpdatedDate,c.ActiveStatus,
					(SELECT top 1 a.AppId from AppAccess as a WHERE a.CompId=c.CompId group by a.AppId) as AppId,
					(SELECT top 1 a.UserId from AppAccess as a WHERE a.CompId=c.CompId group by a.UserId) as UserId
							FROM companyView as c
							--LEFT JOIN AppAccess as a ON a.CompId=c.CompId and a.UserId=c.UserId
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getCompAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getCompAppMap] (@UniqueId INT=NULL, @ActiveStatus CHAR(1)=NULL,@CompId INT=NULL,@BranchId INT=NULL,@AppId INT=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- UniqueId
				WHEN @UniqueId IS NOT NULL AND @ActiveStatus IS NULL AND @CompId IS NULL AND @BranchId IS NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM compAppMapView
							WHERE UniqueId=@UniqueId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- CompId 
				WHEN @UniqueId IS NULL AND @ActiveStatus IS NULL AND @CompId IS NOT NULL AND @BranchId IS NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM compAppMapView
							WHERE CompId=@CompId  FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- BranchId 
				WHEN @UniqueId IS NULL AND @ActiveStatus IS NULL AND @CompId IS NULL AND @BranchId IS NOT NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM compAppMapView
							WHERE BranchId=@BranchId  FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- BranchId 
				WHEN @UniqueId IS NULL AND @ActiveStatus IS NULL AND @CompId IS NULL AND @BranchId IS NULL AND @AppId IS NOT NULL
					THEN (SELECT * 
							FROM compAppMapView
							WHERE AppId=@AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @UniqueId IS NULL AND @ActiveStatus IS NOT NULL AND @CompId IS NULL AND @BranchId IS NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM compAppMapView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--AllNull
			    WHEN @UniqueId IS NULL AND @ActiveStatus IS NULL AND @CompId IS NULL AND @BranchId IS NULL AND @AppId IS NULL
					THEN (SELECT * 
							FROM compAppMapView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getConfigMaster]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getConfigMaster] (@ConfigId INT=NULL,@TypeId INT=NULL, @ActiveStatus CHAR(1)=NULL,@TypeName VARCHAR(50)=NULL)
AS
BEGIN
SELECT CAST((CASE 
			-- ConfigId
				WHEN @ConfigId IS NOT NULL AND @TypeId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configMasterView
							WHERE ConfigId=@ConfigId  FOR JSON PATH, INCLUDE_NULL_VALUES)	
			-- TypeId
				WHEN @TypeId IS NOT NULL AND @ConfigId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configMasterView
							WHERE TypeId=@TypeId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- TypeName
				WHEN @TypeId IS NULL AND @ConfigId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NOT NULL 
					THEN (SELECT * 
							FROM configMasterView
							WHERE TypeName=@TypeName  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--TypeName & ActiveStatus
				WHEN @TypeId IS NULL AND @ConfigId IS NULL AND @ActiveStatus IS NOT NULL AND @TypeName IS NOT NULL 
					THEN (SELECT * 
							FROM configMasterView
							WHERE TypeName=@TypeName and ActiveStatus=@ActiveStatus FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- TypeId & ActiveStatus
				WHEN @TypeId IS NOT NULL AND @ConfigId IS NULL AND @ActiveStatus IS NOT NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configMasterView
							WHERE TypeId=@TypeId AND ActiveStatus=@ActiveStatus FOR JSON PATH, INCLUDE_NULL_VALUES)

			--ActiveStatus
			    WHEN @TypeId IS NULL AND @ConfigId IS NULL AND @ActiveStatus IS NOT NULL AND @TypeName IS NULL 
					THEN (SELECT *
							FROM configMasterView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @TypeId IS NULL AND @ConfigId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configMasterView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getConfigType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getConfigType] (@TypeId INT=NULL, @ActiveStatus CHAR(1)=NULL,@TypeName VARCHAR(50)=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- TypeId
				WHEN @TypeId IS NOT NULL AND @ActiveStatus IS NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configTypeView
							WHERE TypeId=@TypeId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- TypeName
				WHEN @TypeId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NOT NULL 
					THEN (SELECT * 
							FROM configTypeView
							WHERE TypeName=@TypeName  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @TypeId IS NULL AND @ActiveStatus IS NOT NULL AND @TypeName IS NULL 
					THEN (SELECT ct.* 
							FROM configTypeView as ct
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--AllNull
			    WHEN @TypeId IS NULL AND @ActiveStatus IS NULL AND @TypeName IS NULL 
					THEN (SELECT * 
							FROM configTypeView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getCurrency]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getCurrency] (@CurrId INT=NULL, @ActiveStatus CHAR(1)=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- CurrId
				WHEN @CurrId IS NOT NULL AND @ActiveStatus IS NULL
					THEN (SELECT * 
							FROM currencyView
							WHERE CurrId=@CurrId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @CurrId IS NULL AND @ActiveStatus IS NOT NULL 
					THEN (SELECT * 
							FROM currencyView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--AllNull
			    WHEN @CurrId IS NULL AND @ActiveStatus IS NULL 
					THEN (SELECT * 
							FROM currencyView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getFeature]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getFeature] (@ActiveStatus CHAR(1)= NULL)
AS
BEGIN
	SELECT CAST((CASE WHEN @ActiveStatus IS NOT NULL	
						THEN (SELECT * FROM FeatureView WHERE ActiveStatus = @ActiveStatus FOR JSON PATH)
					  WHEN @ActiveStatus IS NULL 
						THEN (SELECT * FROM FeatureView FOR JSON PATH)
					  ELSE 
						NULL
					END
					) AS NVARCHAR(MAX)) as mainData
	--SELECT * FROM AppFeature

	
END
GO
/****** Object:  StoredProcedure [dbo].[GetFEatureMapping]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetFEatureMapping](@AppId INT = NULL,
									@Type CHAR(1) = NULL)

AS
DECLARE @Columns AS NVARCHAR(MAX)
DECLARE @NAmes NVARCHAR(MAx);
DECLARE @Squery NVARCHAR(MAx);
SET @Columns = N'';
BEGIN
			   SET @Columns=(
				SELECT  DISTINCT  abc = REPLACE(STUFF( (SELECT ',' +  N' ISNULL(' + QUOTENAME(FeatName)  + ', 0) ' + FeatName FROM (
				SELECT ISNULL(FeatName,0)  AS FeatName FROM Feature  GROUP BY FeatName ) AS A 
				FOR XML PATH ('')), 1, 1, '' ),' ','') FROM Feature GROUP BY FeatName)
								
				SET @NAmes=(
				SELECT  DISTINCT  abc = REPLACE(STUFF( (SELECT ',' + FeatName FROM (
				SELECT FeatName FROM Feature  GROUP BY FeatName ) AS A 
				FOR XML PATH ('')), 1, 1, '' ),' ','') FROM Feature GROUP BY FeatName)							
								

								
	    IF(@Type='M')
		BEGIN
		SET	@Squery= N'
		       SELECT * FROM (SELECT DISTINCT D.PricingId,F.PricingName,D.AppId,(  
				SELECT * FROM (
				SELECT PricingId,PricingName,AppId,'+@Columns+' FROM 
				(SELECT A.PricingId,C.PricingName,A.AppId,B.FeatName,ISNULL (B.FeatConstraint ,0)  AS  ''FeatConstraint''
				FROM PricingAppFeatMap AS A   INNER JOIN  
				Feature AS B On A.FeatId=B.FeatId
				INNER JOIN PricingType AS C ON A.PricingId=C.PricingId 
				WHERE 
				(''M'' = ''M''  AND NoOfDays =30)
				--OR ('+@Type+' = ''Y'' AND NoOfDays = 365)
				OR 
				(C.PricingName = ''Free'')
				AND A.ActiveStatus = ''A'' AND CAST(A.AppId AS VARCHAR(50))='''+CAST(@AppId AS VARCHAR(50)) +''' AND C.ActiveStatus=''A'' ) AS A
				PIVOT 
				( 
				MIN(FeatConstraint) FOR A.FeatName IN ('+@NAmes+') 
				) AS PivotTable ) AS A 
					WHERE A.AppId=D.AppId AND A.PricingId = D.PricingId
					for JSON path ) AS ''FeatureDetails'' 
				FROM PricingAppFeatMap AS D   INNER JOIN  
				Feature AS E On D.FeatId=E.FeatId
				INNER JOIN PricingType AS F ON D.PricingId=F.PricingId 
				WHERE  CAST(D.AppId AS VARCHAR(50))='+CAST(@AppId AS VARCHAR(50)) +' ) AS A WHERE A.FeatureDetails IS NOT NULL   FOR JSON PATH  '
		END
		ELSE
		BEGIN
			SET	@Squery= N' 
			 SELECT * FROM (SELECT DISTINCT D.PricingId,F.PricingName,D.AppId,(  
				SELECT * FROM (
				SELECT PricingId,PricingName,AppId,'+@Columns+' FROM 
				(SELECT A.PricingId,C.PricingName,A.AppId,B.FeatName,ISNULL (B.FeatConstraint ,0)  AS  ''FeatConstraint''
				FROM PricingAppFeatMap AS A   INNER JOIN  
				Feature AS B On A.FeatId=B.FeatId
				INNER JOIN PricingType AS C ON A.PricingId=C.PricingId 
				WHERE 
					(''Y'' = ''Y'' AND NoOfDays = 365)
				OR 
				(C.PricingName = ''Free'')
				AND A.ActiveStatus = ''A'' AND CAST(A.AppId AS VARCHAR(50))='''+CAST(@AppId AS VARCHAR(50)) +''' AND C.ActiveStatus=''A'' ) AS A
				PIVOT 
				( 
				MIN(FeatConstraint) FOR A.FeatName IN ('+@NAmes+') 
				) AS PivotTable ) AS A 
					WHERE A.AppId=D.AppId AND A.PricingId = D.PricingId
					for JSON path ) AS ''FeatureDetails'' 
				FROM PricingAppFeatMap AS D   INNER JOIN  
				Feature AS E On D.FeatId=E.FeatId
				INNER JOIN PricingType AS F ON D.PricingId=F.PricingId 
				WHERE  CAST(D.AppId AS VARCHAR(50))='+CAST(@AppId AS VARCHAR(50)) +'  ) AS A WHERE A.FeatureDetails IS NOT NULL  FOR JSON PATH  '
		END

							
		Exec(@Squery) 

END
GO
/****** Object:  StoredProcedure [dbo].[getLogin]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getLogin](@UserName NVARCHAR(20)=NULL,@Password NVARCHAR(20)=NULL,@Type NvarChar(50)=NULL,@CompId int=NULL,@BranchId int=NULL,@UserId int=NULL,@Pin Nvarchar(4)=NULL)
AS
BEGIN
BEGIN TRAN
DECLARE @tempVar VARCHAR(100);
BEGIN TRY
	SET @tempVar=CAST(@Username AS NVARCHAR(10))
END TRY
BEGIN CATCH
	SET @tempVar=-1
END CATCH
SELECT CAST((CASE 

				--Type
				WHEN @Type IS NOT NULL AND @UserName IS NULL AND @Password IS NULL AND @CompId IS NULL and @UserId IS NULL and @BranchId IS NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,(cm.ConfigName) as RoleName
							FROM [User] as u
							inner join ConfigMaster as cm on cm.ConfigId=u.UserType
							WHERE  u.ActiveStatus='A' and cm.ConfigName=@Type  FOR JSON PATH, INCLUDE_NULL_VALUES)
				--Type and CompId
				WHEN @Type IS NOT NULL AND @UserName IS NULL AND @Password IS NULL AND @CompId IS NOT NULL and @UserId IS NULL and @BranchId IS NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,emp.MobileAppAccess,emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'
							WHERE  u.ActiveStatus='A' and emp.RoleName=@Type and u.CompId=@CompId FOR JSON PATH, INCLUDE_NULL_VALUES)
				--UserId
				WHEN @Type IS NULL AND @UserName IS NULL AND @Password IS NULL AND @CompId IS NULL and @UserId IS NOT NULL and @BranchId IS NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,emp.MobileAppAccess,
					emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName,ISNULL((SELECT ea.AppId,a.AppName,a.CateId,a.SubCateId,cm.ConfigName 
																									FROM AppAccess AS ea
																									INNER JOIN Application AS a 
																									ON a.AppId=ea.AppId
																									INNER JOIN ConfigMaster AS cm 
																									ON cm.ConfigId=a.SubCateId
																									WHERE ea.UserId=@UserId
																									AND ea.ActiveStatus='A' FOR JSON PATH),'[]') as ModuleDetails
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'

							WHERE  u.ActiveStatus='A' and u.UserId=@UserId FOR JSON PATH, INCLUDE_NULL_VALUES)

					--UserId and BranchId
				WHEN @Type IS NULL AND @UserName IS NULL AND @Password IS NULL AND @CompId IS NULL and @UserId IS NOT NULL and @BranchId IS NOT NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,emp.MobileAppAccess,
					emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName,ISNULL((
																						SELECT ea.AppId,a.AppName,a.CateId,a.SubCateId,cm.ConfigName 
																									FROM AppAccess AS ea
																									INNER JOIN Application AS a 
																									ON a.AppId=ea.AppId
																									INNER JOIN ConfigMaster AS cm 
																									ON cm.ConfigId=a.SubCateId
																									WHERE ea.UserId=@UserId
																									AND ea.BranchId=@BranchId
																									AND ea.ActiveStatus='A'
																									FOR JSON PATH
																				
																			),'[]') as ModuleDetails
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'

							WHERE  u.ActiveStatus='A' and u.UserId=@UserId FOR JSON PATH, INCLUDE_NULL_VALUES)
				--BranchId and Type
				WHEN @Type IS Not NULL AND @UserName IS NULL AND @Password IS NULL AND @CompId IS NULL and @UserId IS NULL and @BranchId IS NOT NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,cm.ConfigName as UserTypeName,
					emp.MobileAppAccess,emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'
							inner join ConfigMaster as cm on u.UserType=cm.ConfigId
							WHERE  u.ActiveStatus='A' and u.BranchId=@BranchId AND
							cm.ConfigName=(CASE
											WHEN @Type='E' THEN 'Employee'
										   ELSE ''
											END)
							
							--AND 
							--emp.RoleName= (CASE
							--						WHEN @Type='E' THEN 'BranchAdmin'
							--						ELSE ''
							--					END)

							
							FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- Username
				--WHEN EXISTS(SELECT * FROM [User] WHERE UserName = @UserName AND Password = @Password)
				--	THEN (SELECT UserName,UserType,MobileNo,MailId,UserId,BranchId,CompId 
				--			FROM [User] 
				--			WHERE UserName = @UserName AND Password = @Password FOR JSON PATH)	
			--EmailId
				--WHEN EXISTS(SELECT * FROM [User] WHERE MailId = @UserName AND Password = @Password)
				--	THEN (SELECT UserName,UserType,MobileNo,MailId,UserId,BranchId,CompId 
				--			FROM [User] 
				--			WHERE MailId = @UserName AND Password = @Password FOR JSON PATH)

			--MobileNumber and Password
				--WHEN EXISTS(SELECT * FROM [User] WHERE MobileNo = @tempVar AND Password = @Password)
				WHEN @Type IS NULL AND @UserName IS NOT NULL AND @Password IS NOT NULL AND @CompId IS NULL and @UserId IS NULL and @BranchId IS NULL and @Pin IS NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,emp.MobileAppAccess,emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName,cm.ConfigName as UserTypeName
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'
							inner join ConfigMaster as cm on u.UserType=cm.ConfigId
							WHERE u.MobileNo = @UserName AND  u.Password=@Password AND u.ActiveStatus='A' FOR JSON PATH)
		     --MobileNumber and Pin
				--WHEN EXISTS(SELECT * FROM [User] WHERE MobileNo = @tempVar AND Pin=@Pin)
				WHEN @Type IS NULL AND @UserName IS NOT NULL AND @Password IS NULL AND @CompId IS NULL and @UserId IS NULL and @BranchId IS NULL and @Pin IS NOT NULL
					THEN (SELECT u.UserId,u.UserName,u.UserType,u.MobileNo,u.MailId,u.CompId,u.BranchId,u.ActiveStatus,emp.MobileAppAccess,emp.EmpShiftId,emp.RoleId,emp.RoleName,emp.CompName,emp.BrName,cm.ConfigName as UserTypeName
							FROM [User] as u
							left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=u.UserId AND emp.ActiveStatus='A'
							inner join ConfigMaster as cm on u.UserType=cm.ConfigId
							WHERE u.MobileNo = @UserName AND u.Pin=@Pin AND u.ActiveStatus='A' FOR JSON PATH)
				ELSE
					NULL

					END)as nvarchar(max)) AS mainData

IF @@TRANCOUNT>0
	COMMIT

END

--select * from [User]
--EXEC getLogin @UserName='8888888888',@Pin='1235'
GO
/****** Object:  StoredProcedure [dbo].[getMessagetemplate]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getMessagetemplate] (@MessageHeader VARCHAR(50)=NULL,@Subject VARCHAR(150)=NULL, @TemplateType CHAR(1)=NULL, @UniqueId INT=NULL)
AS
BEGIN
SELECT CAST((CASE 
			
			-- MessageHeader
				WHEN @MessageHeader IS NOT NULL AND @Subject IS NULL AND @TemplateType IS NULL AND @UniqueId IS NULL
					THEN (SELECT * 
							FROM MessageTemplatesView
							WHERE MessageHeader=@MessageHeader  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--Subject
			    WHEN @MessageHeader IS NULL AND @Subject IS NOT NULL AND @TemplateType IS NULL AND @UniqueId IS NULL
					THEN (SELECT * 
							FROM MessageTemplatesView
							WHERE Subject=@Subject  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--TemplateType
				 WHEN @MessageHeader IS NULL AND @Subject IS NULL AND @TemplateType IS NOT NULL AND @UniqueId IS NULL
					THEN (SELECT * 
							FROM MessageTemplatesView
							WHERE TemplateType=@TemplateType  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--UniqueId
				 WHEN @MessageHeader IS NULL AND @Subject IS NULL AND @TemplateType IS NULL AND @UniqueId IS NOT NULL
					THEN (SELECT * 
							FROM MessageTemplatesView
							WHERE UniqueId=@UniqueId  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AllNull
			    WHEN @MessageHeader IS NULL AND @Subject IS NULL AND @TemplateType IS NULL AND @UniqueId IS NULL
					THEN (SELECT * 
							FROM MessageTemplatesView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getPaymentUPIDetails]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getPaymentUPIDetails] (@type char(1)=NULL,@activeStatus char(1)=NULL,@UserId INT=NULL,@PaymentUPIDetailsId int=null)
AS
BEGIN
SELECT CAST((CASE 

			-- @PaymentUPIDetailsId
				WHEN @type IS NULL AND @activeStatus IS NULL AND @UserId IS NULL AND @PaymentUPIDetailsId IS NOT NULL
					THEN (SELECT pv.*,cm.ConfigName as ModeName
							FROM PaymentUPIDetailsView as pv
							inner join ConfigMaster as cm on cm.ConfigId=pv.mode
							WHERE pv.PaymentUPIDetailsId=@PaymentUPIDetailsId FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			-- type and @activeStatus
				WHEN @type IS NOT NULL AND @activeStatus IS NOT NULL AND @UserId IS NULL AND @PaymentUPIDetailsId IS NULL
					THEN (SELECT pv.*,cm.ConfigName as ModeName
							FROM PaymentUPIDetailsView as pv
							inner join ConfigMaster as cm on cm.ConfigId=pv.mode
							WHERE pv.type=@type AND pv.activeStatus=@activeStatus FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- @activeStatus
				WHEN @type IS NULL AND @activeStatus IS NOT NULL AND @UserId IS NULL AND @PaymentUPIDetailsId IS NULL
					THEN (SELECT pv.*
							FROM PaymentUPIDetailsView as pv
							WHERE pv.activeStatus=@activeStatus FOR JSON PATH, INCLUDE_NULL_VALUES)

			--adminId & type=O
				WHEN @type IS NOT NULL AND @activeStatus IS NULL AND @UserId IS NOT NULL AND @PaymentUPIDetailsId IS NULL
					THEN (SELECT (pu.AdminId) as UserId,(pu.BranchId) as BrId, pu.CompId,pu.MerchantCode,pu.MerchantId,pu.MobileNo,pu.activeStatus,
								pu.mode,pu.Name,pu.orgid,pu.PaymentUPIDetailsId,pu.sign,pu.type,pu.UPIId,pu.url,pu.CreatedBy,pu.CreatedDate,pu.UpdatedBy,pu.UpdatedDate,
								pu.AdminName,pu.CompName,pu.BrName,cm.ConfigName as ModeName			
							FROM PaymentUPIDetailsView as pu
							inner join ConfigMaster as cm on cm.ConfigId=pu.mode
							WHERE AdminId=@UserId AND type=@type FOR JSON PATH, INCLUDE_NULL_VALUES)

			---AllNULL
				WHEN @type IS NULL AND @activeStatus IS NULL AND @UserId IS NULL AND @PaymentUPIDetailsId IS NULL
					THEN (SELECT (pu.AdminId) as UserId,(pu.BranchId) as BrId, pu.CompId,pu.MerchantCode,pu.MerchantId,pu.MobileNo,pu.activeStatus,
								pu.mode,pu.Name,pu.orgid,pu.PaymentUPIDetailsId,pu.sign,pu.type,pu.UPIId,pu.url,pu.CreatedBy,pu.CreatedDate,pu.UpdatedBy,pu.UpdatedDate,
								pu.AdminName,pu.CompName,pu.BrName,cm.ConfigName as ModeName
							FROM PaymentUPIDetailsView as pu
							inner join ConfigMaster as cm on cm.ConfigId=pu.mode
							FOR JSON PATH, INCLUDE_NULL_VALUES)
		

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getPricingAppFeatMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getPricingAppFeatMap] (@AppId INT=NULL, @ActiveStatus CHAR(1)=NULL,@PricingId int =NULL, @UserId INT= NULL,@Type CHAR(1)=NULL)
AS
DECLARE @Columns AS NVARCHAR(MAX)
DECLARE @NAmes NVARCHAR(MAx);
DECLARE @Squery NVARCHAR(MAx);
SET @Columns = N'';
BEGIN
SELECT CAST((CASE 
			
			-- AppId
				WHEN @AppId IS NOT NULL AND @ActiveStatus IS NULL AND @PricingId IS NULL  AND @UserId IS NULL AND @Type IS  NULL
					THEN (SELECT * 
							FROM pricingAppFeatMapView
							WHERE AppId=@AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @AppId IS NULL AND @ActiveStatus IS NOT NULL AND @PricingId IS NULL  AND @UserId IS NULL AND @Type IS  NULL
					THEN (SELECT * 
							FROM pricingAppFeatMapView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--PricingId
			    WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @PricingId IS NOT NULL  AND @UserId IS NULL AND @Type IS  NULL
					THEN (SELECT * 
							FROM pricingAppFeatMapView
							WHERE ActiveStatus=@PricingId AND ActiveStatus='A'  FOR JSON PATH, INCLUDE_NULL_VALUES)


			 ---AppId & UserId & Type
				 WHEN @AppId IS NOT NULL AND @ActiveStatus IS NULL AND @PricingId IS NULL  AND @UserId IS NOT NULL AND @Type IS NOT NULL
					THEN (SELECT * FROM(
						  SELECT pv.AppId,
							CASE
								WHEN (
									EXISTS (
										SELECT uam.*
										FROM UserAppMap AS uam
										WHERE uam.UserId = @UserId
											AND uam.AppId = pv.AppId
											--AND uam.PricingId = pv.PricingId
											AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
											AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
									)
									AND pv.PricingName = 'Free'
								) THEN 'Already Used'
							  WHEN EXISTS (
									   SELECT uam.*
									   FROM UserAppMap AS uam
									   WHERE uam.UserId = @UserId
										   AND uam.AppId = pv.AppId
										   AND uam.PricingId = pv.PricingId
										   AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
										   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
								   ) OR EXISTS (
									   SELECT uam.*
									   FROM UserAppMap AS uam
									   WHERE uam.UserId = @UserId
										   AND uam.AppId = pv.AppId
										   AND uam.PricingId = pv.PricingId
										   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
								   ) THEN 'Extend Pack'
								ELSE CASE
										WHEN pv.PricingName = 'Free' THEN 'Start Free'
										ELSE ''
									END
							END AS 'Status',
							pv.PricingName,
							pv.Price,
							pv.PricingId,
							ISNULL(pv.DisplayPrice, 0) AS DisplayPrice,
							pv.NetPrice,
							pv.PriceTag,
							pv.NoOfDays,
							(SELECT ConfigName FROM ConfigMaster WHERE ConfigId = pv.PriceTag) AS PriceTagName,
							(SELECT f.FeatName, f.FeatConstraint
							FROM Feature AS f
							INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = pv.PricingId AND pm.AppId = @AppId AND pm.ActiveStatus = 'A'
							WHERE f.FeatId = pm.FeatId and pv.AppId= pm.AppId
									
						   	FOR JSON PATH) AS 'FeatureDetails'
					FROM pricingTypeView AS pv
			
					WHERE (
							(@Type = 'M' AND NoOfDays <= 30) -- Validate for Type = 'M' using calculated months
							OR (@Type = 'Y' AND NoOfDays <= 365) -- Validate for Type = 'Y' using calculated years
							OR pv.PricingName = 'Free'
							)
							AND pv.ActiveStatus = 'A'
							AND pv.AppId = @AppId
							AND (
							(
								EXISTS (
								SELECT uam.*
								FROM UserAppMap AS uam
								WHERE uam.UserId = @UserId
									AND uam.AppId = pv.AppId
									AND uam.PricingId = pv.PricingId
									--AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
								)
								AND pv.PricingName != 'Free'
							)
							OR (
								pv.PricingName = 'Free'
								AND NOT EXISTS (
								SELECT uam.*
								FROM UserAppMap AS uam
								WHERE uam.UserId = @UserId
									AND uam.AppId = pv.AppId
									AND uam.PricingId = pv.PricingId
									--AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
								)
							)
							OR NOT EXISTS (
								SELECT uam.*
								FROM UserAppMap AS uam
								WHERE uam.UserId = @UserId
									AND uam.AppId = pv.AppId
									AND uam.PricingId = pv.PricingId
							)
							)
							OR pv.PricingName = 'Free') AS A WHERE AppId=@AppId AND ((PricingName = 'Free' AND FeatureDetails IS NULL) OR (PricingName != 'Free' AND ISNULL(FeatureDetails, '[]') != '[]')) ORDER BY NetPrice ASC FOR JSON PATH, INCLUDE_NULL_VALUES)

			---AppId & Type
				 WHEN @AppId IS NOT NULL AND @ActiveStatus IS NULL AND @PricingId IS NULL  AND @UserId IS NULL AND @Type IS NOT NULL
					THEN(
							SELECT * FROM (SELECT pv.PricingName, pv.PricingId, pv.AppId,
							   (
							   SELECT * FROM (
								  SELECT * FROM ( SELECT  f.FeatName, ROW_NUMBER() OVER (PARTITION BY  f.FeatName ORDER BY  f.FeatName  ) AS ROW ,
										  f.FeatConstraint,f.FeatId,
										 
										  CASE
											  WHEN f.FeatId = pm.FeatId THEN 'Y'
											  ELSE 'N'
										  END AS Status
								   FROM Feature AS f
								   INNER JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A' ) AS A
								   WHERE ROW =1 AND Status='Y'
								   UNION
								   SELECT * FROM (
								   SELECT f.FeatName,
										  f.FeatConstraint,f.FeatId, ROW_NUMBER() OVER (PARTITION BY  f.FeatName ORDER BY  f.FeatName  ) AS ROW ,
										 
										  CASE
											  WHEN f.FeatId = pm.FeatId THEN 'Y'
											  ELSE 'N'
										  END AS Status
								   FROM Feature AS f
								   LEFT JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A' ) AS A
								    WHERE ROW=1 AND Status='N' AND A.FeatName NOT IN( SELECT FeatName FROM ( SELECT  f.FeatName, ROW_NUMBER() OVER (PARTITION BY  f.FeatName ORDER BY  f.FeatName  ) AS ROW ,
										  f.FeatConstraint,
										 
										  CASE
											  WHEN f.FeatId = pm.FeatId THEN 'Y'
											  ELSE 'N'
										  END AS Status
								   FROM Feature AS f
								   INNER JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A' ) AS A
								   ) ) AS A
								   --WHERE pm.AppId = @AppId
								   FOR JSON PATH
							   ) AS 'FeatureDetails'
						FROM PricingType AS pv
						WHERE @Type = 'M'  AND NoOfDays = 30 -- Validate for Type = 'M' using calculated months
								OR (@Type = 'Y' AND NoOfDays = 365) -- Validate for Type = 'Y' using calculated years
								OR pv.PricingName = 'Free'
								AND ActiveStatus = 'A' AND pv.AppId=@AppId) as A WHERE AppId=@AppId
					
					--SELECT * FROM (SELECT pv.PricingName, pv.PricingId, pv.AppId,
					--		   (
					--			   SELECT f.FeatName,
					--					  f.FeatConstraint,
					--					  f.FeatId,
					--					  CASE
					--						  WHEN f.FeatId = pm.FeatId THEN 'Y'
					--						  ELSE 'N'
					--					  END AS Status
					--			   FROM Feature AS f
					--			   LEFT JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A'
					--			   --WHERE pm.AppId = @AppId
					--			   FOR JSON PATH
					--		   ) AS 'FeatureDetails'
					--	FROM PricingType AS pv
					--	WHERE @Type = 'M'  AND NoOfDays = 30 -- Validate for Type = 'M' using calculated months
					--			OR (@Type = 'Y' AND NoOfDays = 365) -- Validate for Type = 'Y' using calculated years
					--			OR pv.PricingName = 'Free'
					--			AND ActiveStatus = 'A' AND pv.AppId=@AppId) as A WHERE AppId=@AppId 
								
								FOR JSON PATH, INCLUDE_NULL_VALUES)

			---AppId & Type
		--		WHEN @AppId IS NOT NULL AND @ActiveStatus IS NULL AND @PricingId IS NULL  AND @UserId IS NULL AND @Type IS NOT NULL
		--			THEN(
		--	   SET @Columns=(
		--		SELECT  DISTINCT  abc = REPLACE(STUFF( (SELECT ',' +  N' ISNULL(' + QUOTENAME(FeatName)  + ', 0) ' + FeatName FROM (
		--		SELECT ISNULL(FeatName,0)  AS FeatName FROM Feature  GROUP BY FeatName ) AS A 
		--		FOR XML PATH ('')), 1, 1, '' ),' ','') FROM Feature GROUP BY FeatName)
								
		--		SET @NAmes=(
		--		SELECT  DISTINCT  abc = REPLACE(STUFF( (SELECT ',' + FeatName FROM (
		--		SELECT FeatName FROM Feature  GROUP BY FeatName ) AS A 
		--		FOR XML PATH ('')), 1, 1, '' ),' ','') FROM Feature GROUP BY FeatName)							
								

								
	 --   IF(@Type='M')
		--BEGIN
		--SET	@Squery= N'
		--       SELECT * FROM (SELECT DISTINCT D.PricingId,F.PricingName,D.AppId,(  
		--		SELECT * FROM (
		--		SELECT PricingId,PricingName,AppId,'+@Columns+' FROM 
		--		(SELECT A.PricingId,C.PricingName,A.AppId,B.FeatName,ISNULL (B.FeatConstraint ,0)  AS  ''FeatConstraint''
		--		FROM PricingAppFeatMap AS A   INNER JOIN  
		--		Feature AS B On A.FeatId=B.FeatId
		--		INNER JOIN PricingType AS C ON A.PricingId=C.PricingId 
		--		WHERE 
		--		(''M'' = ''M''  AND NoOfDays =30)
		--		--OR ('+@Type+' = ''Y'' AND NoOfDays = 365)
		--		OR 
		--		(C.PricingName = ''Free'')
		--		AND A.ActiveStatus = ''A'' AND CAST(A.AppId AS VARCHAR(50))='''+CAST(@AppId AS VARCHAR(50)) +''' AND C.ActiveStatus=''A'' ) AS A
		--		PIVOT 
		--		( 
		--		MIN(FeatConstraint) FOR A.FeatName IN ('+@NAmes+') 
		--		) AS PivotTable ) AS A 
		--			WHERE A.AppId=D.AppId AND A.PricingId = D.PricingId
		--			for JSON path ) AS ''FeatureDetails'' 
		--		FROM PricingAppFeatMap AS D   INNER JOIN  
		--		Feature AS E On D.FeatId=E.FeatId
		--		INNER JOIN PricingType AS F ON D.PricingId=F.PricingId 
		--		WHERE  CAST(D.AppId AS VARCHAR(50))='+CAST(@AppId AS VARCHAR(50)) +' ) AS A WHERE A.FeatureDetails IS NOT NULL   FOR JSON PATH  '
		--END
		--ELSE
		--BEGIN
		--	SET	@Squery= N' 
		--	 SELECT * FROM (SELECT DISTINCT D.PricingId,F.PricingName,D.AppId,(  
		--		SELECT * FROM (
		--		SELECT PricingId,PricingName,AppId,'+@Columns+' FROM 
		--		(SELECT A.PricingId,C.PricingName,A.AppId,B.FeatName,ISNULL (B.FeatConstraint ,0)  AS  ''FeatConstraint''
		--		FROM PricingAppFeatMap AS A   INNER JOIN  
		--		Feature AS B On A.FeatId=B.FeatId
		--		INNER JOIN PricingType AS C ON A.PricingId=C.PricingId 
		--		WHERE 
		--			(''Y'' = ''Y'' AND NoOfDays = 365)
		--		OR 
		--		(C.PricingName = ''Free'')
		--		AND A.ActiveStatus = ''A'' AND CAST(A.AppId AS VARCHAR(50))='''+CAST(@AppId AS VARCHAR(50)) +''' AND C.ActiveStatus=''A'' ) AS A
		--		PIVOT 
		--		( 
		--		MIN(FeatConstraint) FOR A.FeatName IN ('+@NAmes+') 
		--		) AS PivotTable ) AS A 
		--			WHERE A.AppId=D.AppId AND A.PricingId = D.PricingId
		--			for JSON path ) AS ''FeatureDetails'' 
		--		FROM PricingAppFeatMap AS D   INNER JOIN  
		--		Feature AS E On D.FeatId=E.FeatId
		--		INNER JOIN PricingType AS F ON D.PricingId=F.PricingId 
		--		WHERE  CAST(D.AppId AS VARCHAR(50))='+CAST(@AppId AS VARCHAR(50)) +'  ) AS A WHERE A.FeatureDetails IS NOT NULL  FOR JSON PATH  '
		--END

							
		--Exec(@Squery) )
			--AllNull
			    WHEN @AppId IS NULL AND @ActiveStatus IS NULL AND @PricingId IS NULL  AND @UserId IS NULL AND @Type IS  NULL
					THEN (SELECT * 
							FROM pricingAppFeatMapView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getPricingType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getPricingType] (@PricingId INT=NULL, @ActiveStatus CHAR(1)=NULL,@AppId INT=NULL,@NoOfDays INT=NULL, @Type CHAR(1)=NULL, @UserId INT= NULL)
AS
BEGIN
--DECLARE @NoOfMonths INT;
--DECLARE @NoOfYears INT;
--SET @NoOfMonths = @NoOfDays / 30;

SELECT CAST((CASE 
			
			-- PricingId
				WHEN @PricingId IS NOT NULL AND @ActiveStatus IS NULL AND @AppId IS NULL  AND @NoOfDays IS NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT pv.*,(select f.FeatName,f.FeatConstraint  from Feature as f 
					INNER JOIN PricingAppFeatMap as pm
							ON pm.PricingId=pv.PricingId AND pm.AppId= pv.AppId AND pm.ActiveStatus='A'
					where f.FeatId=pm.FeatId for json path) as FeatureDetails
							FROM pricingTypeView as pv
							--INNER JOIN PricingAppFeatMap as pm
							--ON pm.PricingId=pv.PricingId AND pm.AppId= pv.AppId AND pm.ActiveStatus='A'
							--INNER JOIN Feature as f
							--ON f.FeatId=pm.FeatId
							WHERE pv.PricingId=@PricingId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- AppId
				WHEN @PricingId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NOT NULL  AND @NoOfDays IS NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT * 
							FROM pricingTypeView
							WHERE AppId=@AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)

			---- AppId && Type='F'
			--	WHEN @PricingId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NOT NULL  AND @NoOfDays IS NULL AND @Type='F' AND @UserId IS NULL
			--		THEN (SELECT pv.PricingName, pv.PricingId,
			--				   (
			--					   SELECT f.FeatName,
			--							  f.FeatConstraint,
			--							  f.FeatId,
			--							  CASE
			--								  WHEN f.FeatId = pm.FeatId THEN 'Y'
			--								  ELSE 'N'
			--							  END AS Status
			--					   FROM Feature AS f
			--					   LEFT JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A'
			--					   --WHERE pm.AppId = @AppId
			--					   FOR JSON PATH
			--				   ) AS 'FeatureDetails'
			--			FROM PricingType AS pv
			--			WHERE pv.AppId = @AppId  
						
			--			FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--ActiveStatus
			    WHEN @PricingId IS NULL AND @ActiveStatus IS NOT NULL AND @AppId IS NULL  AND @NoOfDays IS NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT * 
							FROM pricingTypeView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)

			--AppId & Type
				WHEN @PricingId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NOT NULL  AND @NoOfDays IS NULL AND @Type IS NOT NULL AND @UserId IS NULL
					THEN (
							SELECT * FROM(SELECT pv.AppId,pv.PricingName,pv.Price,pv.PricingId,ISNULL(pv.DisplayPrice,0)as DisplayPrice ,pv.PriceTag, pv.NoOfDays,
							(SELECT ConfigName FROM ConfigMaster as c WHERE c.ConfigId=pv.PriceTag)as PriceTagName,pv.NetPrice,
							(SELECT f.FeatName, f.FeatConstraint
							FROM Feature AS f
							INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = pv.PricingId AND pm.AppId = @AppId AND pm.ActiveStatus = 'A'
							WHERE f.FeatId = pm.FeatId and pv.AppId= pm.AppId	
						   	FOR JSON PATH) AS 'FeatureDetails'
							FROM pricingTypeView as pv
							WHERE
								(@Type = 'M'  AND NoOfDays = 30) -- Validate for Type = 'M' using calculated months
								OR (@Type = 'Y' AND NoOfDays = 365) -- Validate for Type = 'Y' using calculated years
								OR pv.PricingName = 'Free'
								AND ActiveStatus = 'A' AND pv.AppId=@AppId) as A WHERE AppId=@AppId AND ((PricingName = 'Free' AND FeatureDetails IS NULL) OR (PricingName != 'Free' AND ISNULL(FeatureDetails, '[]') != '[]')) ORDER BY NetPrice ASC
							FOR JSON PATH, INCLUDE_NULL_VALUES)


			--Type & ActiveStatus & AppId
				WHEN @PricingId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NOT NULL  AND @NoOfDays IS NULL AND @Type IS NOT NULL AND @UserId IS NOT NULL
					THEN( 
					Select A.*, JSON_QUERY(A.FeatureDetails) AS FeatureDetail FROM (SELECT * FROM(
                                                SELECT pv.AppId,
                                                        CASE
                                                                WHEN (
                                                                        EXISTS (
                                                                                SELECT uam.*
                                                                                FROM UserAppMap AS uam
                                                                                WHERE uam.UserId = @UserId
                                                                                        AND uam.AppId = pv.AppId
                                                                                        AND uam.PricingId = pv.PricingId
                                                                                        AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
                                                                                        AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
                                                                        )
                                                                        AND pv.PricingName = 'Free'
                                                                ) THEN 'Already Used'
                                                          WHEN EXISTS (
                                                                           SELECT uam.*
                                                                           FROM UserAppMap AS uam
                                                                           WHERE uam.UserId = @UserId
                                                                                   AND uam.AppId = pv.AppId
                                                                                   AND uam.PricingId = pv.PricingId
                                                                                   AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
                                                                                   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
                                                                   ) OR EXISTS (
                                                                           SELECT uam.*
                                                                           FROM UserAppMap AS uam
                                                                           WHERE uam.UserId = @UserId
                                                                                   AND uam.AppId = pv.AppId
                                                                                   AND uam.PricingId = pv.PricingId
                                                                                   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
                                                                   ) THEN 'Extend Pack'
                                                                ELSE CASE
                                                                                WHEN pv.PricingName = 'Free' THEN 'Start Free'
                                                                                ELSE ''
                                                                        END
                                                        END AS 'Status',
                                                        pv.PricingName,
                                                        pv.Price,
                                                        pv.PricingId,
                                                        ISNULL(pv.DisplayPrice, 0) AS DisplayPrice,
                                                        pv.NetPrice,
                                                        pv.PriceTag,
                                                        pv.NoOfDays,
                                                        (SELECT ConfigName FROM ConfigMaster WHERE ConfigId = pv.PriceTag) AS PriceTagName,
                                                       (
                                                                   SELECT f.FeatName,
                                                                                  f.FeatConstraint,
                                                                                  f.FeatId,
                                                                                  CASE
                                                                                          WHEN f.FeatId = pm.FeatId THEN 'Y'
                                                                                          ELSE 'N'
                                                                                  END AS Status
                                                                   FROM Feature AS f
                                                                   LEFT JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A'
                                                                   --WHERE pm.AppId = @AppId
                                                                   FOR JSON PATH
                                                           ) AS 'FeatureDetails'
                                        
                                                        --(SELECT f.FeatName, f.FeatConstraint
                                                        --FROM Feature AS f
                                                        --INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = pv.PricingId AND pm.AppId = @AppId AND pm.ActiveStatus = 'A'
                                                        --WHERE f.FeatId = pm.FeatId and pv.AppId= pm.AppId
                                                                        
                                                 --          FOR JSON PATH) AS 'FeatureDetails'
                                        FROM pricingTypeView AS pv
                        
                                        WHERE (
                                                        (@Type = 'M' AND NoOfDays = 30) -- Validate for Type = 'M' using calculated months
                                                        OR (@Type = 'Y' AND NoOfDays = 365) -- Validate for Type = 'Y' using calculated years
														OR pv.PricingName='Free'
                                                        )
                                                        AND pv.ActiveStatus = 'A'
                                                        AND pv.AppId = @AppId
                                                        AND (
                                                        (
                                                                EXISTS (
                                                                SELECT uam.*
                                                                FROM UserAppMap AS uam
                                                                WHERE uam.UserId = @UserId
                                                                        AND uam.AppId = pv.AppId
                                                                        AND uam.PricingId = pv.PricingId
                                                                        --AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
                                                                )
                                                                AND pv.PricingName != 'Free'
                                                        )
                                                        OR (
                                                                pv.PricingName = 'Free'
                                                                AND NOT EXISTS (
                                                                SELECT uam.*
                                                                FROM UserAppMap AS uam
                                                                WHERE uam.UserId = @UserId
                                                                        AND uam.AppId = pv.AppId
                                                                        AND uam.PricingId = pv.PricingId
                                                                        --AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
                                                                )
                                                        )
                                                        OR NOT EXISTS (
                                                                SELECT uam.*
                                                                FROM UserAppMap AS uam
                                                                WHERE uam.UserId = @UserId
                                                                        AND uam.AppId = pv.AppId
                                                                        AND uam.PricingId = pv.PricingId
                                                        )
                                                        )
                                                        OR pv.PricingName = 'Free') AS A WHERE AppId=@AppId
														UNION  
														SELECT TOP 1 * FROM (SELECT '0' AS AppId,'' AS Status ,'FeatureName' As PricingName, '0' As Price,'0' As PricingId,'0' As DisplayPrice,
														'0' AS NetPrice,'0' As PriceTag,'0' As NoOfDays,'' AS PriceTagName,(
                                                                   SELECT f.FeatName,
                                                                                  f.FeatId
                                                                                 
                                                                   FROM Feature AS f
                                                                   LEFT JOIN PricingAppFeatMap AS pm ON pm.FeatId = f.FeatId AND pm.PricingId = pv.PricingId AND pm.ActiveStatus = 'A'
                                                                   --WHERE pm.AppId = @AppId
                                                                   FOR JSON PATH )
                                                            AS 'FeatureDetails'  FROM pricingTypeView AS pv ) AS A ) as A for JSON path )
					
					--SELECT pv.AppId,
					--		CASE
					--			WHEN (
					--				EXISTS (
					--					SELECT uam.*
					--					FROM UserAppMap AS uam
					--					WHERE uam.UserId = @UserId
					--						AND uam.AppId = pv.AppId
					--						AND uam.PricingId = pv.PricingId
					--						AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
					--						AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
					--				)
					--				AND pv.PricingName = 'Free'
					--			) THEN 'Already Used'
					--		  WHEN EXISTS (
					--				   SELECT uam.*
					--				   FROM UserAppMap AS uam
					--				   WHERE uam.UserId = @UserId
					--					   AND uam.AppId = pv.AppId
					--					   AND uam.PricingId = pv.PricingId
					--					   AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
					--					   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
					--			   ) OR EXISTS (
					--				   SELECT uam.*
					--				   FROM UserAppMap AS uam
					--				   WHERE uam.UserId = @UserId
					--					   AND uam.AppId = pv.AppId
					--					   AND uam.PricingId = pv.PricingId
					--					   AND uam.PaymentStatus='S' AND uam.LicenseStatus='A'
					--			   ) THEN 'Extend Pack'
					--			ELSE CASE
					--					WHEN pv.PricingName = 'Free' THEN 'Start Free'
					--					ELSE ''
					--				END
					--		END AS Status,
					--		pv.PricingName,
					--		pv.Price,
					--		pv.PricingId,
					--		ISNULL(pv.DisplayPrice, 0) AS DisplayPrice,
					--		pv.NetPrice,
					--		pv.PriceTag,
					--		pv.NoOfDays,
					--		(SELECT ConfigName FROM ConfigMaster WHERE ConfigId = pv.PriceTag) AS PriceTagName,
					--		(SELECT f.FeatName, f.FeatConstraint FROM Feature AS f WHERE f.FeatId = pm.FeatId FOR JSON PATH) AS FeatureDetails
					--FROM pricingTypeView AS pv
					--INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = pv.PricingId AND pm.AppId = @AppId AND pm.ActiveStatus = 'A'
					--WHERE (
					--		(@Type = 'M' AND NoOfDays <= 30) -- Validate for Type = 'M' using calculated months
					--		OR (@Type = 'Y' AND NoOfDays <= 365) -- Validate for Type = 'Y' using calculated years
					--		)
					--		AND pv.ActiveStatus = 'A'
					--		AND pv.AppId = @AppId
					--		AND (
					--		(
					--			EXISTS (
					--			SELECT uam.*
					--			FROM UserAppMap AS uam
					--			WHERE uam.UserId = @UserId
					--				AND uam.AppId = pv.AppId
					--				AND uam.PricingId = pv.PricingId
					--				--AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
					--			)
					--			AND pv.PricingName != 'Free'
					--		)
					--		OR (
					--			pv.PricingName = 'Free'
					--			AND NOT EXISTS (
					--			SELECT uam.*
					--			FROM UserAppMap AS uam
					--			WHERE uam.UserId = @UserId
					--				AND uam.AppId = pv.AppId
					--				AND uam.PricingId = pv.PricingId
					--				--AND CAST(GETDATE() AS date) BETWEEN CAST(uam.ValidityStart AS date) AND CAST(uam.ValidityEnd AS date)
					--			)
					--		)
					--		OR NOT EXISTS (
					--			SELECT uam.*
					--			FROM UserAppMap AS uam
					--			WHERE uam.UserId = @UserId
					--				AND uam.AppId = pv.AppId
					--				AND uam.PricingId = pv.PricingId
					--		)
					--		)
					--		OR pv.PricingName = 'Free'
					
					
					--SELECT pv.AppId,pv.PricingName,pv.Price,pv.PricingId,ISNULL(pv.DisplayPrice,0)as DisplayPrice ,pv.PriceTag, pv.NoOfDays,
					--		(SELECT ConfigName FROM ConfigMaster as c WHERE c.ConfigId=pv.PriceTag)as PriceTagName,
					--		(select f.FeatName,f.FeatConstraint  from Feature as f where f.FeatId=pm.FeatId for json path) as FeatureDetails
					--			FROM pricingTypeView as pv
					--			INNER JOIN PricingAppFeatMap as pm
					--			ON pm.PricingId=pv.PricingId AND pm.AppId= pv.AppId AND pm.ActiveStatus='A'
					--			--INNER JOIN Feature as f
					--			--ON f.FeatId=pm.FeatId
					--			WHERE
					--			(@Type = 'M' AND NoOfDays <= 30) -- Validate for Type = 'M' using calculated months
					--			OR (@Type = 'Y' AND NoOfDays <= 365) -- Validate for Type = 'Y' using calculated years
					--			AND pv.ActiveStatus = 'A' AND pv.AppId=@AppId 
								
								
								
			   
			--AllNull
			    WHEN @PricingId IS NULL AND @ActiveStatus IS NULL AND @AppId IS NULL  AND @NoOfDays IS  NULL AND @Type IS NULL AND @UserId IS NULL
					THEN (SELECT * 
							FROM pricingTypeView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getUser]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getUser] (@UserId INT=NULL, @ActiveStatus CHAR(1)=NULL,@MobileNo Nvarchar(10)=NULL,@UserType CHAR(1)=NULL)
AS
BEGIN
declare @Roles Nvarchar(MAX)='Super Admin User,Admin,Employee'
SELECT CAST((CASE 
			
			-- UserId
				WHEN @UserId IS NOT NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL AND @UserType IS NULL
					THEN (SELECT uv.UserId,uv.UserType,uv.CompId,uv.BranchId,uv.MobileNo,uv.MailId,uv.UserName,uv.UserImage,uv.CompName,uv.BrName,uv.UserTypeName 
							FROM userView as uv
							WHERE uv.UserId=@UserId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- UserId and ActiveStatus
				WHEN @UserId IS NOT NULL AND @ActiveStatus IS NOT NULL AND @MobileNo IS NULL AND @UserType IS NULL
					THEN (SELECT uv.UserId,uv.UserType,uv.CompId,uv.BranchId,uv.MobileNo,uv.MailId,uv.UserName,uv.UserImage,uv.CompName,uv.BrName,uv.UserTypeName,CASE
							WHEN (uv.Pin IS NOT NULL AND LEN(uv.Pin) !=0) THEN 'Y'
							ELSE 'N'
						END AS Pin,
					CASE
							WHEN (uv.Password IS NOT NULL AND LEN(uv.Password) !=0) THEN 'Y'
							ELSE 'N'
						END AS Password 
							FROM userView as uv
							WHERE uv.UserId=@UserId and ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			
			--ActiveStatus
			    WHEN @UserId IS NULL AND @ActiveStatus IS NOT NULL AND @MobileNo IS NULL AND @UserType IS NULL
					THEN (SELECT * 
							FROM userView
							WHERE ActiveStatus=@ActiveStatus  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--MobileNo
			    WHEN @UserId IS NULL AND @ActiveStatus IS NULL AND @MobileNo IS NOT NULL AND @UserType IS NULL
					THEN (SELECT userView.ActiveStatus,userView.UserId,userView.UserType,userView.CompId,userView.BranchId,
					userView.UserName,userView.UserTypeName,
					--emp.MobileAppAccess,emp.EmpShiftId,emp.RoleId,emp.RoleName, 
					CASE
							WHEN (userView.Pin IS NOT NULL AND LEN(userView.Pin) !=0) THEN 'Y'
							ELSE 'N'
						END AS Pin,
					CASE
							WHEN (userView.Password IS NOT NULL AND LEN(userView.Password) !=0) THEN 'Y'
							ELSE 'N'
						END AS Password,userView.CompName,userView.BrName
							FROM userView as userView
							--left JOIN [Paypre_Retail].[dbo].employeeView AS emp ON emp.UserId=userView.UserId AND emp.ActiveStatus='A'
							WHERE userView.MobileNo=@MobileNo FOR JSON PATH, INCLUDE_NULL_VALUES)

			----UserType
			--	WHEN @UserId IS NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL  AND @UserType IS NOT NULL
			--		THEN (SELECT uv.* 
			--				FROM userView as uv
			--				WHERE uv.UserType=@UserType
			--				  FOR JSON PATH, INCLUDE_NULL_VALUES)
			--UserType
			--E for user get list ->Sadmin role

		
				WHEN @UserId IS NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL  AND @UserType='E'
					THEN (SELECT uv.*
							FROM userView as uv
							WHERE uv.UserTypeName in ('Super Admin User','Admin','Employee')
						  
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- A Admin based data with user id
			WHEN @UserId IS NOT NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL  AND @UserType='A'
					THEN (
							SELECT * FROM userView WHERE UserId IN(
								select Distinct UserId from AppAccess where CompId IN(
								select CompId from AppAccess where UserId=@UserId)) AND UserType='106'
					--SELECT uv.* 
					--		FROM userView as uv
					--		WHERE uv.CompId in (select c.CompId from Company as c where c.UserId=@UserId) AND uv.UserTypeName Not in ('Public','Admin','Super Admin','Super Admin User')
						  
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- A Admin Data
			WHEN @UserId IS NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL  AND @UserType='A'
					THEN (SELECT uv.* 
							FROM userView as uv
							WHERE uv.UserTypeName Not in ('Employee','Super Admin','Super Admin User','Public') 
								AND uv.ActiveStatus='A'
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

							  

			--AllNull
			    WHEN @UserId IS NULL AND @ActiveStatus IS NULL AND @MobileNo IS NULL  AND @UserType IS NULL
					THEN (SELECT * 
							FROM userView
							  FOR JSON PATH, INCLUDE_NULL_VALUES)

				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[getUserAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getUserAppMap] (@UniqueId INT=NULL, @AppId INT=NULL, @UserId INT = NULL,@Type char(1)=NULL,@PaymentStatus Char(1)=NULL)
AS
BEGIN


SELECT CAST((CASE 
			
			-- UniqueId
				WHEN @UniqueId IS NOT NULL  AND @AppId IS NULL AND @UserId IS NULL AND @Type IS NULL AND @PaymentStatus IS NULL
					THEN (SELECT *  
							FROM userAppMapView
							WHERE UniqueId=@UniqueId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- UniqueId and PaymentStatus
				WHEN @UniqueId IS NOT NULL  AND @AppId IS NULL AND @UserId IS NULL AND @Type IS NULL AND @PaymentStatus IS NOT NULL
					THEN (SELECT *  
							FROM userAppMapView
							WHERE UniqueId=@UniqueId AND PaymentStatus=@PaymentStatus FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- AppId
				WHEN @UniqueId IS NULL  AND @AppId IS NOT NULL AND @UserId IS NULL AND @Type IS NULL AND @PaymentStatus IS NULL
					THEN (SELECT * 
							FROM userAppMapView
							WHERE AppId=@AppId  FOR JSON PATH, INCLUDE_NULL_VALUES)
			-- UserId 
				WHEN @UniqueId IS NULL  AND @AppId IS NULL AND @UserId IS NOT NULL AND @Type IS NULL AND @PaymentStatus IS NULL
					THEN (
					SELECT * FROM (
					 SELECT * FROM (
								SELECT DISTINCT  uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName,
								DATEDIFF(DAY, GETDATE(), uav.ValidityEnd) AS RemainingDays,
								ROW_NUMBER() OVER (PARTITION BY UserId,uav.AppId ORDER By uav.UniqueId DESC) AS 'Row'
								FROM userAppMapView as uav
								inner join applicationView as apv on apv.AppId=uav.AppId
								WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
								AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date) 
									)  AS A
								WHERE Row=1
							UNION 
							SELECT * FROM (
									SELECT DISTINCT  uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName,
								DATEDIFF(DAY, GETDATE(), uav.ValidityEnd) AS RemainingDays,
								ROW_NUMBER() OVER (PARTITION BY UserId,uav.AppId ORDER By uav.UniqueId DESC) AS 'Row'
								FROM userAppMapView as uav
								inner join applicationView as apv on apv.AppId=uav.AppId
								WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
																					  AND uav.AppId NOT IN (  SELECT AppId FROM (
								SELECT DISTINCT  uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName,
								DATEDIFF(DAY, GETDATE(), uav.ValidityEnd) AS RemainingDays,
								ROW_NUMBER() OVER (PARTITION BY UserId,uav.AppId ORDER By uav.UniqueId DESC) AS 'Row'
								FROM userAppMapView as uav
								inner join applicationView as apv on apv.AppId=uav.AppId
								WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
								AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date) 
									)  AS A
								WHERE Row=1)
								--AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date) 
								)  AS A
								WHERE Row=1 ) AS A order by A.RemainingDays
					--SELECT uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName
					--		FROM userAppMapView as uav
					--		inner join applicationView as apv on apv.AppId=uav.AppId

					--		WHERE uav.UserId =@UserId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A' AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date)
				
						--SELECT * FROM (
						--		SELECT DISTINCT  uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName,
						--		DATEDIFF(DAY, GETDATE(), uav.ValidityEnd) AS RemainingDays,
						--		ROW_NUMBER() OVER (PARTITION BY UserId,uav.PricingId ORDER By uav.UniqueId DESC) AS 'Row'
						--		FROM userAppMapView as uav
						--		inner join applicationView as apv on apv.AppId=uav.AppId
						--		WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
						--		--AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date) 
						--		)  AS A
						--		WHERE Row=1 order by RemainingDays DESC

					   ---changed Code ---
					   --SELECT * FROM (
								--SELECT DISTINCT  uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName,
								--DATEDIFF(DAY, GETDATE(), uav.ValidityEnd) AS RemainingDays,
								--ROW_NUMBER() OVER (PARTITION BY UserId,uav.PricingId ORDER By uav.UniqueId DESC) AS 'Row'
								--FROM userAppMapView as uav
								--inner join applicationView as apv on apv.AppId=uav.AppId
								--WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
								--AND CAST(GETDATE() AS date) BETWEEN CAST(uav.ValidityStart AS date) AND CAST(uav.ValidityEnd AS date) 
								--)  AS A
								--WHERE Row=1 order by RemainingDays DESC

							FOR JSON PATH, INCLUDE_NULL_VALUES)

			--UserId & type=P (payment)
			 WHEN @UniqueId IS NULL  AND @AppId IS NULL AND @UserId IS NOT NULL AND @Type='P' AND @PaymentStatus IS NULL
				THEN(SELECT uav.*,apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName
								FROM userAppMapView as uav
								inner join applicationView as apv on apv.AppId=uav.AppId
								WHERE uav.UserId=@UserId AND apv.AppId=uav.AppId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
								ORDER BY uav.PurDate DESC
								FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- UserId AND Type to get user based sub catergory
				WHEN @UniqueId IS NULL  AND @AppId IS NULL AND @UserId IS NOT NULL AND @Type='A' AND @PaymentStatus IS NULL
					THEN (SELECT apv.SubCateId as ConfigId,apv.SubCategoryName as ConfigName
							FROM userAppMapView as uav
							inner join applicationView as apv on apv.AppId=uav.AppId

							WHERE uav.UserId =@UserId Group by  apv.SubCateId,apv.SubCategoryName FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			--UserId && AppId
				WHEN @UniqueId IS NULL  AND @AppId IS NOT NULL  AND @UserId IS NOT NULL AND @Type IS NULL AND @PaymentStatus IS NULL
					THEN(SELECT TOP 1*
								FROM ( 
									SELECT uav.*,
										CASE
											WHEN GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd AND uav.PaymentStatus='S' AND uav.LicenseStatus='A'
											THEN 'Y'
											ELSE 'N'
										END AS Status,
										ISNULL((SELECT COUNT(a.CompId) FROM AppAccess AS a WHERE a.UserId=@UserId AND a.AppId = @AppId AND a.ActiveStatus='A' AND a.CompId IS NOT NULL GROUP BY a.AppId),0) AS CompanyCount,
										ISNULL((SELECT COUNT(a.UserId) FROM AppAccess AS a WHERE a.CompId IN (SELECT  a.CompId FROM AppAccess AS a WHERE a.UserId = @UserId AND a.CompId IS NOT NULL)AND a.AppId = @AppId AND a.ActiveStatus='A'),0) AS UserCount,
										ISNULL((SELECT f.FeatName, f.FeatConstraint
											FROM Feature AS f
											INNER JOIN PricingType as p ON p.PricingId=uav.PricingId AND p.AppId=uav.AppId
											INNER JOIN PricingAppFeatMap AS pm ON pm.PricingId = p.PricingId AND pm.AppId = p.AppId AND pm.ActiveStatus = 'A'
											WHERE f.FeatId = pm.FeatId 								
											FOR JSON PATH),'[]') AS 'FeatureDetails',
										ROW_NUMBER() OVER (PARTITION BY UserId, uav.PricingId ORDER BY uav.UniqueId DESC) AS Row
									FROM userAppMapView AS uav
									WHERE uav.AppId = @AppId AND uav.UserId = @UserId AND uav.PaymentStatus='S' AND uav.LicenseStatus='A' AND GETDATE() BETWEEN uav.ValidityStart AND uav.ValidityEnd
								) AS A 
								WHERE Row = 1
								ORDER BY UniqueId DESC FOR JSON PATH, INCLUDE_NULL_VALUES)



			-- AllNull
				WHEN @UniqueId IS NULL  AND @AppId IS NULL  AND @UserId IS NULL AND @Type IS NULL AND @PaymentStatus IS NULL
					THEN (SELECT u.* 
							FROM userAppMapView as u
							WHERE u.PaymentStatus='S' AND u.LicenseStatus='A' AND CAST(GETDATE() AS date) BETWEEN CAST(u.ValidityStart AS date) AND CAST(u.ValidityEnd AS date) 
							  FOR JSON PATH, INCLUDE_NULL_VALUES)
			
				ELSE
					NULL

					END)AS NVARCHAR(MAX)) AS mainData
END



GO
/****** Object:  StoredProcedure [dbo].[gmailLogin]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[gmailLogin](@UserName NVARCHAR(20)=NULL)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	DECLARE @tempVar VARCHAR(100);
	BEGIN TRY
		SET @tempVar=CAST(@UserName AS NVARCHAR(10))
	END TRY
	BEGIN CATCH
		SET @tempVar=-1
	END CATCH
	IF NOT EXISTS(SELECT * FROM [User] WHERE (UserName = @UserName OR MobileNo = @tempVar))
		BEGIN
			SELECT CAST((CASE 

			-- Username
				WHEN EXISTS(SELECT * FROM [User] WHERE (UserName = @UserName OR MobileNo = @tempVar))
					THEN (SELECT UserName,UserType,MobileNo,MailId,UserId,BranchId,CompId 
							FROM [User] 
							WHERE (UserName = @UserName OR MobileNo = @tempVar) FOR JSON PATH)	

				ELSE
					NULL

					END)as nvarchar(max)) AS mainData
		END
	ELSE
		BEGIN
			INSERT INTO [User](UserType,MobileNo,MailId,UserName,Password,ActiveStatus ,CreatedBy, CreatedDate) 
			VALUES ('P','0123456789',@UserName,@UserName,'123','A',1, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END

END
GO
/****** Object:  StoredProcedure [dbo].[postAdminTax]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postAdminTax](
								@TaxName NVARCHAR(30),
								@TaxPercentage DECIMAL(6,2)=NULL,
								@EffectiveFrom DATE,
								@Reference NVARCHAR(150)=NULL,
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM AdminTax WHERE EffectiveFrom=@EffectiveFrom AND TaxName=@TaxName)
		BEGIN
			IF NOT EXISTS(SELECT * FROM AdminTax WHERE TaxName=@TaxName )
				BEGIN
                  INSERT INTO AdminTax(TaxName,TaxPercentage,EffectiveFrom,Reference,ActiveStatus,CreatedBy,CreatedDate)
					VALUES(@TaxName,@TaxPercentage,@EffectiveFrom,@Reference,'A',@CreatedBy,GETDATE())
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
				END
			ELSE
                  BEGIN 
					  UPDATE AdminTax  SET EffectiveTill=CAST(DATEADD(DAY,-1,@EffectiveFrom) as Date),ActiveStatus='D' 
							WHERE TaxName=@TaxName AND EffectiveTill IS NULL
					  IF @@ROWCOUNT >0
						   INSERT INTO AdminTax(TaxName,TaxPercentage,EffectiveFrom,Reference,ActiveStatus,CreatedBy,CreatedDate)
									VALUES(@TaxName,@TaxPercentage,@EffectiveFrom,@Reference,'A',@CreatedBy,GETDATE())
						  IF @@ROWCOUNT>0
							BEGIN
								SELECT 'Data Added Successfully',1
								IF @@TRANCOUNT > 0
									BEGIN
										COMMIT
									END
							END

						 ELSE
							BEGIN
								SELECT 'Data Not Added',0
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
                  END
			
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists',2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END

IF @@TRANCOUNT>0
	BEGIN
		COMMIT
	END

END


GO
/****** Object:  StoredProcedure [dbo].[postAppAccess]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[postAppAccess]( @UserId INT,@CreatedBy INT,@ModuleDetails NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @subTab TABLE (AppId INT,
						  CompId INT,
						  BranchId INT,
						  AppAccessId INT
						  )
	DECLARE @subUserTab TABLE (AppId INT,
						  CompId INT,
						  BranchId INT
						  )
	BEGIN TRAN
	    IF EXISTS(SELECT * FROM AppAccess WHERE UserId = @UserId)
			BEGIN
				INSERT INTO @subTab(AppId,CompId,BranchId,AppAccessId)
					SELECT AppId,CompId,BranchId,AppAccessId
						FROM AppAccess
						WHERE UserId=@UserId
				INSERT INTO @subUserTab(AppId,CompId,BranchId)
					SELECT AppId,CompId,BranchId
						FROM OPENJSON (@ModuleDetails)
						WITH (
							AppId INT '$.AppId',
							CompId INT '$.CompId',
							BranchId INT '$.BranchId'
						)
			
			--Insert New User
				INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,ActiveStatus,CreatedBy,CreatedDate)
					SELECT @UserId,sut.AppId,sut.CompId,sut.BranchId,'A',@CreatedBy,GETDATE()
						FROM @subUserTab AS sut
						WHERE NOT EXISTS(SELECT st.*
											FROM @subTab AS st
											WHERE st.AppId=sut.AppId
											AND st.CompId=sut.CompId
											AND st.BranchId=sut.BranchId)
			--Update Exist User
				UPDATE AppAccess SET ActiveStatus='D' WHERE AppId IN (SELECT st.AppId
																		FROM @subTab AS st
																		WHERE NOT EXISTS(SELECT sut.*
																							FROM @subUserTab AS sut
																							WHERE sut.AppId=st.AppId
																							AND sut.CompId=st.CompId
																							AND sut.BranchId=st.BranchId))
													AND CompId IN (SELECT st.CompId
																		FROM @subTab AS st
																		WHERE NOT EXISTS(SELECT sut.*
																							FROM @subUserTab AS sut
																							WHERE sut.AppId=st.AppId
																							AND sut.CompId=st.CompId
																							AND sut.BranchId=st.BranchId))
													AND BranchId IN (SELECT st.BranchId
																		FROM @subTab AS st
																		WHERE NOT EXISTS(SELECT sut.*
																							FROM @subUserTab AS sut
																							WHERE sut.AppId=st.AppId
																							AND sut.CompId=st.CompId
																							AND sut.BranchId=st.BranchId))
													AND UserId=@UserId
					UPDATE AppAccess SET ActiveStatus='A' WHERE AppAccessId IN (SELECT AppAccessId FROM @subTab AS st
						INNER JOIN @subUserTab As sut
						ON st.AppId=sut.AppId
						AND st.CompId=sut.CompId
						AND st.BranchId=sut.BranchId)

				IF @@ROWCOUNT > 0
					BEGIN
						SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					
					END
				ELSE
					BEGIN
						SELECT 'Data Not Added', 0,''
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END

								
			END
		ELSE
			BEGIN
				INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,ActiveStatus,CreatedBy,CreatedDate) 
				SELECT @UserId,AppId,CompId,BranchId,'A',@CreatedBy,GETDATE()
						FROM OPENJSON (@ModuleDetails)
						WITH (
							AppId INT '$.AppId',
							CompId INT '$.CompId',
							BranchId INT '$.BranchId'
						)
				IF @@ROWCOUNT > 0
					BEGIN
						SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					
					END
				ELSE
					BEGIN
						SELECT 'Data Not Added', 0,''
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END 
			END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postAppAccessBackup]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[postAppAccessBackup]( @UserId INT,@CreatedBy INT,@ModuleDetails NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	    DELETE AppAccess WHERE UserId=@UserId
		BEGIN
			INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,CreatedBy,CreatedDate) 
			SELECT @UserId,AppId,CompId,BranchId,@CreatedBy,GETDATE()
					FROM OPENJSON (@ModuleDetails)
					WITH (
						AppId INT '$.AppId',
						CompId INT '$.CompId',
						BranchId INT '$.BranchId'
					)
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0,''
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postAppImage]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postAppImage](@AppId INT,
										@ImageType CHAR(1),
										@ImageName NVARCHAR(50),
										@ImageLink NVARCHAR(150),
										@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	
	INSERT INTO AppImage(AppId,ImageType,ImageName,ImageLink, ActiveStatus ,CreatedBy, CreatedDate) 
		VALUES ( @AppId,@ImageType,@ImageName,@ImageLink, 'A',@CreatedBy, GETDATE())
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Added Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
					
		END
	ELSE
		BEGIN
			SELECT 'Data Not Added', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postApplication]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postApplication] (@AppName NVARCHAR(50),
								@AppDescription NVARCHAR(150),
								@AppLogo NVARCHAR(150)=NULL,
								@CateId INT,
								@SubCateId INT,
								@BannerImage NVARCHAR(150),
								@CreatedBy INT
							)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	
	IF NOT EXISTS(SELECT * FROM Application WHERE AppName=@AppName AND CateId=@CateId AND SubCateId=@SubCateId)
		BEGIN
			INSERT INTO Application (AppName,AppDescription,AppLogo,CateId,SubCateId,BannerImage,ActiveStatus,CreatedBy,CreatedDate)
				VALUES(@AppName,@AppDescription,@AppLogo,@CateId,@SubCateId,@BannerImage,'A',@CreatedBy,GETDATE())
			IF @@ROWCOUNT >0
				BEGIN
					SELECT 'Data Added Successfully',1
					IF @@TRANCOUNT >0
						BEGIN
							COMMIT
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					IF @@TRANCOUNT >0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postAppMenu]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postAppMenu]( @AppId INT,
								@MenuName NVARCHAR(20),
								@Level CHAR(1),
								@Level1Id INT,
								@Level2Id INT,
								
								@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM AppMenu WHERE MenuName = @MenuName AND AppId=@AppId)
		BEGIN
			INSERT INTO AppMenu(AppId,MenuName,Level,Level1Id,Level2Id, ActiveStatus ,CreatedBy, CreatedDate) VALUES ( @AppId,@MenuName,@Level,@Level1Id,@Level2Id, 'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postBranch]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postBranch](@CompId INT,
							@BrName NVARCHAR(50),
							@BrShName NVARCHAR(20),
							@BrGSTIN NVARCHAR(15)=NULL,
							@BrInCharge NVARCHAR(15),
							@BrMobile NVARCHAR(10)=NULL,
							@BrEmail NVARCHAR(50)=NULL,
							@BrRegnNo NVARCHAR(50)=NULL,
							@WorkingFrom TIME(7)=NULL,
							@WorkingTo TIME(7)=NULL,
							@CreatedBy INT,
							@Address1 NVARCHAR(100),
							@Address2 NVARCHAR(100)=NULL,
							@Zip INT,
							@City NVARCHAR(50),
							@Dist NVARCHAR(50),
							@State NVARCHAR(50),
							@Latitude DECIMAL(12,8)=NULL,
							@Longitude  DECIMAL(12,8)=NULL,
							@AppId INT,
							@UserId INT)	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @BranchId INT;
	BEGIN TRAN
	INSERT INTO CommonAddress (Address1,Address2,Zip,City,Dist,State,Latitude,Longitude,ActiveStatus,CreatedBy, CreatedDate)
		VALUES(@Address1,@Address2,@Zip,@City,@Dist,@State,@Latitude,@Longitude,'A',@CreatedBy, GETDATE()) 
	IF @@ROWCOUNT > 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Branch WHERE BrName=@BrName AND CompId=@CompId)
				BEGIN
					INSERT INTO Branch (CompId,BrName,BrShName,BrAddId,BrGSTIN,BrInCharge,BrMobile,BrEmail,BrRegnNo,WorkingFrom,WorkingTo,ActiveStatus,CreatedBy,CreatedDate)
					VALUES(@CompId,@BrName,@BrShName,(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),@BrGSTIN,@BrInCharge,@BrMobile,@BrEmail,@BrRegnNo,@WorkingFrom,@WorkingTo,'A',@CreatedBy,GETDATE())
					IF @@ROWCOUNT > 0
					 BEGIN
						SET @BranchId= (SELECT BrId from Branch WHERE CompId =@CompId  AND BrName=@BrName)
						IF EXISTS (SELECT * FROM AppAccess WHERE AppId=@AppId AND CompId=@CompId AND BranchId IS NULL)
							BEGIN	
								UPDATE AppAccess SET BranchId = @BranchId WHERE AppId=@AppId AND CompId=@CompId AND BranchId IS NULL
								IF @@ROWCOUNT > 0
									BEGIN
										SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo)as UserName FROM [User] as u WHERE u.UserId=@UserId)
										IF @@TRANCOUNT > 0
											BEGIN
												COMMIT
											END
									END
								ELSE
									BEGIN
										SELECT 'Data Not Added', 0 ,''
										IF @@TRANCOUNT > 0
											BEGIN
												ROLLBACK
											END
									END
							END
						ELSE
							BEGIN
								INSERT INTO AppAccess (UserId, AppId, CompId, BranchId,ActiveStatus, CreatedBy,CreatedDate) 
								  VALUES (@UserId, @AppId, @CompId, @BranchId, @CreatedBy,'A',GETDATE())
								IF @@ROWCOUNT > 0
									BEGIN
										SELECT 'Data Added Successfully', 1,(SELECT ISNULL(u.UserName,u.MobileNo)as UserName FROM [User] as u WHERE u.UserId=@UserId)
										IF @@TRANCOUNT > 0
											BEGIN
												COMMIT
											END
									END
								ELSE
									BEGIN
										SELECT 'Data Not Added', 0,''
										IF @@TRANCOUNT > 0
											BEGIN
												ROLLBACK
											END
									END
							END
						END

					ELSE
						BEGIN
							SELECT 'Data Not Added', 0,''
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
		
				END
			ELSE
				BEGIN
					SELECT 'Data Already Exists', 2,''
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Added', 0,''
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END

END
GO
/****** Object:  StoredProcedure [dbo].[postBranchAppAccess]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[postBranchAppAccess]( @UserId INT,@CreatedBy INT,@ModuleDetails NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @subTab TABLE (AppId INT,
						  CompId INT,
						  BranchId INT,
						  AppAccessId INT
						  )
	DECLARE @subUserTab TABLE (AppId INT,
						  CompId INT,
						  BranchId INT
						  )
	BEGIN TRAN
	    DECLARE @BranchId INT;
		SELECT TOP 1 @BranchId= BranchId
					FROM OPENJSON (@ModuleDetails)
					WITH (
						AppId INT '$.AppId',
						CompId INT '$.CompId',
						BranchId INT '$.BranchId'
					)
		IF EXISTS(SELECT * FROM AppAccess WHERE UserId=@UserId AND BranchId=@BranchId)
			BEGIN
				INSERT INTO @subTab(AppId,CompId,BranchId,AppAccessId)
					SELECT AppId,CompId,BranchId,AppAccessId
						FROM AppAccess
						WHERE UserId=@UserId
						AND BranchId=@BranchId
				INSERT INTO @subUserTab(AppId,CompId,BranchId)
					SELECT AppId,CompId,BranchId
						FROM OPENJSON (@ModuleDetails)
						WITH (
							AppId INT '$.AppId',
							CompId INT '$.CompId',
							BranchId INT '$.BranchId'
						)
			--Insert New User
				INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,ActiveStatus,CreatedBy,CreatedDate)
					SELECT @UserId,sut.AppId,sut.CompId,sut.BranchId,'A',@CreatedBy,GETDATE()
						FROM @subUserTab AS sut
						WHERE NOT EXISTS(SELECT st.*
											FROM @subTab AS st
											WHERE st.AppId=sut.AppId
											AND st.CompId=sut.CompId
											AND st.BranchId=sut.BranchId)
			--Update Exist User
				UPDATE AppAccess SET ActiveStatus='D' WHERE AppId IN (SELECT st.AppId
																		FROM @subTab AS st
																		WHERE NOT EXISTS(SELECT sut.*
																							FROM @subUserTab AS sut
																							WHERE sut.AppId=st.AppId
																							AND sut.CompId=st.CompId
																							AND sut.BranchId=st.BranchId))
													AND CompId IN (SELECT st.CompId
																		FROM @subTab AS st
																		WHERE NOT EXISTS(SELECT sut.*
																							FROM @subUserTab AS sut
																							WHERE sut.AppId=st.AppId
																							AND sut.CompId=st.CompId
																							AND sut.BranchId=st.BranchId))
														AND UserId=@UserId
														AND BranchId=@BranchId
				UPDATE AppAccess SET ActiveStatus='A' WHERE AppAccessId IN (SELECT AppAccessId FROM @subTab AS st
						INNER JOIN @subUserTab As sut
						ON st.AppId=sut.AppId
						AND st.CompId=sut.CompId
						AND st.BranchId=sut.BranchId)

				IF @@ROWCOUNT > 0
					BEGIN
						SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					
					END
				ELSE
					BEGIN
						SELECT 'Data Not Added', 0,''
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
				
			END
		ELSE
			BEGIN
				INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,ActiveStatus,CreatedBy,CreatedDate) 
				SELECT @UserId,AppId,CompId,BranchId,'A',@CreatedBy,GETDATE()
						FROM OPENJSON (@ModuleDetails)
						WITH (
							AppId INT '$.AppId',
							CompId INT '$.CompId',
							BranchId INT '$.BranchId'
						)
				IF @@ROWCOUNT > 0
					BEGIN
						SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					
					END
				ELSE
					BEGIN
						SELECT 'Data Not Added', 0,''
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postBranchAppAccessBackup]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[postBranchAppAccessBackup]( @UserId INT,@CreatedBy INT,@ModuleDetails NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	    DECLARE @BranchId INT;
		SELECT TOP 1 @BranchId= BranchId
					FROM OPENJSON (@ModuleDetails)
					WITH (
						AppId INT '$.AppId',
						CompId INT '$.CompId',
						BranchId INT '$.BranchId'
					)
		DELETE AppAccess WHERE UserId=@UserId AND BranchId=@BranchId
		BEGIN
			INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,CreatedBy,CreatedDate) 
			SELECT @UserId,AppId,CompId,BranchId,@CreatedBy,GETDATE()
					FROM OPENJSON (@ModuleDetails)
					WITH (
						AppId INT '$.AppId',
						CompId INT '$.CompId',
						BranchId INT '$.BranchId'
					)
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1 ,(SELECT ISNULL(u.UserName,u.MobileNo) FROM [User] as u WHERE u.UserId=@UserId)
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0,''
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postBulkUpload]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postBulkUpload](@configMasterDetailsJson NVARCHAR(max))
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @subTypeId int,
									@subConfigName Nvarchar(50),
									@subAlphaNumFld Nvarchar(20)=NULL,
									@subNumFld DECIMAL(10,3)=NULL,
									@subSmallIcon Nvarchar(150)=NULL;
									--@subCreatedBy INT;

	DECLARE @configMasterDetailsTab TABLE (TypeId int,
										 ConfigName Nvarchar(50),
										 AlphaNumFld Nvarchar(20),
										 NumFld DECIMAL(10,3),
										 SmallIcon Nvarchar(150)
										 --CreatedBy INT
										 )
	BEGIN TRAN
						 
	INSERT INTO @configMasterDetailsTab SELECT TypeId,ConfigName,AlphaNumFld,NumFld,SmallIcon
			FROM OPENJSON (@configMasterDetailsJson)
			WITH( TypeId int '$.TypeId',
				ConfigName Nvarchar(50) '$.ConfigName',
				AlphaNumFld Nvarchar(20) '$.AlphaNumFld',
				NumFld DECIMAL(10,3) '$.NumFld',
				SmallIcon Nvarchar(150) '$.SmallIcon')
	IF @@ROWCOUNT > 0
		BEGIN
			DECLARE configMasterCursor CURSOR FAST_FORWARD FOR
			SELECT * FROM @configMasterDetailsTab
			OPEN configMasterCursor
			FETCH NEXT FROM configMasterCursor INTO @subTypeId,@subConfigName,@subAlphaNumFld,@subNumFld,@subSmallIcon
			WHILE @@FETCH_STATUS = 0
				BEGIN
				IF NOT EXISTS (SELECT * FROM ConfigMaster WHERE TypeId=@subTypeId and ConfigName=@subConfigName )
					BEGIN
						INSERT INTO ConfigMaster(TypeId,ConfigName,AlphaNumFld,NumFld,SmallIcon,ActiveStatus,CreatedBy,CreatedDate) 
							VALUES (@subTypeId, @subConfigName, @subAlphaNumFld, @subNumFld, @subSmallIcon,'A',1, GETDATE())
						IF @@ROWCOUNT = 0
							BEGIN
								SELECT 'Data Not Added', 0
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
					END
				FETCH NEXT FROM configMasterCursor INTO @subTypeId,@subConfigName,@subAlphaNumFld,@subNumFld,@subSmallIcon
				END
				
				CLOSE configMasterCursor
				DEALLOCATE configMasterCursor
				IF @@TRANCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully',1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
				END
				
		END

	ELSE
		BEGIN
			SELECT 'Data Not Added', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
					
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postCarousel]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postCarousel](@ScreenId INT,@Carousel NVARCHAR(150),@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Carousel WHERE ScreenId = @ScreenId AND Carousel=@Carousel)
		BEGIN
			INSERT INTO Carousel(ScreenId,Carousel,ActiveStatus, CreatedBy, CreatedDate) VALUES ( @ScreenId,@Carousel,'A', @CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postCompany]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[postCompany](@CompName NVARCHAR(50),
									@CompShName NVARCHAR(20),
									@BusiBrief NVARCHAR(150) =NULL,
									@CompLogo NVARCHAR(150) =NULL,
									@CompGSTIN NVARCHAR(15) =NULL,
									@Proprietor NVARCHAR(20),
									@CompPOC NVARCHAR(15) =NULL,
									@CompMobile NVARCHAR(10) =NULL,
									@CompEmail NVARCHAR(50)=NULL,
									@CompRegnNo NVARCHAR(20)=NULL,
									@CreatedBy INT,
									@Address1 NVARCHAR(100),
									@Address2 NVARCHAR(100)=NULL,
									@Zip INT,
									@City NVARCHAR(50),
									@Dist NVARCHAR(50),
									@State NVARCHAR(50),
									@Latitude DECIMAL(12,8)=NULL,
									@Longitude  DECIMAL(12,8)=NULL,
									@UserId INT=NULL,
									@AppId INT=NULL)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @companyId INT;
	DECLARE @BranchId INT;
	BEGIN TRAN

	IF @Address1 IS NOT NULL AND @Zip IS NOT NULL AND @City IS NOT NULL AND @Dist IS NOT NULL AND @State IS NOT NULL
		BEGIN
			INSERT INTO CommonAddress (Address1,Address2,Zip,City,Dist,State,Latitude,Longitude,ActiveStatus,CreatedBy, CreatedDate)
					VALUES(@Address1,@Address2,@Zip,@City,@Dist,@State,@Latitude,@Longitude,'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					IF NOT EXISTS(SELECT * FROM Company WHERE CompName = @CompName)
						BEGIN
							INSERT INTO Company(CompName,CompShName,BusiBrief,CompLogo,CompAddId,CompGSTIN,Proprietor,CompPOC,CompMobile,CompEmail,CompRegnNo, ActiveStatus ,CreatedBy, CreatedDate) 
									VALUES (@CompName,@CompShName,@BusiBrief,@CompLogo,(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),@CompGSTIN,@Proprietor,@CompPOC,@CompMobile,@CompEmail,@CompRegnNo, 'A',@CreatedBy, GETDATE())
							IF @@ROWCOUNT > 0
								BEGIN
									SET @companyId = (SELECT CompId from Company WHERE CompName=@CompName)
									INSERT INTO Branch (CompId,BrName,BrShName,BrAddId,BrGSTIN,BrInCharge,BrMobile,BrEmail,BrRegnNo,ActiveStatus,CreatedBy,CreatedDate)
									VALUES(@companyId,@CompName,@CompShName,(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),@CompGSTIN,@Proprietor,@CompMobile,@CompEmail,@CompRegnNo,'A',@CreatedBy,GETDATE())
									IF @@ROWCOUNT > 0								
										 BEGIN
											 SET @BranchId = (SELECT BrId from Branch WHERE BrName=@CompName)
											 INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,CreatedBy,CreatedDate,ActiveStatus)
											 VALUES(@UserId,@AppId,@companyId,@BranchId,@CreatedBy,GETDATE(),'A')
											 IF @@ROWCOUNT > 0
												 BEGIN
														SELECT 'Data Added Successfully', 1, (SELECT ISNULL(u.UserName,u.MobileNo)as UserName FROM [User] as u WHERE u.UserId=@UserId)
														IF @@TRANCOUNT > 0
															BEGIN
																COMMIT
															END
													END
												ELSE
													BEGIN
														SELECT 'Data Not Added', 0,''
														IF @@TRANCOUNT > 0
															BEGIN
																ROLLBACK
															END
													END
										  END
									 ELSE
										BEGIN
											SELECT 'Data Not Added', 0,''
											IF @@TRANCOUNT > 0
												BEGIN
													ROLLBACK
												END
										END
								 END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0,''
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END
								
						END
					ELSE
						BEGIN
							SELECT 'Data Already Exists', 2,''
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END

				END

		END
		ELSE
			BEGIN
				IF NOT EXISTS(SELECT * FROM Company WHERE CompName = @CompName)
						BEGIN
							INSERT INTO Company(CompName,CompShName,BusiBrief,CompLogo,CompGSTIN,Proprietor,CompPOC,CompMobile,CompEmail,CompRegnNo, ActiveStatus ,CreatedBy, CreatedDate) 
									VALUES (@CompName,@CompShName,@BusiBrief,@CompLogo,@CompGSTIN,@Proprietor,@CompPOC,@CompMobile,@CompEmail,@CompRegnNo, 'A',@CreatedBy, GETDATE())
							IF @@ROWCOUNT > 0
								BEGIN
									SET @companyId = (SELECT CompId from Company WHERE CompName=@CompName)
									INSERT INTO Branch (CompId,BrName,BrShName,BrGSTIN,BrInCharge,BrMobile,BrEmail,BrRegnNo,ActiveStatus,CreatedBy,CreatedDate)
											VALUES(@companyId,@CompName,@CompShName,@CompGSTIN,@Proprietor,@CompMobile,@CompEmail,@CompRegnNo,'A',@CreatedBy,GETDATE())
									IF @@ROWCOUNT > 0							
										 BEGIN
											 SET @BranchId = (SELECT BrId from Branch WHERE BrName=@CompName)
											 INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,CreatedBy,CreatedDate,ActiveStatus)
											 VALUES(@UserId,@AppId,@companyId,@BranchId,@CreatedBy,GETDATE(),'A')
											 IF @@ROWCOUNT > 0
												 BEGIN
														SELECT 'Data Added Successfully', 1,(SELECT ISNULL(u.UserName,u.MobileNo)as UserName FROM [User] as u WHERE u.UserId=@UserId)
														IF @@TRANCOUNT > 0
															BEGIN
																COMMIT
															END
													END
												ELSE
													BEGIN
														SELECT 'Data Not Added', 0,''
														IF @@TRANCOUNT > 0
															BEGIN
																ROLLBACK
															END
													END
										  END
									  ELSE
										BEGIN
											SELECT 'Data Not Added', 0,''
											IF @@TRANCOUNT > 0
												BEGIN
													ROLLBACK
												END
										 END
									END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0,''
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END
								
						END
					ELSE
						BEGIN
							SELECT 'Data Already Exists', 2,''
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
			END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postCompanyAlt]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postCompanyAlt](@CompName NVARCHAR(50),
									@CompShName NVARCHAR(20),
									@BusiBrief NVARCHAR(150) =NULL,
									@CompLogo NVARCHAR(150) =NULL,
									@CompGSTIN NVARCHAR(15) =NULL,
									@Proprietor NVARCHAR(20),
									@CompPOC NVARCHAR(15) =NULL,
									@CompMobile NVARCHAR(10) =NULL,
									@CompEmail NVARCHAR(50)=NULL,
									@CompRegnNo NVARCHAR(20)=NULL,
									@CreatedBy INT,
									@Address1 NVARCHAR(100),
									@Address2 NVARCHAR(100)=NULL,
									@Zip INT,
									@City NVARCHAR(50),
									@Dist NVARCHAR(50),
									@State NVARCHAR(50),
									@Latitude DECIMAL(12,8)=NULL,
									@Longitude  DECIMAL(12,8)=NULL,
									@UserId INT=NULL)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN

	IF @Address1 IS NOT NULL AND @Zip IS NOT NULL AND @City IS NOT NULL AND @Dist IS NOT NULL AND @State IS NOT NULL
		BEGIN
			INSERT INTO CommonAddress (Address1,Address2,Zip,City,Dist,State,Latitude,Longitude,ActiveStatus,CreatedBy, CreatedDate)
					VALUES(@Address1,@Address2,@Zip,@City,@Dist,@State,@Latitude,@Longitude,'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					IF NOT EXISTS(SELECT * FROM Company WHERE CompName = @CompName)
						BEGIN
							INSERT INTO Company(CompName,CompShName,BusiBrief,CompLogo,CompAddId,CompGSTIN,Proprietor,CompPOC,CompMobile,CompEmail,CompRegnNo, ActiveStatus ,CreatedBy, CreatedDate, UserId) 
									VALUES (@CompName,@CompShName,@BusiBrief,@CompLogo,(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),@CompGSTIN,@Proprietor,@CompPOC,@CompMobile,@CompEmail,@CompRegnNo, 'A',@CreatedBy, GETDATE(), @UserId)
							IF @@ROWCOUNT > 0
								BEGIN
									SELECT 'Data Added Successfully', 1
									IF @@TRANCOUNT > 0
										BEGIN
											COMMIT
										END
								END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END
						END
					ELSE
						BEGIN
							SELECT 'Data Already Exists', 2
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END

				END

		END
		ELSE
			BEGIN
				IF NOT EXISTS(SELECT * FROM Company WHERE CompName = @CompName)
						BEGIN
							INSERT INTO Company(CompName,CompShName,BusiBrief,CompLogo,CompGSTIN,Proprietor,CompPOC,CompMobile,CompEmail,CompRegnNo, ActiveStatus ,CreatedBy, CreatedDate, UserId) 
									VALUES (@CompName,@CompShName,@BusiBrief,@CompLogo,@CompGSTIN,@Proprietor,@CompPOC,@CompMobile,@CompEmail,@CompRegnNo, 'A',@CreatedBy, GETDATE(), @UserId)
							IF @@ROWCOUNT > 0
								BEGIN
									SELECT 'Data Added Successfully', 1
									IF @@TRANCOUNT > 0
										BEGIN
											COMMIT
										END
								END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END
						END
					ELSE
						BEGIN
							SELECT 'Data Already Exists', 2
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
			END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postCompAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postCompAppMap]( @CompId INT,
								@BranchId INT,
								@AppId INT,
								@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM CompAppMap WHERE CompId = @CompId AND BranchId =@BranchId AND AppId=@AppId)
		BEGIN
			INSERT INTO CompAppMap(CompId,BranchId,AppId, ActiveStatus ,CreatedBy, CreatedDate) 
					VALUES ( @CompId,@BranchId,@AppId, 'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postConfigMaster]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postConfigMaster](@TypeId INT,
								  @ConfigName NVARCHAR(50),
								  @AlphaNumFld NVARCHAR(20) = NULL,
								  @NumFld DECIMAL(10,3) = NULL,
								  @SmallIcon NVARCHAR(150) = NULL,
								  @CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigMaster WHERE TypeId = @TypeId AND ConfigName=@ConfigName)
		BEGIN
			INSERT INTO ConfigMaster (TypeId,ConfigName,AlphaNumFld,NumFld,SmallIcon,ActiveStatus,CreatedBy,CreatedDate)
				VALUES(@TypeId,@ConfigName,@AlphaNumFld,@NumFld,@SmallIcon,'A',@CreatedBy,GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postConfigType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------Procedures------------------------

CREATE PROCEDURE [dbo].[postConfigType]( @TypeName NVARCHAR(50),
								@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigType WHERE TypeName = @TypeName)
		BEGIN
			INSERT INTO ConfigType(TypeName, ActiveStatus ,CreatedBy, CreatedDate) VALUES ( @TypeName, 'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postCurrency]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postCurrency](@CurrName NVARCHAR(50),@CurrShName  NVARCHAR(3),@ConvRate FLOAT, @CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Currency WHERE CurrName=@CurrName)
		BEGIN
			INSERT INTO Currency(CurrName,CurrShName,ConvRate,ActiveStatus, CreatedBy, CreatedDate) VALUES ( @CurrName,@CurrShName,@ConvRate,'A', @CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postFeature]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postFeature]( @FeatCat INT,
										@FeatName NVARCHAR(50),
										@FeatDescription NVARCHAR(150),
										@FeatType INT, 
										@FeatConstraint INT=NULL,
										@CoreAddon CHAR(1),
								        @CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Feature WHERE FeatName = @FeatName AND FeatCat=@FeatCat AND FeatType=@FeatType AND CoreAddon=@CoreAddon AND FeatConstraint=@FeatConstraint)
		BEGIN
			INSERT INTO Feature(FeatCat,FeatName,FeatDescription,FeatType,FeatConstraint, CoreAddon,ActiveStatus,CreatedBy, CreatedDate) VALUES ( @FeatCat,@FeatName,@FeatDescription,@FeatType,@FeatConstraint,@CoreAddon,'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postFreeOption]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postFreeOption]( @UserId INT,
								@AppId INT,
								@PricingId INT,
								@CompId INT=NULL,
								@PurDate DATETIME,
								@PaymentMode INT,
								@PaymentStatus CHAR(1),
								@LicenseStatus CHAR(1),
								@Price DECIMAL(9,2)=NULL,
								@TaxId INT=NULL,
								@TaxAmount DECIMAL(9,2)=NULL,
								@NetPrice DECIMAL(9,2)=NULL,
								@ValidityStart DATETIME,
								@ValidityEnd DATETIME,
								@CreatedBy INT)
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM UserAppMap WHERE UserId = @UserId AND  AppId=@AppId AND PricingId=@PricingId AND CAST(GETDATE() AS DATE) BETWEEN CAST(ValidityStart AS DATE) AND CAST(ValidityEnd AS DATE))
		BEGIN
			INSERT INTO UserAppMap(UserId,AppId,PricingId,CompId,PurDate,PaymentMode,PaymentStatus,LicenseStatus,Price,TaxId,TaxAmount,NetPrice,ValidityStart,ValidityEnd ,CreatedBy, CreatedDate) 
					VALUES (@UserId,@AppId,@PricingId,@CompId,@PurDate,(SELECT ConfigId
							FROM configMasterView
							WHERE TypeName='PaymentType' and ActiveStatus='A' and ConfigName='Free'),@PaymentStatus,@LicenseStatus,@Price,@TaxId,ISNULL(@TaxAmount,0),ISNULL(@NetPrice,0),@ValidityStart,@ValidityEnd,@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postInvoicedeatils]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postInvoicedeatils]( @UniqueId INT=NULL,
								             @MailId NVARCHAR(50)=NULL,
											 @Link NVARCHAR(500)=NULL)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN

		BEGIN
				SELECT um.*,a.AppName,(SELECT u.UserName,u.MobileNo,(@MailId)as MailId FOR JSON PATH) as userData,(SELECT m.* FROM MessageTemplates as m WHERE m.MessageHeader='Booking' FOR JSON PATH) as tempData,
				(@Link) as Link,c.ConfigName
				FROM UserAppMap as um
				LEFT JOIN [User] as u on u.UserId=um.UserId
				LEFT JOIN Application as a on um.AppId=a.AppId
				LEFT JOIN ConfigMaster as c on c.ConfigId=um.PaymentMode
				WHERE um.UniqueId=@UniqueId
				IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Sended Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					
						END
					ELSE
						BEGIN
							SELECT 'Data Not Sended', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postMessageTemplates]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from MessageTemplates

create PROCEDURE [dbo].[postMessageTemplates](
								@MessageHeader NVARCHAR(150),
								@Subject NVARCHAR(150),
								@MessageBody NVARCHAR(Max),
								@TemplateType CHAR(1),
								@Peid NVARCHAR(30),
								@Tpid NVARCHAR(30),
								@CreatedBy int
								)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM MessageTemplates WHERE MessageHeader=@MessageHeader AND TemplateType=@TemplateType)
				BEGIN
                  INSERT INTO MessageTemplates(MessageHeader,Subject,MessageBody,TemplateType,Peid,Tpid,CreatedBy,CreatedDate)
					VALUES(@MessageHeader,@Subject,@MessageBody,@TemplateType,@Peid,@Tpid,@CreatedBy,GETDATE())
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
				END
                  
	ELSE
		BEGIN
			SELECT 'Data Already Exists',2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END

IF @@TRANCOUNT>0
	BEGIN
		COMMIT
	END

END


GO
/****** Object:  StoredProcedure [dbo].[postPaymentUpiDetails]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from PaymentUPIDetails

CREATE PROCEDURE [dbo].[postPaymentUpiDetails](@MobileNo NVARCHAR(10),@Name nvarchar(50),@UPIId nvarchar(30),@UserId int=null,@CompId int=null,@BrId int=null,@type char(1),@MerchantCode nvarchar(50),
                @MerchantId nvarchar(10),@mode nvarchar(15),@orgid nvarchar(15),@sign nvarchar(100),@url nvarchar(100),@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF @type='O' 
	 BEGIN
	   IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE AdminId =@UserId and CompId=@CompId and BranchId=@BrId and mode=@mode and activeStatus='A' )
		BEGIN
		 --IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE CompId=@CompId and activeStatus='A' and BranchId=@BrId)
			 --BEGIN
				INSERT INTO PaymentUPIDetails(MobileNo,Name,UPIId,AdminId,CompId,BranchId,type,MerchantCode,MerchantId,mode,orgid,sign,url,activeStatus, CreatedBy, CreatedDate) VALUES 
				( @MobileNo,@Name,@UPIId,@UserId,@CompId,@BrId,@type,@MerchantCode,@MerchantId,@mode,@orgid,@sign,@url,'A', @CreatedBy, GETDATE())
					IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Added Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					
						END
					ELSE
						BEGIN
							SELECT 'Data Not Added', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
			  END
		--ELSE
		--	BEGIN
		--			update PaymentUPIDetails set activeStatus='D' where  CompId=@CompId and BranchId=@BrId
		--			IF @@ROWCOUNT >0
		--				BEGIN
		--					INSERT INTO PaymentUPIDetails(MobileNo,Name,UPIId,AdminId,CompId,BranchId,type,MerchantCode,MerchantId,mode,orgid,sign,url,activeStatus, CreatedBy, CreatedDate) VALUES 
		--					( @MobileNo,@Name,@UPIId,@UserId,@CompId,@BrId,@type,@MerchantCode,@MerchantId,@mode,@orgid,@sign,@url,'A', @CreatedBy, GETDATE())
		--						IF @@ROWCOUNT > 0
		--							BEGIN
		--								SELECT 'Data Added Successfully', 1
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										COMMIT
		--									END
					
		--							END
		--						ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--					END
		--				 ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--		  END
		--END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	 END
	ElSE
	   BEGIN
		IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE mode=@mode and activeStatus='A' and CompId IS NULL and BranchId IS NULL and AdminId IS NULL)
		BEGIN
		 --IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE CompId=@CompId and activeStatus='A' and BranchId=@BrId)
			 --BEGIN
				INSERT INTO PaymentUPIDetails(MobileNo,Name,UPIId,AdminId,CompId,BranchId,type,MerchantCode,MerchantId,mode,orgid,sign,url,activeStatus, CreatedBy, CreatedDate) VALUES 
				( @MobileNo,@Name,@UPIId,@UserId,@CompId,@BrId,@type,@MerchantCode,@MerchantId,@mode,@orgid,@sign,@url,'A', @CreatedBy, GETDATE())
					IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Added Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					
						END
					ELSE
						BEGIN
							SELECT 'Data Not Added', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
			  END
		--ELSE
		--	BEGIN
		--			update PaymentUPIDetails set activeStatus='D' where  CompId=@CompId and BranchId=@BrId
		--			IF @@ROWCOUNT >0
		--				BEGIN
		--					INSERT INTO PaymentUPIDetails(MobileNo,Name,UPIId,AdminId,CompId,BranchId,type,MerchantCode,MerchantId,mode,orgid,sign,url,activeStatus, CreatedBy, CreatedDate) VALUES 
		--					( @MobileNo,@Name,@UPIId,@UserId,@CompId,@BrId,@type,@MerchantCode,@MerchantId,@mode,@orgid,@sign,@url,'A', @CreatedBy, GETDATE())
		--						IF @@ROWCOUNT > 0
		--							BEGIN
		--								SELECT 'Data Added Successfully', 1
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										COMMIT
		--									END
					
		--							END
		--						ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--					END
		--				 ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--		  END
		--END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
	   END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postPricingAppFeatMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postPricingAppFeatMap]( @AppId INT,@PricingId INT,@CreatedBy INT,@FeatDetails NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	--IF NOT EXISTS(SELECT * FROM PricingAppFeatMap WHERE AppId = @AppId AND PricingId=@PricingId)
	Update PricingAppFeatMap set ActiveStatus='D' where AppId=@AppId AND PricingId=@PricingId
		BEGIN
			INSERT INTO PricingAppFeatMap(AppId,PricingId,FeatId, ActiveStatus ,CreatedBy, CreatedDate) 
			--VALUES ( @AppId,@PricingId,@FeatId, 'A',@CreatedBy, GETDATE())
			SELECT @AppId,@PricingId,FeatId,'A',@CreatedBy,GETDATE()
					FROM OPENJSON (@FeatDetails)
					WITH (
						FeatId INT '$.FeatId'
					)
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	--ELSE
	--	BEGIN
	--		SELECT 'Data Already Exists', 2
	--		IF @@TRANCOUNT > 0
	--			BEGIN
	--				COMMIT
	--			END
	--	END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postPricingType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postPricingType](@AppId INT,
											@PricingName NVARCHAR(50), 
											@Price DECIMAL(9,2) =NULL,
											@DisplayPrice DECIMAL(9,2) = NULL,
											@PriceTag INT= NULL,
											@TaxId INT =NULL,
											@TaxAmount DECIMAL(9,2)=NULL,
											@NetPrice DECIMAL(9,2) = NULL, 
											@CurrId INT,
											@NoOfDays INT,
											@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM PricingType WHERE AppId = @AppId AND PricingName=@PricingName)
		BEGIN
			INSERT INTO PricingType(AppId,PricingName,Price, DisplayPrice, PriceTag, TaxId, TaxAmount, NetPrice,CurrId,NoOfDays, ActiveStatus ,CreatedBy, CreatedDate) 
				VALUES ( @AppId,@PricingName,@Price,@DisplayPrice, @PriceTag, @TaxId, @TaxAmount, @NetPrice,@CurrId,@NoOfDays, 'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postUser]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postUser](@UserType int,
								@CompId INT=NULL,
								@BranchId INT=NULL,
								@MobileNo NVARCHAR(10),
								@MailId NVARCHAR(50) =NULL, 
								@UserName NVARCHAR(20), 
								@UserImage NVARCHAR(150)=NULL,
								@Password NVARCHAR(20),
								@Pin INT=NULL,
								@AppId INT=NULL,
								@CreatedBy INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM [User] WHERE UserName = @UserName OR MobileNo=@MobileNo)
		BEGIN
			INSERT INTO [User](UserType,CompId,BranchId,MobileNo,MailId,UserName,UserImage,Password,Pin,ActiveStatus ,CreatedBy, CreatedDate) VALUES (@UserType,@CompId,@BranchId,@MobileNo,@MailId,@UserName,@UserImage,@Password,@Pin, 'A',@CreatedBy, GETDATE())
			IF @@ROWCOUNT > 0
				BEGIN
				    IF @AppId IS NOT NULL
					BEGIN
						--DELETE AppAccess WHERE UserId=(SELECT  Top 1 u.UserId FROM [User] as u  WHERE u.MobileNo=@MobileNo order by  u.UserId desc)
						BEGIN
							INSERT INTO AppAccess(UserId,AppId,CompId,BranchId,CreatedBy,CreatedDate,ActiveStatus) 
							VALUES((SELECT  Top 1 u.UserId FROM [User] as u  WHERE u.MobileNo=@MobileNo order by  u.UserId desc),
							@AppId,@CompId,@BranchId,@CreatedBy,GETDATE(),'A')
							IF @@ROWCOUNT > 0
							   BEGIN
									SELECT 'Data Added Successfully', 1,(SELECT  Top 1 u.UserId FROM [User] as u  WHERE u.MobileNo=@MobileNo order by  u.UserId desc)
									IF @@TRANCOUNT > 0
										BEGIN
											COMMIT
										END
							   END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0,''
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END
						END
						END
					Else
						BEGIN
									SELECT 'Data Added Successfully', 1,(SELECT  Top 1 u.UserId FROM [User] as u  WHERE u.MobileNo=@MobileNo order by  u.UserId desc)
									IF @@TRANCOUNT > 0
										BEGIN
											COMMIT
										END
							 END
					
					
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added', 0,''
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2,''
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[postUserAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[postUserAppMap]( @UserId INT,
								@AppId INT,
								@PricingId INT,
								@CompId INT=NULL,
								@PurDate DATETIME,
								@PaymentMode INT,
								@PaymentStatus CHAR(1),
								@LicenseStatus CHAR(1),
								@Price DECIMAL(9,2)=NULL,
								@TaxId INT=NULL,
								@TaxAmount DECIMAL(9,2)=NULL,
								@NetPrice DECIMAL(9,2)=NULL,
								@ValidityStart DATETIME,
								@ValidityEnd DATETIME,
								@CreatedBy INT,
								@NoofDays INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN

	declare @lastdate DATETIME;

	IF NOT EXISTS(SELECT * FROM UserAppMap WHERE UserId=@UserId AND AppId=@AppId  AND PaymentStatus='S' AND LicenseStatus='A' AND Getdate() between ValidityStart and ValidityEnd)
		BEGIN
	
				INSERT INTO UserAppMap(UserId,AppId,PricingId,CompId,PurDate,PaymentMode,PaymentStatus,LicenseStatus,Price,TaxId,TaxAmount,NetPrice,ValidityStart,ValidityEnd ,CreatedBy, CreatedDate) 
						VALUES (@UserId,@AppId,@PricingId,@CompId,@PurDate,@PaymentMode,@PaymentStatus,@LicenseStatus,@Price,@TaxId,ISNULL(@TaxAmount,0),ISNULL(@NetPrice,0),@ValidityStart,@ValidityEnd,@CreatedBy, GETDATE())
						IF @@ROWCOUNT > 0
							BEGIN
								SELECT 'Data Added Successfully', 1,(select Top 1 UniqueId from UserAppMap where UserId=@UserId order by UniqueId desc),(SELECT u.UserName,u.MailId,u.MobileNo FROM [User] as u where u.UserId=@UserId FOR JSON PATH)as userData,
								(SELECT a.AppName FROM Application as a WHERE a.AppId=@AppId),(SELECT m.* FROM MessageTemplates as m WHERE m.MessageHeader='Booking' FOR JSON PATH) as tempData,(SELECT c.ConfigName FROM ConfigMaster as c WHERE c.ConfigId=@PaymentMode)
								IF @@TRANCOUNT > 0
									BEGIN
										COMMIT
									END
					
							END
						ELSE
							BEGIN
								SELECT 'Data Not Added', 0,'','','',''
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
		END
	ELSE
		BEGIN

		
	
		set @lastdate=(select Top 1 ValidityEnd + 1 from UserAppMap WHERE UserId=@UserId AND AppId=@AppId AND PaymentStatus='S' AND LicenseStatus='A' order by UniqueId desc)
			INSERT INTO UserAppMap(UserId,AppId,PricingId,CompId,PurDate,PaymentMode,PaymentStatus,LicenseStatus,Price,TaxId,TaxAmount,NetPrice,ValidityStart,ValidityEnd ,CreatedBy, CreatedDate) 
							VALUES (@UserId,@AppId,@PricingId,@CompId,@PurDate,@PaymentMode,@PaymentStatus,@LicenseStatus,@Price,@TaxId,ISNULL(@TaxAmount,0),ISNULL(@NetPrice,0),@lastdate,@lastdate+@NoofDays,@CreatedBy, GETDATE())
							IF @@ROWCOUNT > 0
								BEGIN
									SELECT 'Data Added Successfully', 1,(select Top 1 UniqueId from UserAppMap where UserId=@UserId order by UniqueId desc),(SELECT u.UserName,u.MailId,u.MobileNo FROM [User] as u where u.UserId=@UserId FOR JSON PATH)as userData,
								(SELECT a.AppName FROM Application as a WHERE a.AppId=@AppId) as AppName,(SELECT m.* FROM MessageTemplates as m WHERE m.MessageHeader='Booking' FOR JSON PATH) as tempData,(SELECT c.ConfigName FROM ConfigMaster as c WHERE c.ConfigId=@PaymentMode)
									IF @@TRANCOUNT > 0
										BEGIN
											COMMIT
										END
					
								END
							ELSE
								BEGIN
									SELECT 'Data Not Added', 0,'','','',''
									IF @@TRANCOUNT > 0
										BEGIN
											ROLLBACK
										END
								END

		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putAppImage]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putAppImage](@AppId INT,
										@ImageType CHAR(1),
										@ImageName NVARCHAR(50),
										@ImageLink NVARCHAR(150),
										@UpdatedBy INT=NULL,
										@ImageId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	
	UPDATE AppImage SET ImageType=@ImageType,ImageName=@ImageName,ImageLink=@ImageLink,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
		WHERE ImageId=@ImageId AND AppId=@AppId
		
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Updated Successfully', 1
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
					
		END
	ELSE
		BEGIN
			SELECT 'Data Not Updated', 0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putApplication]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putApplication] (@AppName NVARCHAR(50),
								@AppDescription NVARCHAR(150),
								@AppLogo NVARCHAR(150)=NULL,
								@CateId INT,
								@SubCateId INT,
								@BannerImage NVARCHAR(150),
								@UpdatedBy INT,
								@AppId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	
	IF NOT EXISTS(SELECT * FROM Application WHERE AppName=@AppName AND CateId=@CateId AND SubCateId=@SubCateId AND AppId!=@AppId)
		BEGIN
			UPDATE Application SET AppName=@AppName,AppDescription=@AppDescription,AppLogo=@AppLogo,BannerImage=@BannerImage,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
				WHERE CateId=@CateId AND SubCateId=@SubCateId AND AppId=@AppId
				
			IF @@ROWCOUNT >0
				BEGIN
					SELECT 'Data Updated Successfully',1
					IF @@TRANCOUNT >0
						BEGIN
							COMMIT
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					IF @@TRANCOUNT >0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putAppMenu]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putAppMenu]( @AppId INT,
								@MenuName NVARCHAR(20),
								@Level CHAR(1),
								@Level1Id INT,
								@Level2Id INT,
								
								@UpdatedBy INT=NULL,
								@MenuId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM AppMenu WHERE MenuName = @MenuName AND AppId=@AppId AND MenuId!=@MenuId)
		BEGIN
			UPDATE AppMenu SET AppId=@AppId,MenuName=@MenuName,Level=@Level,Level1Id=@Level1Id,Level2Id=@Level2Id, UpdatedBy=@UpdatedBy,UpdatedDate= GETDATE()
				WHERE MenuId=@MenuId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putBranch]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putBranch](@CompId INT,
							@BrName NVARCHAR(50),
							@BrShName NVARCHAR(20),
							@BrGSTIN NVARCHAR(15)=NULL,
							@BrInCharge NVARCHAR(15),
							@BrMobile NVARCHAR(10)=NULL,
							@BrEmail NVARCHAR(50)=NULL,
							@BrRegnNo NVARCHAR(50)=NULL,
							@WorkingFrom TIME(7)=NULL,
							@WorkingTo TIME(7)=NULL,
							@UpdatedBy INT,
							@Address1 NVARCHAR(100)=NULL,
							@Address2 NVARCHAR(100)=NULL,
							@Zip INT=NULL,
							@City NVARCHAR(50)=NULL,
							@Dist NVARCHAR(50)=NULl,
							@State NVARCHAR(50)=NULL,
							@Latitude DECIMAL(12,8)=NULL,
							@Longitude  DECIMAL(12,8)=NULL,
							@BrId INT,
							@AddId INT=NULL)	
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Branch WHERE BrName=@BrName AND CompId=@CompId AND BrId!=@BrId)
		BEGIN
			IF @AddId IS NULL AND @Address1 IS NOT NULL AND @Zip IS NOT NULL AND @City IS NOT NULL AND @Dist IS NOT NULL AND @State IS NOT NULL
			  BEGIN
				INSERT INTO CommonAddress (Address1,Address2,Zip,City,Dist,State,Latitude,Longitude,ActiveStatus,CreatedBy, CreatedDate)
				 VALUES(@Address1,@Address2,@Zip,@City,@Dist,@State,@Latitude,@Longitude,'A',@UpdatedBy, GETDATE())
				  IF @@ROWCOUNT > 0
					BEGIN
					   UPDATE Branch SET CompId=@CompId,BrName=@BrName,BrShName=@BrShName,BrAddId=(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),BrGSTIN=@BrGSTIN,BrInCharge=@BrInCharge,BrMobile=@BrMobile,BrEmail=@BrEmail,BrRegnNo=@BrRegnNo,WorkingFrom=@WorkingFrom,WorkingTo=@WorkingTo,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
						WHERE BrId=@BrId
						IF @@ROWCOUNT = 0
							BEGIN
								SELECT 'Data Not Updated', 0
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					  END
				  ELSE
					  BEGIN
						SELECT 'Data Not Updated', 0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					  END
				END
			 ELSE
				  BEGIN
					UPDATE Branch SET CompId=@CompId,BrName=@BrName,BrShName=@BrShName,BrAddId=@AddId,BrGSTIN=@BrGSTIN,BrInCharge=@BrInCharge,BrMobile=@BrMobile,BrEmail=@BrEmail,BrRegnNo=@BrRegnNo,WorkingFrom=@WorkingFrom,WorkingTo=@WorkingTo,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
							WHERE BrId=@BrId
					IF @@ROWCOUNT > 0
						BEGIN
							IF @AddId IS NOT NULL
								BEGIN
									UPDATE CommonAddress  SET Address1=@Address1,Address2=@Address2,Zip=@Zip,City=@City,Dist=@Dist,State=@State,Latitude=@Latitude,Longitude=@Longitude,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
										WHERE AddId=@AddId
									
									IF @@ROWCOUNT = 0
										BEGIN
											SELECT 'Data Not Updated', 0
											IF @@TRANCOUNT > 0
												BEGIN
													ROLLBACK
												END
										END
								END
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					
						END
					ELSE
						BEGIN
							SELECT 'Data Not Updated', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
				END
			END						
	 ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
					
	

IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END

END


GO
/****** Object:  StoredProcedure [dbo].[putCarousel]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putCarousel](@ScreenId INT,@Carousel NVARCHAR(150),@UpdatedBy INT=NULL,@CarouselId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Carousel WHERE ScreenId = @ScreenId AND Carousel=@Carousel AND CarouselId!=@CarouselId)
		BEGIN
			UPDATE Carousel SET Carousel=@Carousel,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE ScreenId=@ScreenId AND CarouselId=@CarouselId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putCompany]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putCompany](@CompName NVARCHAR(50),
									@CompShName NVARCHAR(20),
									@BusiBrief NVARCHAR(150) =NULL,
									@CompLogo NVARCHAR(150) =NULL,
									@CompAddId INT=NULL,
									@CompGSTIN NVARCHAR(15) =NULL,
									@Proprietor NVARCHAR(20),
									@CompPOC NVARCHAR(15) =NULL,
									@CompMobile NVARCHAR(10) =NULL,
									@CompEmail NVARCHAR(50)=NULL,
									@CompRegnNo NVARCHAR(20)=NULL,
									@UpdatedBy INT=NULL,
									@Address1 NVARCHAR(100),
									@Address2 NVARCHAR(100)=NULL,
									@Zip INT,
									@City NVARCHAR(50),
									@Dist NVARCHAR(50),
									@State NVARCHAR(50),
									@Latitude DECIMAL(12,8)=NULL,
									@Longitude  DECIMAL(12,8)=NULL,
									@AddId INT=NULL,
									@CompId INT
									--@UserId INT
									)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Company WHERE CompName = @CompName AND CompId!=@CompId)
		BEGIN
		IF @AddId=0 AND @Address1 IS NOT NULL AND @Zip IS NOT NULL AND @City IS NOT NULL AND @Dist IS NOT NULL AND @State IS NOT NULL
			BEGIN
				INSERT INTO CommonAddress (Address1,Address2,Zip,City,Dist,State,Latitude,Longitude,ActiveStatus,CreatedBy, CreatedDate)
					VALUES(@Address1,@Address2,@Zip,@City,@Dist,@State,@Latitude,@Longitude,'A',@UpdatedBy, GETDATE())
				IF @@ROWCOUNT > 0
					BEGIN
						UPDATE Company SET CompName=@CompName,CompShName=@CompShName,BusiBrief=@BusiBrief,CompLogo=@CompLogo,CompAddId=(SELECT TOP 1 AddId FROM CommonAddress WHERE Address1=@Address1 AND Zip=@Zip AND City=@City ORDER BY AddId DESC),CompGSTIN=@CompGSTIN,Proprietor=@Proprietor,CompPOC=@CompPOC,CompMobile=@CompMobile,CompEmail=@CompEmail,CompRegnNo=@CompRegnNo,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
							WHERE CompId=@CompId
						IF @@ROWCOUNT = 0
							BEGIN
								SELECT 'Data Not Updated', 0
								IF @@TRANCOUNT > 0
									BEGIN
										ROLLBACK
									END
							END
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					END
				ELSE
					BEGIN
						SELECT 'Data Not Updated', 0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END

			END
		ELSE
			BEGIN
				UPDATE Company SET CompName=@CompName,CompShName=@CompShName,BusiBrief=@BusiBrief,CompLogo=@CompLogo,CompAddId=@CompAddId,CompGSTIN=@CompGSTIN,Proprietor=@Proprietor,CompPOC=@CompPOC,CompMobile=@CompMobile,CompEmail=@CompEmail,CompRegnNo=@CompRegnNo,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
						WHERE CompId=@CompId
					
				IF @@ROWCOUNT > 0
					BEGIN
						IF @AddId!=0
							BEGIN
								UPDATE CommonAddress  SET Address1=@Address1,Address2=@Address2,Zip=@Zip,City=@City,Dist=@Dist,State=@State,Latitude=@Latitude,Longitude=@Longitude,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
									WHERE AddId=@AddId
									
								IF @@ROWCOUNT = 0
									BEGIN
										SELECT 'Data Not Updated', 0
										IF @@TRANCOUNT > 0
											BEGIN
												ROLLBACK
											END
									END
							END
						SELECT 'Data Updated Successfully', 1
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					
					END
				ELSE
					BEGIN
						SELECT 'Data Not Updated', 0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
			END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putCompAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putCompAppMap]( @CompId INT,
								@BranchId INT,
								@AppId INT,
								@UpdatedBy INT=NULL,
								@UniqueId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM CompAppMap WHERE CompId = @CompId AND BranchId =@BranchId AND AppId=@AppId AND UniqueId!=UniqueId)
		BEGIN
			UPDATE CompAppMap SET CompId=@CompId,BranchId=@BranchId,AppId=@AppId,UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE()
				WHERE UniqueId=@UniqueId
					
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putConfigMaster]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putConfigMaster](@TypeId INT,
								  @ConfigName NVARCHAR(50),
								  @AlphaNumFld NVARCHAR(20) = NULL,
								  @NumFld DECIMAL(10,3) = NULL,
								  @SmallIcon NVARCHAR(150) = NULL,
								  @UpdatedBy INT=NULL,
								  @ConfigId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigMaster WHERE TypeId = @TypeId AND ConfigName=@ConfigName AND ConfigId!=@ConfigId)
		BEGIN
			UPDATE ConfigMaster SET ConfigName=@ConfigName,AlphaNumFld=@AlphaNumFld,NumFld=@NumFld,SmallIcon=@SmallIcon,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
					WHERE TypeId = @TypeId AND ConfigId = @ConfigId
				
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putConfigType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putConfigType]( @TypeName NVARCHAR(50),
								@UpdatedBy INT=NULL,
								@TypeId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigType WHERE TypeName = @TypeName AND TypeId!=@TypeId)
		BEGIN
			UPDATE ConfigType SET TypeName=@TypeName,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE TypeId=@TypeId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putCurrency]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putCurrency](@CurrName NVARCHAR(50),@CurrShName  NVARCHAR(3),@ConvRate FLOAT, @UpdatedBy INT,@CurrId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Currency WHERE CurrName=@CurrName AND CurrId!=@CurrId)
		BEGIN
			UPDATE Currency SET CurrName=@CurrName,CurrShName=@CurrShName,ConvRate=@ConvRate,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE CurrId=@CurrId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END


GO
/****** Object:  StoredProcedure [dbo].[putDeafaulBranch]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[putDeafaulBranch](@DefaultBranch CHAR(1)=NULL,
										  @CompId INT=NULL,
										  @BranchId INT=NULL,
										  @UserId INT =NULL)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE AppAccess SET DefaultBranch=@DefaultBranch WHERE CompId=@CompId AND BranchId=@BranchId AND UserId=@UserId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putFeature]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putFeature](@FeatCat INT,
										@FeatName NVARCHAR(50),
										@FeatDescription NVARCHAR(150),
										@FeatType INT, 
										@FeatConstraint INT=NULL,
										@CoreAddon CHAR(1),
										@UpdatedBy INT=NULL,
										@FeatId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Feature WHERE FeatName = @FeatName AND FeatCat=@FeatCat AND CoreAddon=@CoreAddon AND FeatType=@FeatType AND FeatConstraint=@FeatConstraint  AND FeatId!=@FeatId)
		BEGIN
			UPDATE Feature SET FeatName=@FeatName,FeatDescription=@FeatDescription,FeatConstraint=@FeatConstraint,CoreAddon=@CoreAddon,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE()
				WHERE FeatCat=@FeatCat AND FeatType=@FeatType AND FeatId=@FeatId
				
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putMessageTemplates]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from MessageTemplates

create PROCEDURE [dbo].[putMessageTemplates](
								@MessageHeader NVARCHAR(150),
								@Subject NVARCHAR(150),
								@MessageBody NVARCHAR(Max),
								@TemplateType CHAR(1),
								@Peid NVARCHAR(30),
								@Tpid NVARCHAR(30),
								@UpdatedBy int,
								@UniqueId int
								)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM MessageTemplates WHERE MessageHeader=@MessageHeader AND TemplateType=@TemplateType AND UniqueId!=@UniqueId)
				BEGIN
                  Update MessageTemplates set MessageHeader=@MessageHeader,Subject=@Subject,MessageBody=@MessageBody,TemplateType=@TemplateType,Peid=@Peid,Tpid=@Tpid,UpdatedBy=@UpdatedBy,UpdatedDate=GetDate() where UniqueId=@UniqueId
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Updated Successfully',1
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK
							END
					END
				END
                  
	ELSE
		BEGIN
			SELECT 'Data Already Exists',2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END

IF @@TRANCOUNT>0
	BEGIN
		COMMIT
	END

END


GO
/****** Object:  StoredProcedure [dbo].[putPaymentUpiDetails]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putPaymentUpiDetails](
								@MobileNo NVARCHAR(10),
								@Name nvarchar(50),
								@UPIId nvarchar(30),
								@AdminId int=null,
								@CompId int=null,
								@BranchId int=null,
								@type char(1)=null,
								@MerchantCode nvarchar(50),
								@MerchantId nvarchar(10),
								@mode nvarchar(15),
								@orgid nvarchar(15),
								@sign nvarchar(100),
								@url nvarchar(100),
								@UpdatedBy INT,
								@PaymentUPIDetailsId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE type=@type and mode=@mode and CompId=@CompId and BranchId=@BranchId and activeStatus='A' and PaymentUPIDetailsId!=@PaymentUPIDetailsId )
	 
		--BEGIN
		 --IF NOT EXISTS(SELECT * FROM PaymentUPIDetails WHERE CompId=@CompId and activeStatus='A' and BranchId=@BranchId)
			 BEGIN
				UPDATE PaymentUPIDetails SET MobileNo=@MobileNo, Name=@Name, UPIId=@UPIId, AdminId=@AdminId, CompId=@CompId, BranchId=@BranchId,
					type=@type, MerchantCode=@MerchantCode, MerchantId=@MerchantId, mode=@mode, orgid=@orgid , sign=@sign, url=@url, UpdatedBy=@UpdatedBy WHERE PaymentUPIDetailsId=@PaymentUPIDetailsId
					IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
					
						END
					ELSE
						BEGIN
							SELECT 'Data Not Updated', 0
							IF @@TRANCOUNT > 0
								BEGIN
									ROLLBACK
								END
						END
			  END
		--ELSE
		--	BEGIN
		--			update PaymentUPIDetails set activeStatus='D' where  CompId=@CompId and BranchId=@BranchId
		--			IF @@ROWCOUNT >0
		--				BEGIN
		--					INSERT INTO PaymentUPIDetails(MobileNo,Name,UPIId,AdminId,CompId,BranchId,type,MerchantCode,MerchantId,mode,orgid,sign,url,activeStatus, CreatedBy, CreatedDate) VALUES 
		--					( @MobileNo,@Name,@UPIId,@AdminId,@CompId,@BranchId,@type,@MerchantCode,@MerchantId,@mode,@orgid,@sign,@url,'A', @CreatedBy, GETDATE())
		--						IF @@ROWCOUNT > 0
		--							BEGIN
		--								SELECT 'Data Added Successfully', 1
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										COMMIT
		--									END
					
		--							END
		--						ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--					END
		--				 ELSE
		--							BEGIN
		--								SELECT 'Data Not Added', 0
		--								IF @@TRANCOUNT > 0
		--									BEGIN
		--										ROLLBACK
		--									END
		--							END
		--		  END
		--END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putPricingType]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putPricingType](@AppId INT,
											@PricingName NVARCHAR(50), 
											@Price INT =NULL,
											@DisplayPrice DECIMAL(9,2) = NULL,
											@PriceTag INT= NULL,
											@TaxId INT =NULL,
											@TaxAmount DECIMAL(9,2)=NULL,
											@NetPrice DECIMAL(9,2) = NULL,
											@CurrId INT,
											@NoOfDays INT,
											@UpdatedBy INT,
											@PricingId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM PricingType WHERE AppId = @AppId AND PricingName=@PricingName AND PricingId!=PricingId)
		BEGIN
			UPDATE PricingType SET PricingName=@PricingName,Price=@Price,DisplayPrice=@DisplayPrice, PriceTag= @PriceTag , TaxId=@TaxId, TaxAmount = @TaxAmount,
					NetPrice=@NetPrice, CurrId=@CurrId,NoOfDays=@NoOfDays,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE AppId=@AppId AND PricingId=@PricingId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putUPIPmtStatus]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putUPIPmtStatus](@PaymentStatus CHAR(1),@TransactionId NVARCHAR(50)=NULL,@BankName NVARCHAR(50)=NULL,@BankReferenceNumber NVARCHAR(50),@UpdatedBy INT=NULL,@UniqueId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE UserAppMap SET PaymentStatus=@PaymentStatus,TransactionId=@TransactionId,BankName=@BankName,BankReferenceNumber=@BankReferenceNumber,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UniqueId=@UniqueId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putUser]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putUser](@UserType INT,
								--@CompId INT,
								--@BranchId INT,
								@MobileNo NVARCHAR(10),
								@MailId NVARCHAR(50) =NULL, 
								@UserName NVARCHAR(20),
								@UserImage NVARCHAR(150)=NULL,
								@Password NVARCHAR(20),
								@Pin INT=NULL,
								@UpdatedBy INT,
								@UserId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM [User] WHERE(UserName = @UserName OR MobileNo=@MobileNo) AND UserId!=@UserId)
		BEGIN
			UPDATE [User] SET UserType=@UserType,
			--CompId=@CompId,BranchId=@BranchId,
			MobileNo=@MobileNo,MailId=@MailId,UserName=@UserName,UserImage=@UserImage,Password=@Password,Pin=@Pin,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UserId=@UserId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Already Exists', 2
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END

--EXEC putUser 'E',1,1,'7896541235','arun@gmail.com','arun','123',123,7,8
GO
/****** Object:  StoredProcedure [dbo].[putUserAppMap]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putUserAppMap]( 
								@PaymentStatus CHAR(1),
								@UpdatedBy INT= NULL,
								@UniqueId INT)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE UserAppMap SET PaymentStatus=@PaymentStatus,UpdatedBy=@UpdatedBy WHERE UniqueId=@UniqueId
		
	IF @@ROWCOUNT > 0
		BEGIN
			SELECT 'Data Updated Successfully', 1,(select * from MessageTemplates where MessageHeader='PaymentLink' for json path) as MessageTemplate,
			(SELECT u.UserName,u.MailId,u.MobileNo,ISNULL(up.TaxAmount,0) as TaxAmount,up.NetPrice FROM [User] as u INNER JOIN UserAppMap as up ON up.UserId=u.UserId WHERE up.UniqueId=@UniqueId FOR JSON PATH)as userData,
			(SELECT a.AppName FROM Application as a INNER JOIN UserAppMap as up ON a.AppId=up.AppId WHERE up.UniqueId=@UniqueId),(SELECT m.* FROM MessageTemplates as m WHERE m.MessageHeader='Booking' FOR JSON PATH) as tempData,
			(SELECT c.ConfigName FROM ConfigMaster as c INNER JOIN UserAppMap as up ON c.ConfigId=up.PaymentMode WHERE up.UniqueId=@UniqueId)
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
					
		END
	ELSE
		BEGIN
			SELECT 'Data Not Updated', 0,'','','','',''
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK
				END
		END
		
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putUserPassword]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from [User]
CREATE PROCEDURE [dbo].[putUserPassword]( @UserId int,
								@UpdatedBy INT=NULL,
								@Password Nvarchar(20))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
		BEGIN
			UPDATE [User] SET Password=@Password,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UserId=@UserId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putUserPin]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from [User]
CREATE PROCEDURE [dbo].[putUserPin]( @UserId int,
								@UpdatedBy INT=NULL,
								@Pin int)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
		BEGIN
			UPDATE [User] SET Pin=@Pin,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UserId=@UserId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[putUserProfile]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from [User]
CREATE PROCEDURE [dbo].[putUserProfile]( @UserId int,
								@UpdatedBy INT=NULL,
								@MobileNo nvarchar(10),
								@MailId nvarchar(50),
								@UserName Nvarchar(50),
								@UserImage NvarChar(200))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
		BEGIN
			UPDATE [User] SET MailId=@MailId,MobileNo=@MobileNo,UserName=@UserName,UserImage=@UserImage,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UserId=@UserId
			IF @@ROWCOUNT > 0
				BEGIN
					SELECT 'Data Updated Successfully', 1
					IF @@TRANCOUNT > 0
						BEGIN
							COMMIT
						END
					
				END
			ELSE
				BEGIN
					SELECT 'Data Not Updated', 0
					IF @@TRANCOUNT > 0
						BEGIN
							ROLLBACK
						END
				END
		END
	
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[VerifyOTP]    Script Date: 27-Jul-23 11:47:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC VerifyOTP @UserName ='9999999998'
--EXEC VerifyOTP @UserName ='9222222222',@Type='N'
CREATE PROCEDURE [dbo].[VerifyOTP](@UserName NVARCHAR(50),@Type char(1)=NULL)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF @Type IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT * FROM [User] WHERE MobileNo=@UserName)
				BEGIN
					INSERT INTO [User](MobileNo,CreatedBy, CreatedDate,UserType)  VALUES (@UserName,0,getdate(),(select Top 1 ConfigId from ConfigMaster where ConfigName='Admin'))
						IF @@ROWCOUNT > 0
							BEGIN
								SELECT 'Data Added Successfully', 2,(Select Top 1 [User].UserId from [User] where MobileNo=@UserName),(select * from MessageTemplates where MessageHeader='OTP' for json path) as MessageTemplate
								
					
							END
					ELSE
						BEGIN
							SELECT 'Data Not Added', 0,''
							
						END
				END
			ELSE
				BEGIN
					SELECT 'User Already Exists',0,''
					COMMIT
				END

		END
		

	ELSE
	  BEGIN
		IF EXISTS(SELECT MobileNo from [User] WHERE MobileNo=@UserName)
			BEGIN
				SELECT 'User Exists',1,'',(select * from MessageTemplates where MessageHeader='OTP' for json path) as MessageTemplate,MailId,MobileNo,UserName,UserId 
				FROM [User] 
					WHERE (MailId=@UserName OR MobileNo=@UserName)
				
			END
		ELSE
			BEGIN
				SELECT 'User Not Exists',0,''
				COMMIT
			END
		END
IF @@TRANCOUNT > 0
		BEGIN
			COMMIT
		END

END
GO
