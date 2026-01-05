<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentHome.aspx.cs" Inherits="StudentHome" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>学生指挥中心 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 页面加载前立即同步主题 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 学生版主题变量 (星云紫/靛青) === */
        :root {
            --primary: #6366f1;       /* Indigo 500 */
            --primary-hover: #4f46e5; /* Indigo 600 */
            --danger: #ef4444;        /* Red 500 (预警色) */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        /* 🌑 暗黑模式 */
        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
        }

        /* ☀️ 明亮模式 */
        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s, color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* === 导航栏 === */
        .navbar {
            background-color: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 0 40px; height: 64px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 100;
            box-shadow: var(--shadow);
        }
        .brand { font-size: 20px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 10px; }
        .nav-right { display: flex; align-items: center; gap: 20px; }
        .theme-toggle-btn { background: none; border: none; cursor: pointer; color: var(--text-sub); font-size: 18px; padding: 8px; border-radius: 50%; transition: all 0.2s; }
        .theme-toggle-btn:hover { background-color: var(--hover-bg); color: var(--text-main); }
        .btn-logout { color: #ef4444; text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 6px; }

        /* === 主内容区 === */
        .main-content {
            flex: 1; padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }
        
        /* 欢迎头 */
        .welcome-section { margin-bottom: 40px; }
        .welcome-title { font-size: 28px; font-weight: 700; margin: 0; color: var(--text-main); }
        .welcome-subtitle { color: var(--text-sub); margin-top: 5px; font-size: 14px; display:flex; align-items:center; gap:10px; }
        .tag-id { background: rgba(99, 102, 241, 0.1); color: var(--primary); padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }

        /* === 数据卡片 === */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px;
        }
        .stat-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: var(--shadow);
            position: relative; overflow: hidden;
            transition: all 0.3s;
        }

        /* 挂科预警样式 (通过 C# 变量控制) */
        .stat-card.alert-mode {
            border-color: var(--danger);
            background: rgba(239, 68, 68, 0.05);
        }
        .stat-card.alert-mode .stat-icon-box { color: var(--danger); background: rgba(239, 68, 68, 0.15); }
        .stat-card.alert-mode .value { color: var(--danger); }
        .stat-card.alert-mode::after {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--danger);
        }

        .stat-info h3 { margin: 0; font-size: 15px; color: var(--text-sub); font-weight: 500; }
        .stat-info .value { font-size: 36px; font-weight: 700; color: var(--text-main); margin-top: 8px; font-family: 'Inter', sans-serif; }
        .stat-icon-box {
            width: 56px; height: 56px; border-radius: 12px;
            background: rgba(99, 102, 241, 0.1); color: var(--primary);
            display: flex; align-items: center; justify-content: center; font-size: 28px;
        }

        /* === 功能导航 === */
        .section-title { font-size: 18px; font-weight: 600; color: var(--text-main); margin-bottom: 20px; border-left: 4px solid var(--primary); padding-left: 12px; }
        
        .menu-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px;
        }

        .menu-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 30px;
            text-decoration: none; color: var(--text-main);
            display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;
            transition: all 0.3s;
            box-shadow: var(--shadow);
        }
        .menu-card:hover {
            transform: translateY(-4px);
            border-color: var(--primary);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        
        .menu-icon { font-size: 40px; margin-bottom: 15px; color: var(--text-sub); transition: color 0.3s; }
        .menu-card:hover .menu-icon { color: var(--primary); }

        .menu-title { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
        .menu-desc { font-size: 13px; color: var(--text-sub); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-graduation-cap"></i> 智慧教务 | 学生端
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>

                <div style="display:flex; align-items:center; gap:20px; font-size:14px;">
                    <span style="color:var(--text-sub);">
                        <i class="fas fa-user-circle"></i> <asp:Label ID="lblName" runat="server"></asp:Label>
                    </span>
                    <span style="color:var(--border);">|</span>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                        <i class="fas fa-sign-out-alt"></i> 退出
                    </asp:LinkButton>
                </div>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="welcome-section">
                <h1 class="welcome-title">学习概览</h1>
                <div class="welcome-subtitle">
                    学号：<span class="tag-id"><asp:Label ID="lblStuNo" runat="server"></asp:Label></span>
                    <span style="margin-left:10px;">保持专注，持续进步。</span>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-info">
                        <h3>加权平均分</h3>
                        <div class="value"><asp:Literal ID="ltlAvgScore" runat="server" Text="0.0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-chart-line"></i></div>
                </div>

                <div class="stat-card">
                    <div class="stat-info">
                        <h3>已修总学分</h3>
                        <div class="value" style="color:#10b981;"><asp:Literal ID="ltlCredits" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box" style="color:#10b981; background:rgba(16, 185, 129, 0.1);"><i class="fas fa-award"></i></div>
                </div>

                <div class="stat-card <%= HasFailed ? "alert-mode" : "" %>">
                    <div class="stat-info">
                        <h3>学业预警 / 挂科</h3>
                        <div class="value"><asp:Literal ID="ltlFailed" runat="server" Text="0"></asp:Literal></div>
                    </div>
                    <div class="stat-icon-box"><i class="fas fa-exclamation-triangle"></i></div>
                </div>
            </div>

            <div class="section-title">常用功能</div>
            <div class="menu-grid">
                <a href="CourseSelection.aspx" class="menu-card">
                    <i class="fas fa-mouse-pointer menu-icon"></i>
                    <div class="menu-title">在线选课</div>
                    <div class="menu-desc">浏览可选课程并进行选课/退课操作</div>
                </a>
                
                <a href="StudentScore.aspx" class="menu-card">
                    <i class="fas fa-file-invoice-dollar menu-icon"></i>
                    <div class="menu-title">成绩查询</div>
                    <div class="menu-desc">查看各学期成绩、绩点及学分详情</div>
                </a>
                
                <a href="StudentRetake.aspx" class="menu-card">
                    <i class="fas fa-redo-alt menu-icon"></i>
                    <div class="menu-title">补考申请</div>
                    <div class="menu-desc">针对不及格课程提交补考或重修申请</div>
                </a>
            </div>

        </div>
    </form>

    <script>
        // === 主题切换逻辑 ===
        function toggleTheme() {
            const current = document.documentElement.getAttribute('data-theme');
            const target = current === 'dark' ? 'light' : 'dark';

            document.documentElement.setAttribute('data-theme', target);
            localStorage.setItem('theme', target);
            updateIcon(target);
        }

        function updateIcon(theme) {
            const icon = document.getElementById('themeIcon');
            if (icon) icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
        }

        // 初始化
        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>