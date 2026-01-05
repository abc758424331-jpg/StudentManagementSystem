<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TeacherGrade.aspx.cs" Inherits="TeacherGrade" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>成绩录入 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet" />
    
    <style>
        /* === 1. 核心主题变量 === */
        :root { --ease-out: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #0ea5e9;
            --accent: #8b5cf6;
            --success: #10b981; 
            --table-hover: rgba(14, 165, 233, 0.05);
        }

        body {
            margin: 0; padding: 0;
            background: var(--bg-color); background-image: var(--bg-gradient);
            color: var(--text-main); font-family: 'Inter', sans-serif;
            overflow-x: hidden; min-height: 100vh;
        }

        #particle-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }

        /* 导航 */
        .navbar {
            height: 70px; padding: 0 40px;
            background: var(--glass-panel); border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between;
            position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand {
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 24px;
            letter-spacing: 2px; color: var(--text-main); text-decoration: none;
            display: flex; gap: 10px; align-items: center;
        }
        .btn-back {
            background: transparent; border: 1px solid var(--glass-border); color: var(--text-sub);
            padding: 8px 20px; border-radius: 8px; cursor: pointer; transition: 0.3s;
            font-size: 13px; text-decoration: none; display: flex; gap: 8px; align-items: center;
        }
        .btn-back:hover { background: var(--glass-border); color: var(--text-main); }

        .main-container { max-width: 1200px; margin: 100px auto 50px; padding: 0 20px; }

        /* 头部卡片 */
        .header-card {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; padding: 30px; margin-bottom: 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .course-title h2 { font-family: 'Rajdhani'; font-size: 32px; color: var(--primary); margin: 0; letter-spacing: 1px; }
        .course-meta { color: var(--text-sub); margin-top: 5px; font-size: 14px; }
        .weight-info { display: flex; gap: 20px; }
        .weight-item { text-align: center; }
        .weight-val { font-family: 'Rajdhani'; font-weight: 700; font-size: 24px; color: var(--accent); }
        .weight-lbl { font-size: 11px; color: var(--text-sub); text-transform: uppercase; letter-spacing: 1px; }

        /* 表格 */
        .grid-container {
            background: var(--glass-panel); border: 1px solid var(--glass-border);
            border-radius: 16px; overflow: hidden; padding: 5px;
        }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th {
            background: rgba(0,0,0,0.2); color: var(--text-sub); padding: 15px; text-align: left;
            font-size: 12px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid var(--glass-border);
        }
        .cyber-grid td {
            padding: 15px; color: var(--text-main); border-bottom: 1px solid var(--glass-border);
            font-size: 14px; vertical-align: middle;
        }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 输入框样式 */
        .grade-input {
            background: rgba(0,0,0,0.2); border: 1px solid var(--glass-border); color: #fff;
            padding: 8px 12px; border-radius: 6px; width: 50px; text-align: center;
            font-family: 'Rajdhani', sans-serif; font-weight: 700; font-size: 16px;
            transition: 0.3s; outline: none;
        }
        .grade-input:focus { border-color: var(--primary); background: rgba(14, 165, 233, 0.1); box-shadow: 0 0 10px rgba(14, 165, 233, 0.3); }

        /* 禁用状态 */
        .grade-input.disabled {
            background: rgba(255, 255, 255, 0.05) !important;
            color: #555 !important;
            border-color: transparent !important;
            cursor: not-allowed;
        }

        .total-score { font-family: 'Rajdhani'; font-weight: 700; font-size: 18px; color: var(--primary); }

        /* 单行保存按钮 */
        .btn-row-save {
            background: rgba(16, 185, 129, 0.1); color: var(--success); border: 1px solid var(--success);
            padding: 6px 15px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 700; transition: 0.3s;
        }
        .btn-row-save:hover { background: var(--success); color: #fff; box-shadow: 0 0 10px rgba(16, 185, 129, 0.4); }

    </style>
</head>
<body>
    <canvas id="particle-canvas"></canvas>

    <form id="form1" runat="server">
    <div class="navbar">
        <a href="#" class="brand">
            <i class="fas fa-edit"></i> GRADE MATRIX
        </a>
        <a href="TeacherHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> Return</a>
    </div>

    <div class="main-container">
        <div class="header-card">
            <div class="course-title">
                <h2><asp:Label ID="lblCourseName" runat="server">Course Name</asp:Label></h2>
                <div class="course-meta">ID: <asp:Label ID="lblCourseId" runat="server"></asp:Label> | Single Entry Mode</div>
            </div>
            <div class="weight-info">
                <div class="weight-item"><span class="weight-val"><asp:Label ID="lblWReg" runat="server">0</asp:Label>%</span><div class="weight-lbl">Regular</div></div>
                <div class="weight-item"><span class="weight-val"><asp:Label ID="lblWHwk" runat="server">0</asp:Label>%</span><div class="weight-lbl">Homework</div></div>
                <div class="weight-item"><span class="weight-val"><asp:Label ID="lblWMid" runat="server">0</asp:Label>%</span><div class="weight-lbl">Midterm</div></div>
                <div class="weight-item"><span class="weight-val"><asp:Label ID="lblWFin" runat="server">0</asp:Label>%</span><div class="weight-lbl">Final</div></div>
            </div>
        </div>

        <div class="grid-container">
            <asp:GridView ID="gvGrades" runat="server" AutoGenerateColumns="False" DataKeyNames="ScoreId"
                CssClass="cyber-grid" GridLines="None" 
                OnRowCommand="GvGrades_RowCommand"
                OnRowDataBound="GvGrades_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="StuNumber" HeaderText="ID" ReadOnly="true" />
                    <asp:BoundField DataField="Name" HeaderText="STUDENT NAME" ReadOnly="true" ItemStyle-Font-Bold="true" />
                    
                    <%-- 平时成绩 --%>
                    <asp:TemplateField HeaderText="REGULAR">
                        <ItemTemplate>
                            <asp:TextBox ID="txtReg" runat="server" CssClass="grade-input" Text='<%# Eval("ScoreRegular") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 作业成绩 --%>
                    <asp:TemplateField HeaderText="HOMEWORK">
                        <ItemTemplate>
                            <asp:TextBox ID="txtHwk" runat="server" CssClass="grade-input" Text='<%# Eval("ScoreHomework") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 期中成绩 --%>
                    <asp:TemplateField HeaderText="MIDTERM">
                        <ItemTemplate>
                            <asp:TextBox ID="txtMid" runat="server" CssClass="grade-input" Text='<%# Eval("ScoreMidterm") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 期末成绩 --%>
                    <asp:TemplateField HeaderText="FINAL">
                        <ItemTemplate>
                            <asp:TextBox ID="txtFin" runat="server" CssClass="grade-input" Text='<%# Eval("ScoreFinal") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 总分 (只读) --%>
                    <asp:TemplateField HeaderText="TOTAL">
                        <ItemTemplate>
                            <span class="total-score"><%# Eval("Score") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- 单行保存按钮 --%>
                    <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Button ID="btnSaveOne" runat="server" Text="SAVE" 
                                CommandName="SaveOne" CommandArgument='<%# Container.DataItemIndex %>'
                                CssClass="btn-row-save" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
    </form>

    <script>
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