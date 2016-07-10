<!DOCTYPE html >
<html >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>华为FSU产品协议包管理系统</title>

<link href='${BasePath}/css/login_new.css' rel='stylesheet' type='text/css' />

<script type="text/javascript">
	var BasePath="${BasePath}";
</script>
<style>
input{
line-height:35px;
height:35px;
}
 .sign_logo{
    padding-top: 210px;
    text-align: center;
    width: 387px;
    overflow: hidden;
    margin: 0 auto;
    }
.sign_logo img{
      float: left;
        }
</style>
</head>
<body>
<div class="sign_bao">
  <div class="sign_top">
    <div class="sign_logo"><img src='${BasePath}/images/huewei_logo.png'/><p>华为FSU产品协议包管理系统</p></div>
    <div class="sign_box">
		      <div class="sign_box_title">登录</div>
		      <form  role="form" action="login.kq" method="post">
			      <div class="sign_box_body">
				        <div class="denglv"> <i class="i-login-e"></i>
				          <input type="text" id="username" name="username"  placeholder="用户名" required autofocus><br>
				        </div>
				        <div class="mima"> <i class="i-login-e"></i>
				           <input type="password" id="password" name="password"  placeholder="密码" required>
				        </div>
			      </div>
			      <div class="sign_clear">
				        <ul >
				          <li class="sign_fuxuan">
				            
				            <input type="checkbox" value="remember-me"> 
				            
				            <label >记住密码</label>
				            
				          </li>
				        </ul>
			      </div>
			      <button class="sign_button" type="submit">登录</button>
		      </form>
    </div>
  </div>
</div>
</body>
</html>
