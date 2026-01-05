<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseSelection.aspx.cs" Inherits="CourseSelection" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>选课大厅 | 智慧教务系统</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
    
    <script>
        // === 1. 主题同步脚本 ===
        (function () {
            const savedTheme = localStorage.getItem('theme') || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();
    </script>

    <style>
        /* === 2. 选课中心专属样式 (星云紫主题) === */
        :root {
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --success: #10b981;
            --danger: #ef4444;
            --full: #94a3b8; /* 满员灰 */
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --bar-bg: rgba(255,255,255,0.1);
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --bar-bg: #e2e8f0;
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
            flex: 1; padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; box-sizing: border-box;
        }

        .page-header { margin-bottom: 30px; display:flex; justify-content:space-between; align-items:flex-end; }
        .page-title { font-size: 24px; font-weight: 700; margin: 0; color: var(--text-main); }
        .page-subtitle { color: var(--text-sub); margin-top: 5px; font-size: 14px; }
        .btn-back {
            color: var(--text-sub); text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; border: 1px solid var(--border); transition: all 0.2s;
        }
        .btn-back:hover { background: var(--hover-bg); color: var(--text-main); border-color: var(--text-sub); }

        /* 表格容器 */
        .table-section {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            box-shadow: var(--shadow);
        }
        .table-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .table-title { font-size: 18px; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 10px; }

        /* 课程列表 GridView */
        .custom-grid { width: 100%; border-collapse: collapse; color: var(--text-main); }
        .custom-grid th {
            text-align: left; padding: 14px 16px;
            color: var(--text-sub); font-size: 13px; font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        .custom-grid td { padding: 16px; border-bottom: 1px solid var(--border); font-size: 14px; vertical-align: middle; }
        .custom-grid tr:last-child td { border-bottom: none; }
        .custom-grid tr:hover { background-color: var(--hover-bg); }

        /* 重点字段样式 */
        .course-name { font-weight: 600; font-size: 15px; display: block; }
        .course-term { font-size: 12px; color: var(--text-sub); margin-top: 2px; display: block; }

        /* 容量进度条组件 */
        .capacity-wrapper { display: flex; flex-direction: column; gap: 6px; width: 140px; }
        .capacity-text { font-size: 12px; color: var(--text-sub); display: flex; justify-content: space-between; }
        .progress-bar-bg {
            height: 6px; background: var(--bar-bg); border-radius: 3px; overflow: hidden; width: 100%;
        }
        .progress-bar-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
        
        /* 进度条颜色逻辑 */
        .fill-normal { background: var(--primary); }
        .fill-warning { background: #f59e0b; } /* 快满了 */
        .fill-full { background: var(--danger); }

        /* 状态徽章 */
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
        .badge-selected { background: rgba(16, 185, 129, 0.15); color: var(--success); border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-full { background: rgba(239, 68, 68, 0.15); color: var(--danger); border: 1px solid rgba(239, 68, 68, 0.2); }
        
        /* 操作按钮 */
        .btn-action {
            padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none;
            display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s; border: none; cursor: pointer;
        }
        
        /* 选课按钮 (蓝色) */
        .btn-select { background: linear-gradient(135deg, var(--primary) 0%, #4f46e5 100%); color: white; box-shadow: 0 4px 10px rgba(99, 102, 241, 0.3); }
        .btn-select:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(99, 102, 241, 0.4); }

        /* 退课按钮 (红色幽灵) */
        .btn-drop { background: transparent; color: var(--danger); border: 1px solid var(--danger); }
        .btn-drop:hover { background: var(--danger); color: white; }

        /* 已满禁用 (灰色) */
        .btn-disabled { background: var(--hover-bg); color: var(--text-sub); cursor: not-allowed; border: 1px solid var(--border); }

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
                <div style="font-size:14px; color:var(--text-sub);">
                    <i class="fas fa-user-circle"></i> <asp:Label ID="lblUser" runat="server"></asp:Label>
                </div>
                <span style="color:var(--border); margin:0 10px;">|</span>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> 退出
                </asp:LinkButton>
            </div>
        </nav>

        <div class="main-content">
            
            <div class="page-header">
                <div>
                    <h1 class="page-title">可视化选课大厅</h1>
                    <p class="page-subtitle">实时查看课程容量，合理规划学期课程</p>
                </div>
                <a href="StudentHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> 返回主页</a>
            </div>

            <div class="table-section">
                <div class="table-header">
                    <div class="table-title">可选课程列表</div>
                </div>

                <asp:GridView ID="gvCourses" runat="server" CssClass="custom-grid" AutoGenerateColumns="False" 
                    OnRowCommand="gvCourses_RowCommand" GridLines="None" EmptyDataText="当前暂无开放选课的课程">
                    <Columns>
                        <asp:TemplateField HeaderText="课程信息">
                            <ItemTemplate>
                                <span class="course-name"><%# Eval("CourseName") %></span>
                                <span class="course-term"><%# Eval("Semester") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="TeacherInfo" HeaderText="任课教师" />
                        <asp:BoundField DataField="Credit" HeaderText="学分" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        
                        <%-- 可视化容量条 --%>
                        <asp:TemplateField HeaderText="容量进度">
                            <ItemTemplate>
                                <div class="capacity-wrapper">
                                    <div class="capacity-text">
                                        <span>已选: <%# Eval("CurrentCount") %></span>
                                        <span>容量: <%# Eval("MaxCapacity") %></span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <%-- 计算逻辑：防止分母为0 --%>
                                        <div class="progress-bar-fill <%# 
                                            (Convert.ToInt32(Eval("MaxCapacity")) > 0 && Convert.ToDouble(Eval("CurrentCount")) / Convert.ToDouble(Eval("MaxCapacity")) >= 1) ? "fill-full" : 
                                            (Convert.ToInt32(Eval("MaxCapacity")) > 0 && Convert.ToDouble(Eval("CurrentCount")) / Convert.ToDouble(Eval("MaxCapacity")) >= 0.8) ? "fill-warning" : "fill-normal" 
                                            %>" 
                                            style='width: <%# 
                                                Convert.ToInt32(Eval("MaxCapacity")) > 0 
                                                ? Math.Min(100, (Convert.ToDouble(Eval("CurrentCount")) / Convert.ToDouble(Eval("MaxCapacity"))) * 100) 
                                                : 100 
                                            %>%'>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 状态 (已选/空) --%>
                        <asp:TemplateField HeaderText="状态" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%# Convert.ToInt32(Eval("IsSelected")) == 1 
                                    ? "<span class='badge badge-selected'><i class='fas fa-check'></i> 已选</span>" 
                                    : (Convert.ToInt32(Eval("CurrentCount")) >= Convert.ToInt32(Eval("MaxCapacity")) ? "<span class='badge badge-full'>已满</span>" : "")
                                %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- 操作按钮 (逻辑互斥检查) --%>
                        <asp:TemplateField HeaderText="操作" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%-- 场景1: 已选 -> 显示退课 (无论是否满员，都要能退) --%>
                                <asp:LinkButton runat="server" CommandName="DropCourse" CommandArgument='<%# Eval("CourseId") %>' 
                                    CssClass="btn-action btn-drop"
                                    Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 1 %>'
                                    OnClientClick="return confirm('⚠️ 确定要退选该课程吗？\n如果已出成绩将无法退课。');">
                                    <i class="fas fa-times"></i> 退课
                                </asp:LinkButton>

                                <%-- 场景2: 未选 & 未满 -> 显示选课 --%>
                                <asp:LinkButton runat="server" CommandName="SelectCourse" CommandArgument='<%# Eval("CourseId") %>' 
                                    CssClass="btn-action btn-select"
                                    Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 0 && Convert.ToInt32(Eval("CurrentCount")) < Convert.ToInt32(Eval("MaxCapacity")) %>'>
                                    <i class="fas fa-plus"></i> 选课
                                </asp:LinkButton>

                                <%-- 场景3: 未选 & 已满 -> 显示禁用按钮 --%>
                                <asp:Label runat="server" CssClass="btn-action btn-disabled" Text="<i class='fas fa-ban'></i> 满员"
                                    Visible='<%# Convert.ToInt32(Eval("IsSelected")) == 0 && Convert.ToInt32(Eval("CurrentCount")) >= Convert.ToInt32(Eval("MaxCapacity")) %>'>
                                </asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:40px; text-align:center; color:var(--text-sub);">
                            <i class="fas fa-layer-group" style="font-size:32px; margin-bottom:10px; opacity:0.5;"></i>
                            <p>选课系统暂未开放，或没有符合条件的课程。</p>
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