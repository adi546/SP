USE [mazuagricusmssql01-db-db]
GO
/****** Object:  Table [dbo].[TB_States]    Script Date: 2/26/2025 5:29:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TB_States](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StateName] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[TB_States] ON 

INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (1, N'Andhra Pradesh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (2, N'Arunachal Pradesh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (3, N'Assam')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (4, N'Bihar')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (5, N'Chhattisgarh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (6, N'Goa')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (7, N'Gujarat')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (8, N'Haryana')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (9, N'Himachal Pradesh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (10, N'Jharkhand')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (11, N'Karnataka')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (12, N'Kerala')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (13, N'Madhya Pradesh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (14, N'Maharashtra')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (15, N'Manipur')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (16, N'Meghalaya')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (17, N'Mizoram')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (18, N'Nagaland')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (19, N'Odisha')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (20, N'Punjab')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (21, N'Rajasthan')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (22, N'Sikkim')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (23, N'Tamil Nadu')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (24, N'Telangana')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (25, N'Tripura')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (26, N'Uttar Pradesh')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (27, N'Uttarakhand')
INSERT [dbo].[TB_States] ([Id], [StateName]) VALUES (28, N'West Bengal')
SET IDENTITY_INSERT [dbo].[TB_States] OFF
GO
