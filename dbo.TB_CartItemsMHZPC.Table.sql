USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[TB_CartItemsMHZPC]    Script Date: 2/26/2025 5:31:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TB_CartItemsMHZPC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CartId] [int] NULL,
	[PriceCardType] [nvarchar](50) NOT NULL,
	[ProductName] [nvarchar](255) NULL,
	[Condition_Amount] [decimal](18, 2) NULL,
	[BookingPrice] [decimal](18, 2) NULL,
	[OrderQuantity] [int] NULL,
	[OrderAmount] [decimal](18, 2) NULL,
	[BookingAmount] [decimal](18, 2) NULL,
	[BalanceAmountToPay] [decimal](18, 2) NULL,
	[SecondaryProductName] [nvarchar](255) NULL,
	[SecondaryCondition_Amount] [decimal](18, 2) NULL,
	[SecondaryBookingPrice] [decimal](18, 2) NULL,
	[SecondaryOrderQuantity] [int] NULL,
	[SecondaryOrderAmount] [decimal](18, 2) NULL,
	[SecondaryBookingAmount] [decimal](18, 2) NULL,
	[SecondaryBalanceAmountToPay] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TB_CartItemsMHZPC]  WITH CHECK ADD FOREIGN KEY([CartId])
REFERENCES [dbo].[TB_CartMHZPC] ([Id])
GO
