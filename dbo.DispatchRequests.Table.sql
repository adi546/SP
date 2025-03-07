USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[DispatchRequests]    Script Date: 3/8/2025 6:21:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DispatchRequests](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerCode] [nvarchar](50) NOT NULL,
	[PricePerKg] [decimal](18, 2) NOT NULL,
	[BookingPrice] [decimal](18, 2) NOT NULL,
	[BookedQty] [int] NOT NULL,
	[BookingAmtPaid] [decimal](18, 2) NOT NULL,
	[BalanceAmtToPay] [decimal](18, 2) NOT NULL,
	[ExpectedDelivery] [date] NULL,
	[BalanceQuantity] [int] NOT NULL,
	[DispatchStatus] [nvarchar](20) NOT NULL,
	[RequestForQuantityMT] [decimal](18, 2) NOT NULL,
	[AmountRequiredToDispatch] [decimal](18, 2) NOT NULL,
	[BookingAmountReceived] [decimal](18, 2) NOT NULL,
	[BalanceAmount] [decimal](18, 2) NOT NULL,
	[FromDate] [date] NOT NULL,
	[ToDate] [date] NOT NULL,
	[DispatchAddress] [nvarchar](255) NOT NULL,
	[CreatedOn] [datetime] NULL,
	[OrderNumber] [int] NULL,
	[SecondaryPricePerKg] [decimal](18, 2) NULL,
	[SecondaryBookingPrice] [decimal](18, 2) NULL,
	[SecondaryBookedQty] [int] NULL,
	[SecondaryBookingAmtPaid] [decimal](18, 2) NULL,
	[SecondaryBalanceAmtToPay] [decimal](18, 2) NULL,
	[SecondaryRequestForQtyMT] [decimal](18, 2) NULL,
	[SecondaryBalanceQuantity] [int] NULL,
	[SecondaryDispatchStatus] [nvarchar](20) NULL,
	[SecondaryBalanceAmount] [decimal](18, 2) NULL,
	[ProductId] [int] NULL,
	[SecondaryAmountRequiredToDispatch] [decimal](18, 2) NULL,
	[SecondaryBookingAmountReceived] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DispatchRequests] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
