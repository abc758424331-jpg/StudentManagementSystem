<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseConfig.aspx.cs" Inherits="CourseConfig" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>课程权重配置 | 智慧教务系统</title>
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
        /* === 2. 教师版主题 (天际蓝) === */
        :root {
            --primary: #0ea5e9;       /* Sky Blue */
            --primary-hover: #0284c7;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --text-main: #f1f5f9;
            --text-sub: #94a3b8;
            --border: #334155;
            --hover-bg: rgba(255,255,255,0.05);
            --input-bg: #0f172a;
            --track-bg: #334155;
        }

        [data-theme="light"] {
            --bg-body: #f1f5f9;
            --bg-card: #ffffff;
            --text-main: #1e293b;
            --text-sub: #64748b;
            --border: #e2e8f0;
            --hover-bg: #f8fafc;
            --input-bg: #f8fafc;
            --track-bg: #e2e8f0;
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
            flex: 1; padding: 40px; max-width: 800px; margin: 0 auto; width: 100%; box-sizing: border-box;
            display: flex; flex-direction: column; justify-content: center;
        }

        .page-header { margin-bottom: 40px; text-align: center; }
        .page-title { font-size: 28px; font-weight: 700; margin: 0; color: var(--text-main); }
        .page-subtitle { color: var(--text-sub); margin-top: 10px; font-size: 15px; }

        /* 配置卡片 */
        .config-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px; padding: 40px;
            box-shadow: var(--shadow);
        }

        .course-badge {
            background: rgba(14, 165, 233, 0.1); color: var(--primary);
            padding: 5px 12px; border-radius: 20px; font-size: 13px; font-weight: 600;
            display: inline-block; margin-bottom: 20px;
        }

        /* 权重输入区 */
        .ratio-control-group {
            display: flex; align-items: center; justify-content: space-between; gap: 30px; margin-bottom: 30px;
        }
        
        .ratio-item { flex: 1; text-align: center; }
        .ratio-label { font-size: 14px; color: var(--text-sub); margin-bottom: 10px; display: block; font-weight: 500; }
        .ratio-input-wrapper { position: relative; display: inline-block; width: 100%; }
        
        .form-control {
            width: 100%; padding: 15px; text-align: center;
            background: var(--input-bg); border: 2px solid var(--border);
            border-radius: 12px; color: var(--text-main);
            font-size: 24px; font-weight: 700; font-family: 'Inter', sans-serif;
            transition: all 0.3s; box-sizing: border-box;
        }
        .form-control:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.15); }
        .unit-percent {
            position: absolute; right: 20px; top: 50%; transform: translateY(-50%);
            color: var(--text-sub); font-weight: 600;
        }

        .operator { font-size: 24px; color: var(--text-sub); font-weight: 700; margin-top: 25px; }

        /* 可视化进度条 */
        .visual-bar-container {
            height: 12px; background: var(--track-bg); border-radius: 6px; overflow: hidden;
            display: flex; margin-bottom: 40px;
        }
        .bar-regular { height: 100%; background: var(--primary); transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .bar-final { height: 100%; background: var(--success); transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1); }

        /* 底部按钮 */
        .action-area { display: flex; gap: 15px; }
        .btn-save {
            flex: 2; background: linear-gradient(135deg, var(--primary) 0%, #0284c7 100%);
            color: white; border: none; padding: 14px; border-radius: 8px;
            font-size: 16px; font-weight: 600; cursor: pointer; transition: transform 0.2s;
            box-shadow: 0 4px 15px rgba(14, 165, 233, 0.3);
        }
        .btn-save:hover { transform: translateY(-2px); }
        
        .btn-back {
            flex: 1; background: transparent; border: 1px solid var(--border);
            color: var(--text-sub); padding: 14px; border-radius: 8px;
            font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s;
        }
        .btn-back:hover { border-color: var(--text-main); color: var(--text-main); }

        /* 校验提示 */
        .validation-msg {
            text-align: center; margin-top: 15px; font-size: 14px; min-height: 20px;
        }
        .msg-error { color: var(--danger); }
        .msg-ok { color: var(--success); }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="brand">
                <i class="fas fa-sliders-h"></i> 课程配置中心
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
                <h1 class="page-title">总评成绩构成设置</h1>
                <p class="page-subtitle">调整平时成绩与期末考试在总评中的权重比例</p>
            </div>

            <div class="config-card">
                <div style="text-align:center;">
                    <div class="course-badge">
                        <i class="fas fa-book"></i> 当前课程：<asp:Label ID="lblCourseName" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="ratio-control-group">
                    <div class="ratio-item">
                        <label class="ratio-label">平时成绩占比 (Regular)</label>
                        <div class="ratio-input-wrapper">
                            <asp:TextBox ID="txtRegular" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" max="100" 
                                oninput="syncWeights('regular')" placeholder="50"></asp:TextBox>
                            <span class="unit-percent">%</span>
                        </div>
                    </div>

                    <div class="operator">+</div>

                    <div class="ratio-item">
                        <label class="ratio-label">期末成绩占比 (Final)</label>
                        <div class="ratio-input-wrapper">
                            <asp:TextBox ID="txtFinal" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" max="100" 
                                oninput="syncWeights('final')" placeholder="50"></asp:TextBox>
                            <span class="unit-percent">%</span>
                        </div>
                    </div>

                    <div class="operator">=</div>

                    <div class="ratio-item" style="flex: 0.5;">
                        <label class="ratio-label">总计</label>
                        <div style="font-size: 24px; font-weight: 700; color:var(--text-main); padding: 15px;">100%</div>
                    </div>
                </div>

                <div class="visual-bar-container">
                    <div id="barRegular" class="bar-regular" style="width: 50%;"></div>
                    <div id="barFinal" class="bar-final" style="width: 50%;"></div>
                </div>

                <div class="validation-msg">
                    <span id="lblTip" class="msg-ok"><i class="fas fa-check-circle"></i> 配置合法，可以保存</span>
                </div>

                <div class="action-area" style="margin-top:30px;">
                    <asp:Button ID="btnBack" runat="server" Text="取消返回" OnClick="btnBack_Click" CssClass="btn-back" />
                    <asp:Button ID="btnSave" runat="server" Text="保存配置" OnClick="btnSave_Click" CssClass="btn-save" OnClientClick="return validateForm();" />
                </div>
            </div>

        </div>
    </form>

    <script>
        // === 1. 权重联动与校验逻辑 ===
        function syncWeights(source) {
            const txtReg = document.getElementById('<%= txtRegular.ClientID %>');
            const txtFin = document.getElementById('<%= txtFinal.ClientID %>');
            const barReg = document.getElementById('barRegular');
            const barFin = document.getElementById('barFinal');
            const lblTip = document.getElementById('lblTip');

            let regVal = parseInt(txtReg.value) || 0;
            let finVal = parseInt(txtFin.value) || 0;

            // 逻辑自查：输入限制，防止超过100
            if (regVal > 100) regVal = 100;
            if (finVal > 100) finVal = 100;

            // 联动逻辑：改平时->算期末；改期末->算平时
            if (source === 'regular') {
                finVal = 100 - regVal;
                // 防止负数
                if (finVal < 0) { finVal = 0; regVal = 100; }
                txtFin.value = finVal;
                // 此时 regVal 可能被修正，这里暂不回写 txtReg 以免干扰输入体验，但进度条要准
            } else if (source === 'final') {
                regVal = 100 - finVal;
                if (regVal < 0) { regVal = 0; finVal = 100; }
                txtReg.value = regVal;
            }

            // 更新进度条
            barReg.style.width = regVal + '%';
            barFin.style.width = finVal + '%';

            // 实时状态提示
            if (regVal + finVal === 100) {
                lblTip.innerHTML = '<i class="fas fa-check-circle"></i> 配置合法，可以保存';
                lblTip.className = 'msg-ok';
                document.getElementById('<%= btnSave.ClientID %>').disabled = false;
                document.getElementById('<%= btnSave.ClientID %>').style.opacity = "1";
            } else {
                lblTip.innerHTML = '<i class="fas fa-exclamation-triangle"></i> 总和必须等于 100%';
                lblTip.className = 'msg-error';
                // 可以在这里禁用按钮，但为了让后端也拦截，暂不强制禁用
            }
        }

        // 提交前最后校验
        function validateForm() {
            const txtReg = document.getElementById('<%= txtRegular.ClientID %>');
            const txtFin = document.getElementById('<%= txtFinal.ClientID %>');
            const sum = (parseInt(txtReg.value) || 0) + (parseInt(txtFin.value) || 0);

            if (sum !== 100) {
                alert('⚠️ 逻辑错误：平时成绩与期末成绩之和必须等于 100！\n当前总和: ' + sum);
                return false;
            }
            return true;
        }

        // 初始化视觉状态
        window.onload = function () {
            // 手动触发一次计算以更新进度条
            syncWeights('regular');

            // 主题图标初始化
            const saved = localStorage.getItem('theme') || 'dark';
            updateIcon(saved);
        };

        // === 2. 主题切换 ===
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
    </script>
</body>
</html>