<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CourseApply.aspx.cs" Inherits="CourseApply" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" data-theme="dark">
<head runat="server">
    <title>Submit New Course | 智慧教务中枢</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Rajdhani:wght@500;700&display=swap" rel="stylesheet">
    <link href="Style.css" rel="stylesheet" />
    
    <style>
        /* === 教师端主题 (蓝色/青色系) === */
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .header-title h2 { margin: 0; font-family: 'Rajdhani', sans-serif; font-weight: 700; color: #fff; }
        
        .form-container {
            max-width: 800px; margin: 0 auto;
        }

        .form-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 30px;
        }
        .form-group { margin-bottom: 25px; }
        .form-group label { display: block; color: #94a3b8; margin-bottom: 8px; font-size: 14px; letter-spacing: 0.5px; }
        
        .form-control {
            width: 100%; padding: 14px; background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(56, 189, 248, 0.2); border-radius: 8px;
            color: #fff; font-family: 'Inter', sans-serif; transition: all 0.3s;
        }
        .form-control:focus { 
            border-color: #38bdf8; outline: none; box-shadow: 0 0 15px rgba(56, 189, 248, 0.15); 
            background: rgba(15, 23, 42, 0.8);
        }

        /* 提交按钮特效 */
        .btn-submit {
            background: linear-gradient(135deg, #0284c7 0%, #0ea5e9 100%);
            color: white; border: none; padding: 15px 40px; border-radius: 8px;
            font-weight: 600; cursor: pointer; transition: all 0.3s;
            font-size: 16px; letter-spacing: 1px; display: inline-flex; align-items: center; gap: 10px;
            box-shadow: 0 4px 15px rgba(14, 165, 233, 0.3);
        }
        .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(14, 165, 233, 0.5); }

        .btn-back {
            background: rgba(255,255,255,0.05); color: #94a3b8; padding: 10px 20px; 
            border-radius: 6px; text-decoration: none; font-size: 14px; transition: color 0.2s;
        }
        .btn-back:hover { color: #fff; background: rgba(255,255,255,0.1); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="background: rgba(15, 23, 42, 0.9); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(56, 189, 248, 0.1);">
            <div style="font-family: 'Rajdhani'; font-weight: 700; font-size: 20px; color: #38bdf8;">
                <i class="fas fa-chalkboard-teacher"></i> TEACHER-HUB
            </div>
            <div style="display: flex; gap: 20px; align-items: center;">
                <span style="color: #94a3b8;"><i class="fas fa-user-circle"></i> <asp:Label ID="lblName" runat="server"></asp:Label></span>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" style="color: #ef4444; text-decoration:none;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <div class="header-title">
                    <h2>Course Application</h2>
                    <p style="color:#64748b; margin:5px 0 0 0;">Propose a new course for the upcoming semester.</p>
                </div>
                <a href="TeacherHome.aspx" class="btn-back"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            </div>

            <div class="form-container">
                <div class="form-grid">
                    <div>
                        <div class="form-group">
                            <label><i class="fas fa-book"></i> Course Name</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. Advanced Quantum Physics"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-calendar-alt"></i> Semester</label>
                            <asp:TextBox ID="txtTerm" runat="server" CssClass="form-control" placeholder="e.g. 2025-2026-1"></asp:TextBox>
                        </div>
                    </div>

                    <div>
                        <div class="form-group">
                            <label><i class="fas fa-star"></i> Credits</label>
                            <asp:TextBox ID="txtCredit" runat="server" CssClass="form-control" placeholder="e.g. 3.0" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-users"></i> Max Capacity</label>
                            <asp:TextBox ID="txtCapacity" runat="server" CssClass="form-control" placeholder="e.g. 60" TextMode="Number"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 40px; text-align: center;">
                    <asp:Button ID="btnSubmit" runat="server" Text="Submit Application" OnClick="btnSubmit_Click" CssClass="btn-submit" />
                    
                    <div style="margin-top: 20px; min-height: 30px;">
                        <asp:Label ID="lblMsg" runat="server" style="font-weight:600; font-size:15px;"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>