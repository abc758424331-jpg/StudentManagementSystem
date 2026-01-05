<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseApproval.aspx.cs" Inherits="CourseApproval" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>新课审批 | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* === 复用管理员主题 (绿色系) === */
        :root { --ease-smooth: cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        [data-theme="dark"] {
            --bg-color: #0b1120;
            --bg-gradient: radial-gradient(circle at 50% 50%, #1e293b 0%, #0b1120 100%);
            --glass-panel: rgba(30, 41, 59, 0.75);
            --glass-border: rgba(255, 255, 255, 0.1);
            --text-main: #f8fafc;
            --text-sub: #94a3b8;
            --primary: #10b981; /* 审批主色：绿色 */
            --danger: #ef4444;
            --table-hover: rgba(16, 185, 129, 0.05);
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
            height: 70px; padding: 0 40px; background: var(--glass-panel); border-bottom: 1px solid var(--glass-border);
            display: flex; align-items: center; justify-content: space-between; position: fixed; top: 0; width: 100%; z-index: 1000; box-sizing: border-box;
        }
        .brand { font-family: 'Rajdhani'; font-weight: 700; font-size: 24px; color: var(--primary); text-decoration: none; display: flex; gap: 10px; align-items: center; }
        .btn-back { color: var(--text-sub); text-decoration: none; border: 1px solid var(--glass-border); padding: 8px 16px; border-radius: 6px; font-size: 13px; }

        .main-container { max-width: 1100px; margin: 100px auto 50px; padding: 0 20px; }

        .page-header { margin-bottom: 30px; border-bottom: 1px solid var(--glass-border); padding-bottom: 20px; }
        .page-header h2 { font-family: 'Rajdhani'; font-size: 32px; color: var(--primary); margin: 0; }
        .page-header p { color: var(--text-sub); margin-top: 5px; }

        /* 表格 */
        .grid-container { background: var(--glass-panel); border: 1px solid var(--glass-border); border-radius: 16px; overflow: hidden; }
        .cyber-grid { width: 100%; border-collapse: collapse; }
        .cyber-grid th { background: rgba(0,0,0,0.2); color: var(--text-sub); padding: 20px; text-align: left; font-size: 12px; border-bottom: 1px solid var(--glass-border); }
        .cyber-grid td { padding: 20px; color: var(--text-main); border-bottom: 1px solid var(--glass-border); font-size: 14px; vertical-align: middle; }
        .cyber-grid tr:hover td { background: var(--table-hover); }

        /* 按钮 */
        .btn-approve { background: rgba(16, 185, 129, 0.1); color: var(--primary); border: 1px solid var(--primary); padding: 6px 15px; border-radius: 6px; cursor: pointer; font-weight: 700; transition:0.3s; margin-right: 10px; }
        .btn-approve:hover { background: var(--primary); color: #fff; }

        .btn-reject { background: rgba(239, 68, 68, 0.1); color: var(--danger); border: 1px solid var(--danger); padding: 6px 15px; border-radius: 6px; cursor: pointer; font-weight: 700; transition:0.3s; }
        .btn-reject:hover { background: var(--danger); color: #fff; }
    </style>
</head>
<body>
    <canvas id="particle-canvas"></canvas>
    <form id="form1" runat="server">
        <div class="navbar">
            <a href="#" class="brand"><i class="fas fa-gavel"></i> COURSE APPROVAL</a>
            <a href="Default.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> Dashboard</a>
        </div>

        <div class="main-container">
            <div class="page-header">
                <h2>审批中课程</h2>
                <p>Review new course proposals from faculty. Approve to publish or Reject to delete.</p>
            </div>

            <div class="grid-container">
                <asp:GridView ID="gvApproval" runat="server" AutoGenerateColumns="False" 
                    DataKeyNames="CourseId" CssClass="cyber-grid" GridLines="None"
                    OnRowCommand="gvApproval_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="CourseName" HeaderText="COURSE NAME" ItemStyle-Font-Bold="true" />
                        <asp:TemplateField HeaderText="APPLICANT">
                            <ItemTemplate>
                                <%# Eval("TeacherName") %> <span style="color:#666; font-size:12px;">(<%# Eval("WorkNo") %>)</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Credit" HeaderText="CREDIT" />
                        <asp:BoundField DataField="Semester" HeaderText="TERM" />
                        <asp:BoundField DataField="MaxCapacity" HeaderText="CAPACITY" />
                        
                        <asp:TemplateField HeaderText="ACTIONS" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:Button ID="btnApprove" runat="server" Text="APPROVE" 
                                    CommandName="Pass" CommandArgument='<%# Eval("CourseId") %>'
                                    CssClass="btn-approve" />
                                <asp:Button ID="btnReject" runat="server" Text="REJECT" 
                                    CommandName="Reject" CommandArgument='<%# Eval("CourseId") %>'
                                    CssClass="btn-reject" 
                                    OnClientClick="return confirm('Permanently delete this application?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding:60px; text-align:center; color:#64748b;">
                            <i class="fas fa-check-circle" style="font-size:40px; margin-bottom:15px; color:#10b981;"></i>
                            <p>No pending applications. All systems nominal.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>
    
    <script>
        // 简单的粒子背景
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth; canvas.height = window.innerHeight;
        const particles = Array.from({ length: 50 }, () => ({
            x: Math.random() * canvas.width, y: Math.random() * canvas.height,
            vx: (Math.random() - 0.5) * 0.5, vy: (Math.random() - 0.5) * 0.5, size: Math.random() * 2
        }));
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.x += p.vx; p.y += p.vy;
                if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
                if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
                ctx.beginPath(); ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
                ctx.fillStyle = 'rgba(16, 185, 129, 0.3)'; ctx.fill();
            });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>