<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentHome.aspx.cs" Inherits="StudentHome" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>Student Dashboard | 智慧教务</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    <link href="Style.css" rel="stylesheet" />

    <style>
        /* === 页面独有样式 === */
        .dashboard-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 40px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .welcome-text h2 { font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 28px; margin: 0; color: #fff; }
        .welcome-text p { color: #94a3b8; margin: 5px 0 0 0; }

        /* 仪表盘卡片网格 */
        .stats-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 25px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: rgba(30, 41, 59, 0.6); border: 1px solid rgba(255,255,255,0.05);
            padding: 25px; border-radius: 12px; position: relative; overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.2); }
        
        .stat-icon {
            position: absolute; top: 20px; right: 20px; font-size: 40px; opacity: 0.1; color: #fff;
        }
        .stat-label { font-size: 14px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; }
        .stat-value { font-family: 'Rajdhani', sans-serif; font-size: 36px; font-weight: 700; color: #fff; margin-top: 10px; }
        
        /* 动态状态颜色类 */
        .text-danger { color: #ef4444 !important; text-shadow: 0 0 10px rgba(239, 68, 68, 0.5); }
        .text-success { color: #10b981 !important; }
        .text-primary { color: #38bdf8 !important; }

        /* 快捷菜单 */
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 20px; }
        .menu-item {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05);
            padding: 30px; border-radius: 12px; text-decoration: none; color: #cbd5e1;
            transition: all 0.2s;
        }
        .menu-item:hover { background: rgba(255,255,255,0.08); color: #fff; transform: scale(1.02); }
        .menu-item i { font-size: 32px; margin-bottom: 15px; color: #38bdf8; }
        .menu-item span { font-weight: 600; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="background: rgba(15, 23, 42, 0.9); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div style="font-family: 'Rajdhani'; font-weight: 700; font-size: 20px; color: #38bdf8;">
                <i class="fas fa-atom"></i> EDU-HUB
            </div>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" style="color: #ef4444; text-decoration:none; font-weight:600;">
                <i class="fas fa-sign-out-alt"></i> Logout
            </asp:LinkButton>
        </div>

        <div class="container">
            <div class="dashboard-header">
                <div class="welcome-text">
                    <h2>Welcome back, <asp:Label ID="lblName" runat="server"></asp:Label></h2>
                    <p>Student ID: <asp:Label ID="lblStuNo" runat="server"></asp:Label> | Let's keep learning.</p>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <i class="fas fa-chart-line stat-icon"></i>
                    <div class="stat-label">Avg Score</div>
                    <div class="stat-value text-primary">
                        <asp:Literal ID="ltlAvgScore" runat="server" Text="0.0"></asp:Literal>
                    </div>
                </div>

                <div class="stat-card">
                    <i class="fas fa-award stat-icon"></i>
                    <div class="stat-label">Credits Earned</div>
                    <div class="stat-value text-success">
                        <asp:Literal ID="ltlCredits" runat="server" Text="0"></asp:Literal>
                    </div>
                </div>

                <div class="stat-card">
                    <i class="fas fa-exclamation-triangle stat-icon"></i>
                    <div class="stat-label">Pending / Failed</div>
                    <div class="<%= HasFailed ? "stat-value text-danger" : "stat-value" %>">
                        <asp:Literal ID="ltlFailed" runat="server" Text="0"></asp:Literal>
                    </div>
                </div>
            </div>

            <h3 style="color:#fff; margin-bottom:20px; font-family:'Rajdhani';">Quick Actions</h3>
            <div class="menu-grid">
                <a href="CourseSelection.aspx" class="menu-item">
                    <i class="fas fa-book-open"></i>
                    <span>Enroll Courses</span>
                </a>
                <a href="StudentScore.aspx" class="menu-item">
                    <i class="fas fa-file-invoice"></i>
                    <span>My Grades</span>
                </a>
                <a href="StudentRetake.aspx" class="menu-item">
                    <i class="fas fa-redo"></i>
                    <span>Retake App</span>
                </a>
            </div>
        </div>
    </form>
</body>
</html>