﻿$(function(){$("#add").click(function(){$("#select1 option:selected").remove().appendTo("#select2")});$("#remove").click(function(){$("#select2 option:selected").remove().appendTo("#select1")});$("#select1").dblclick(function(){$("option:selected",this).remove().appendTo("#select2")});$("#select2").dblclick(function(){$("option:selected",this).remove().appendTo("#select1")});$("#left_up").click(function(){var a=$("#select1 option").index($("#select1 option:selected:first")),b=$("#select1 option:eq("+
(a-1)+")");if(0<a){var c=$("#select1 option:selected").remove();setTimeout(function(){b.before(c)},10)}});$("#left_down").click(function(){var a=$("#select1 option").index($("#select1 option:selected:last")),b=$("#select1 option").length-1,c=$("#select1 option:eq("+(a+1)+")");if(a<b){var d=$("#select1 option:selected").remove();setTimeout(function(){c.after(d)},10)}});$("#right_up").click(function(){var a=$("#select2 option").index($("#select2 option:selected:first")),b=$("#select2 option:eq("+(a-
1)+")");if(0<a){var c=$("#select2 option:selected").remove();setTimeout(function(){b.before(c)},10)}});$("#right_down").click(function(){var a=$("#select2 option").index($("#select2 option:selected:last")),b=$("#select2 option").length-1,c=$("#select2 option:eq("+(a+1)+")");if(a<b){var d=$("#select2 option:selected").remove();setTimeout(function(){c.after(d)},10)}})});
function toUpdatePassword(a){showThickBox("\u5bc6\u7801\u4fee\u6539","../../../system/systemmgmt/systemuser/toUpdateSystemUserPassword.kq?TB_iframe\x3dtrue\x26height\x3d550\x26width\x3d750",!1,"id\x3d"+a)}function toSelectUserOrganiz(){showThickBox("\u9009\u62e9\u7528\u6237\u7ec4\u7ec7\u673a\u6784","../../../system/systemmgmt/organiz/toSelectUserOrganiz.kq?TB_iframe\x3dtrue\x26height\x3d550\x26width\x3d750",!1)}
function initOrganizStruct(a,b){$("#organizName").attr("value",b);$("#organizNo").attr("value",a);$("#organizName").focus()}function removeSystemUser(a){confirm("\u786e\u5b9a\u8981\u5220\u9664\u8be5\u7cfb\u7edf\u7528\u6237")&&ajaxRequest("d_remove.kq",{id:a},function(b){b&&(b=b.replace(/(^\s*)|(\s*$)/g,""),"success"==b?(alert("\u5220\u9664\u6210\u529f"),$("#Tr"+a).remove()):alert("\u5220\u9664\u5931\u8d25"))})}
function allotUserRole(a){showThickBox("\u5206\u914d\u89d2\u8272","../../../system/systemmgmt/systemuser/toAllotUserRole.kq?TB_iframe\x3dtrue\x26height\x3d550\x26width\x3d750",!1,"id\x3d"+a)}
function updateUserState(a,b){confirm("\u786e\u5b9a\u4fee\u6539")&&ajaxRequest("u_updateUserState.kq",{id:a,state:b},function(c){c&&(c=c.replace(/(^\s*)|(\s*$)/g,""),"success"==c&&(alert("\u6210\u529f\uff01"),"1"==b?($("#clockUser"+a).css("display","inline-block"),$("#unClockUser"+a).css("display","none"),$("#State"+a).text("\u6b63\u5e38")):($("#unClockUser"+a).css("display","inline-block"),$("#clockUser"+a).css("display","none"),$("#State"+a).text("\u9501\u5b9a"))))})}
function submitAllotRoleForm(){var a=document.allotRoleForm;0==$("#select1 \x3e option").length&&$("#select1").append("\x3coption value\x3d'null-role'\x3e\x3c/option\x3e");$("#select1 \x3e option").attr("selected",!0);a.target="content";a.submit();window.top.TB_remove()}function submitForm(){var a=document.forms[0];a.target="content";a.submit();window.top.TB_remove()}function ajaxRequest(a,b,c){$.ajax({type:"POST",url:a,data:b,cache:!0,success:c})};