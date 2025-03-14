USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[RejectionReasons]    Script Date: 3/13/2025 7:50:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RejectionReasons](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Reason] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[RejectionReasons] ON 

INSERT [dbo].[RejectionReasons] ([Id], [Reason]) VALUES (1, N'We regret to inform you that your order cannot be processed because the items are unavailable.')
INSERT [dbo].[RejectionReasons] ([Id], [Reason]) VALUES (2, N'We are unable to process your order because you have exceeded your available credit limit.')
INSERT [dbo].[RejectionReasons] ([Id], [Reason]) VALUES (3, N'We are unable to process your order due to an overdue balance that exceeds 90 days.')
SET IDENTITY_INSERT [dbo].[RejectionReasons] OFF
GO
