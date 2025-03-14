USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[DispatchRequests]    Script Date: 3/13/2025 5:16:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DispatchRequests](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerCode] [nvarchar](50) NOT NULL,
	[OrderNumber] [int] NULL,
	[ProductId] [int] NULL,
	[ItemId] [int] NULL,
	[PriceCardType] [nvarchar](20) NOT NULL,
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
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DispatchRequests] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
