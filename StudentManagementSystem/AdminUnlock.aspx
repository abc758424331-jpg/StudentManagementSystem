<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminUnlock.aspx.cs" Inherits="AdminUnlock" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>成绩解锁管理 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 主题同步 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 管理员版主题 (翡翠绿 + 警示红) === */
        :root {
            --primary: #10b981;       /* Emerald 500 */
            --primary-hover: #059669;
            --danger: #ef4444;        /* Red 500 */
            --warning: #f59e0b;       /* Amber 500 */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0b1120;
            --bg-card: #1e293b;
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --input-bg: #0f172a;
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --input-bg: #f8fafc;
        }

        body {
            margin: 0; padding: 0;
            background-color: var(--bg-body);
            color: var(--text-main);
            font-family: 'Noto Sans SC', 'Inter', sans-serif;
            transition: background-color 0.3s;
        }

        form { display: flex; flex-direction: column; min-height: 100vh; }

        /* 导航栏 */
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

        /* 主内容区 */
        .main-content {
            flex: 1; padding: 40px; max-width: 1200px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }

        .page-header { margin-bottom: 30px; display:flex; justify-content:space-between; align-items:center; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .btn-back {
            color: var(--text-sub); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; border: 1px solid var(--border); transition: all 0.2s;
        }
        .btn-back:hover { background: var(--hover-bg); color: var(--text-main); border-color: var(--text-sub); }

        /* 搜索栏卡片 */
        .search-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 20px; margin-bottom: 24px;
            display: flex; gap: 15px; align-items: center;
            box-shadow: var(--shadow);
        }
        .search-input {
            flex: 1; background: var(--input-bg); border: 1px solid var(--border);
            padding: 10px 15px; border-radius: 8px; color: var(--text-main);
            font-size: 14px; outline: none; transition: border-color 0.2s;
        }
        .search-input:focus { border-color: var(--primary); }
        
        .btn-search {
            background: var(--primary); color: white; border: none;
            padding: 10px 24px; border-radius: 8px; cursor: pointer;
            font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 8px;
            transition: opacity 0.2s;
        }
        .btn-search:hover { opacity: 0.9; }

        /* 表格区域 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }

        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 锁定状态徽章 */
        .badge-locked {
            background: rgba(239, 68, 68, 0.1); color: var(--danger);
            padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;
            display: inline-flex; align-items: center; gap: 5px; border: 1px solid rgba(239, 68, 68, 0.2);
        }

        /* 组合信息 */
        .info-group { display: flex; flex-direction: column; }
        .info-main { font-weight: 600; font-size: 15px; }
        .info-sub { font-size: 12px; color: var(--text-sub); margin-top: 2px; }

        /* 解锁按钮 */
        .btn-unlock {
            background: transparent; color: var(--primary);
            border: 1px solid var(--primary); padding: 6px 14px; border-radius: 6px;
            font-size: 13px; font-weight: 600; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s;
        }
        .btn-unlock:hover { background: var(--primary); color: white; box-shadow: 0 4px 10px rgba(16, 185, 129, 0.3); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-lock-open"></i> 成绩解锁管理
            </div>
            
            <div class="nav-right">
                <button type="button" class="theme-toggle-btn" onclick="toggleTheme()" title="切换主题">
                    <i class="fas fa-adjust" id="themeIcon"></i>
                </button>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> 退出
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <div>
                    <h1 class="page-title">特殊流程处理</h1>
                    <div style="color:var(--text-sub); margin-top:5px; font-size:14px;">
                        处理教师提交的成绩修改请求，解除课程的归档锁定状态
                    </div>
                </div>
                <a href="Default.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回总控台</a>
            </div>

            <div class="search-card">
                <i class="fas fa-search" style="color:var(--text-sub)"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="输入课程名称或教师姓名进行查找..."></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="搜索课程" OnClick="btnSearch_Click" CssClass="btn-search" />
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">已锁定课程列表</div>
                </div>

                <asp:GridView ID="gvLockedCourses" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvLockedCourses_RowCommand" GridLines="None" EmptyDataText="👏 当前没有被锁定的课程记录。">
                    <Columns>
                        <asp:TemplateField HeaderText="课程信息">
                            <ItemTemplate>
                                <div class="info-group">
                                    <span class="info-main"><%# Eval("CourseName") %></span>
                                    <span class="info-sub"><%# Eval("Semester") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="任课教师">
                            <ItemTemplate>
                                <div class="info-group">
                                    <span class="info-main"><%# Eval("TeacherName") %></span>
                                    <span class="info-sub">工号: <%# Eval("WorkNo") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="状态" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span class="badge-locked"><i class="fas fa-lock"></i> 已归档</span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="影响范围" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span style="font-weight:600;"><%# Eval("StudentCount") %></span> 名学生
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="操作" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnUnlock" runat="server" CommandName="Unlock" CommandArgument='<%# Eval("CourseId") %>' 
                                    CssClass="btn-unlock"
                                    OnClientClick="return confirm('⚠️ 确定要解锁该课程吗？\n解锁后，教师将可以重新修改所有学生的成绩。');">
                                    <i class="fas fa-key"></i> 解锁录入
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:60px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-folder-open" style="font-size:48px; margin-bottom:15px; opacity:0.3;"></i>
                            <p style="font-size:16px;">没有找到符合条件的锁定记录。</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>

    <script>
        // === 主题切换 ===
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

        const saved = localStorage.getItem('theme') || 'dark';
        updateIcon(saved);
    </script>
</body>
</html>