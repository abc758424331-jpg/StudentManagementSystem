<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TeacherHome.aspx.cs" Inherits="TeacherHome" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>教师工作台 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 1. 核心主题变量 === */
        :root {
            --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #0ea5e9; /* 天空蓝 */
            --accent: #8b5cf6;  /* 紫色 */
            --danger: #ef4444;
            --warning: #f59e0b; /* 橙色 (用于审核中) */
            --success: #10b981; /* 绿色 (用于已激活) */
            --table-hover: rgba(14, 165, 233, 0.05);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
        }

        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }
        .fade-in { animation: fadeIn 0.8s var(--ease-smooth) forwards; opacity: 0; transform: translateY(20px); }
        @keyframes fadeIn { to { opacity: 1; transform: translateY(0); } }

        /* 导航栏 */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel); backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main); text-decoration: none;
            display: flex; align-items: center; gap: 10px;
        }
        .brand i { color: var(--primary); }

        .btn-logout {
            background: transparent; border: 1px solid var(--danger); color: var(--danger);
            padding: 6px 16px; border-radius: 6px; cursor: pointer; transition: 0.3s;
            font-size: 12px; letter-spacing: 1px; font-weight: 600;
        }
        .btn-logout:hover { background: var(--danger); color: #fff; box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }

        /* 主界面 */
        .main-container { max-width: 1200px; margin: 110px auto 50px; padding: 0 20px; }

        .welcome-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .welcome-header h1 { font-family: 'Rajdhani'; font-size: 42px; margin: 0; letter-spacing: 2px; }
        .welcome-header p { color: var(--text-sub); margin-top: 5px; font-size: 16px; }
        
        /* HUD 仪表盘 */
        .dashboard-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; margin-bottom: 40px;
        }
        
        .hud-card {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 25px; display: flex; align-items: center; gap: 20px;
            transition: 0.3s; cursor: pointer; text-decoration: none; position: relative; overflow: hidden;
        }
        .hud-card:hover { transform: translateY(-5px); border-color: var(--primary); }
        
        /* 红色警报样式 (用于待办提醒) */
        .card-alert { border-color: var(--danger) !important; box-shadow: 0 0 20px rgba(239, 68, 68, 0.2); }
        .card-alert .hud-icon { color: var(--danger) !important; animation: pulseRed 2s infinite; }
        .card-alert .value { color: var(--danger) !important; }
        @keyframes pulseRed { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

        .hud-icon {
            width: 60px; height: 60px; border-radius: 16px; background: rgba(255,255,255,0.05);
            display: flex; align-items: center; justify-content: center; font-size: 28px; color: var(--text-sub);
        }
        .hud-info h4 { margin: 0; font-size: 12px; color: var(--text-sub); text-transform: uppercase; letter-spacing: 1px; }
        .hud-info .value { font-family: 'Rajdhani'; font-size: 36px; font-weight: 700; color: var(--text-main); display: block; margin-top: 5px; }

        /* 课程列表 */
        .section-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
        .section-title { font-family: 'Rajdhani'; font-size: 24px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 10px; }
        
        .cyber-select {
            background: rgba(0,0,0,0.3); border: 1px solid var(--glass-border); color: var(--text-main);
            padding: 8px 15px; border-radius: 6px; outline: none; cursor: pointer; min-width: 150px;
        }

        .grid-container {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; min-height: 300px;
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub); padding: 20px; text-align: left;
            font-size: 12px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 20px; color: var(--text-main); border-bottom: 1px solid var(--glass-border);
            font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 状态徽章 */
        .badge { padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; }
        .badge-active { background: rgba(16, 185, 129, 0.1); color: var(--success); border: 1px solid var(--success); }
        .badge-pending { background: rgba(245, 158, 11, 0.1); color: var(--warning); border: 1px solid var(--warning); }

        /* 操作按钮 */
        .btn-action {
            padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; cursor: pointer;
            transition: 0.2s; border: none; margin-right: 5px; color: #fff;
        }
        .btn-config { background: rgba(139, 92, 246, 0.2); color: var(--accent); border: 1px solid var(--accent); }
        .btn-config:hover { background: var(--accent); color: #fff; }
        
        .btn-grade { background: rgba(14, 165, 233, 0.2); color: var(--primary); border: 1px solid var(--primary); }
        .btn-grade:hover { background: var(--primary); color: #fff; }

        .btn-new-course {
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
            background: var(--primary); color: #fff; padding: 10px 20px; border-radius: 8px; font-size: 14px; font-weight: 700;
            box-shadow: 0 0 15px rgba(14, 165, 233, 0.4); transition: 0.3s;
        }
        .btn-new-course:hover { transform: translateY(-2px); box-shadow: 0 0 25px rgba(14, 165, 233, 0.6); }
    </style>
</head>
<body>
    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    
    <div class="navbar fade-in">
        <a href="#" class="brand">
            <i class="fas fa-chalkboard-teacher"></i> TEACHER <span style="font-weight:300; opacity:0.6; font-size:14px; margin-left:5px;">CONSOLE</span>
        </a>
        <asp:Button ID="btnLogout" runat="server" Text="LOGOUT" OnClick="btnLogout_Click" CssClass="btn-logout" />
    </div>

    <div class="main-container fade-in">
        
        <div class="welcome-header">
            <div>
                <h1>WELCOME, <span style="color:var(--primary);"><asp:Label ID="lblName" runat="server"></asp:Label></span></h1>
                <p>System Online. Manage your courses and grading protocols.</p>
            </div>
            <div>
                <a href="CourseApply.aspx" class="btn-new-course">
                    <i class="fas fa-plus-circle"></i> NEW COURSE APPLICATION
                </a>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="hud-card">
                <div class="hud-icon"><i class="fas fa-book-open"></i></div>
                <div class="hud-info"><h4>My Courses</h4><asp:Literal ID="ltlCourseCount" runat="server">0</asp:Literal></div>
            </div>
            <div class="hud-card">
                <div class="hud-icon"><i class="fas fa-user-graduate"></i></div>
                <div class="hud-info"><h4>Total Students</h4><asp:Literal ID="ltlStudentCount" runat="server">0</asp:Literal></div>
            </div>
            
            <asp:Panel ID="pnlTodo" runat="server" CssClass="hud-card">
                <a href="RetakeManage.aspx" style="text-decoration:none; width:100%; height:100%; display:flex; align-items:center; gap:20px;">
                    <div class="hud-icon"><i class="fas fa-tasks"></i></div>
                    <div class="hud-info">
                        <h4>Retake Requests</h4>
                        <span class="value"><asp:Literal ID="ltlTodoCount" runat="server">0</asp:Literal></span>
                    </div>
                </a>
            </asp:Panel>
        </div>

        <div class="section-header">
            <div class="section-title"><i class="fas fa-layer-group"></i> COURSE MANAGEMENT</div>
            <asp:DropDownList ID="ddlTerm" runat="server" CssClass="cyber-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTerm_SelectedIndexChanged">
            </asp:DropDownList>
        </div>

        <div class="grid-container">
            <asp:GridView ID="gvMyCourses" runat="server" AutoGenerateColumns="False" 
                DataKeyNames="CourseId" CssClass="cyber-grid" GridLines="None"
                OnRowCommand="gvMyCourses_RowCommand">
                <Columns>
                    <asp:BoundField DataField="CourseName" HeaderText="COURSE NAME" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="Credit" HeaderText="CREDIT" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="MaxCapacity" HeaderText="CAPACITY" ItemStyle-HorizontalAlign="Center" />
                    
                    <%-- [关键新增] 审批状态列 --%>
                    <asp:TemplateField HeaderText="STATUS" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <%# GetStatusHtml(Eval("Status")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 操作列 (智能显示) --%>
                    <asp:TemplateField HeaderText="ACTIONS" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Panel ID="pnlActions" runat="server" Visible='<%# Convert.ToInt32(Eval("Status")) == 1 %>'>
                                <asp:Button ID="btnConfig" runat="server" Text="CONFIG" 
                                    CommandName="Config" CommandArgument='<%# Eval("CourseId") %>'
                                    CssClass="btn-action btn-config" ToolTip="Set Weights" />
                                
                                <asp:Button ID="btnGrade" runat="server" Text="GRADE" 
                                    CommandName="Grade" CommandArgument='<%# Eval("CourseId") %>'
                                    CssClass="btn-action btn-grade" ToolTip="Enter Grades" />
                            </asp:Panel>
                            
                            <asp:Label ID="lblWait" runat="server" Text="WAITING ADMIN..." 
                                Visible='<%# Convert.ToInt32(Eval("Status")) == 0 %>'
                                style="font-size:12px; color:var(--text-sub); font-style:italic; letter-spacing:1px;">
                            </asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding:60px; text-align:center; color:var(--text-sub);">
                        <i class="fas fa-folder-open" style="font-size:40px; margin-bottom:15px; opacity:0.5;"></i>
                        <p>No courses found for this term.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

    </div>
    </form>

    <script>
        // === 粒子特效 (复用) ===
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let width, height, particles = [];

        function resize() { width = canvas.width = window.innerWidth; height = canvas.height = window.innerHeight; }
        class Particle {
            constructor() { this.x = Math.random() * width; this.y = Math.random() * height; this.vx = (Math.random() - .5) * 0.5; this.vy = (Math.random() - .5) * 0.5; this.size = Math.random() * 2; }
            update() { this.x += this.vx; this.y += this.vy; if (this.x < 0 || this.x > width) this.vx *= -1; if (this.y < 0 || this.y > height) this.vy *= -1; }
            draw() { ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fillStyle = 'rgba(14, 165, 233, 0.3)'; ctx.fill(); }
        }
        function init() { particles = []; for (let i = 0; i < 60; i++) particles.push(new Particle()); }
        function animate() { ctx.clearRect(0, 0, width, height); particles.forEach(p => { p.update(); p.draw(); }); requestAnimationFrame(animate); }

        window.addEventListener('resize', () => { resize(); init(); }); resize(); init(); animate();
    </script>
</body>
</html>