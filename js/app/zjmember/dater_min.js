var dater=(function(){_dater=function(a){this.curDat=new Date();this.maxDat=new Date("2015/12/31");this.minDat=new Date("1980/01/01");this.selectYear=null;this.selectMonth=null;this.selectDate=null;for(var d in a){this[d]=a[d]}this.minDat&&(this.curDat=new Date(Math.max(this.minDat,this.curDat)));this.maxDat&&(this.curDat=new Date(Math.min(this.maxDat,this.curDat)));this.curDate=this.formate(this.curDat);this.maxDate=this.formate(this.maxDat);this.minDate=this.formate(this.minDat)};_dater.prototype={init:function(d){var c=this;c.selectYear.onchange=c.selectMonth.onchange=c.selectDate.onchange=function(){c.onchange.call(c,this,true)};c.onchange(c.selectYear,false);return c},onchange:function(e,f){var d=this;switch(e){case d.selectYear:if(f){d.curDate[0]=parseInt(e.value,10)||d.curDate[0];d.curDate[1]=1;d.curDate[2]=1;d.selectMonth.value=1}d.selectYear&&(function(){d.selectYear.options.length=0;for(var a=d.minDate[0];a<=d.maxDate[0];a++){d.selectYear.options.add(new Option(a+"年",a))}d.selectYear.value=d.curDate[0]})();d.onchange(d.selectMonth,f);break;case d.selectMonth:if(f){d.curDate[1]=parseInt(e.value,10)||d.curDate[1];d.curDate[2]=1;d.selectDate.value=1}d.selectMonth&&(function(){d.selectMonth.options.length=0;var c=Math.max((function(){var h=(d.curDate[0]==d.minDate[0])?d.minDate[1]:1;return h})(),1);var a=Math.min((function(){var h=d.curDate[0]==d.maxDate[0]?d.maxDate[1]:12;return h})(),12);d.curDate[1]=[c,d.curDate[1],a].sort(function(i,j){return i>j?1:0})[1];for(var b=c;b<=a;b++){d.selectMonth.options.add(new Option(b+"月",b))}d.selectMonth.value=d.curDate[1]})();d.onchange(d.selectDate,f);break;case d.selectDate:if(f){d.curDate[2]=parseInt(e.value,10)||d.curDate[2]}d.selectDate&&(function(){d.selectDate.options.length=0;var b=Math.max((function(){var h=((d.curDate[0]==d.minDate[0])&&(d.curDate[1]==d.minDate[1]))?d.minDate[2]:1;return h})(),1);var c=Math.min((function(){var h=(d.curDate[1] in {1:true,3:true,5:true,7:true,8:true,10:true,12:true})?31:30;return h})(),(function(){if(2==d.curDate[1]){var h=(d.curDate[0]%4==0&&d.curDate[0]%100!=0)||(d.curDate[0]%100==0&&d.curDate[0]%400==0)?28:29;return h}else{return 31}})(),(function(){var h=((d.curDate[0]==d.maxDate[0])&&(d.curDate[1]==d.maxDate[1]))?d.maxDate[2]:31;return h})());d.curDate[2]=[b,d.curDate[2],c].sort(function(i,j){return i>j?1:0})[1];for(var a=b;a<=c;a++){d.selectDate.options.add(new Option(a+"日",a))}d.selectDate.value=d.curDate[2]})();default:console.log(d.curDate);break}return d},formate:function(e){var d=this;if(e instanceof Array){return e}var f=new Array();f.push(parseInt(e.getFullYear(),10));f.push(parseInt(e.getMonth()+1,10));f.push(parseInt(e.getDate(),10));return f}};return _dater})();