//Chart function

//load Bar Chart
function loadBarChart(element,json_file_name){
  $.getJSON(
      "../data/"+json_file_name,
      function(json){
          $(function(){
	          var group_data1 = json[0].itemBarChartFlow1;
	          var group_data2 = json[0].itemBarChartFlow1;
	          var group_data3 = json[0].itemBarChartFlow1;
	          var group_data4 = json[0].itemBarChartFlow1;
	          var group_data5 = json[0].itemBarChartFlow1;
            
	          var bar_value1 = 0;
	          var bar_value2 = 0;
	          var bar_value3 = 0;
	          var bar_value4 = 0;
	          var bar_value5 = 0;

	          var length = group_data1.length;
	          
	          for(var i=0;i<length;i++)
	          {
	            bar_value1 = json[0].itemBarChartFlow1[i];
	            bar_value2 = json[0].itemBarChartFlow2[i];
	            bar_value3 = json[0].itemBarChartFlow3[i];
	            bar_value4 = json[0].itemBarChartFlow4[i];
	            bar_value5 = json[0].itemBarChartFlow5[i];
	            
	            //set bar heights
	            $(element+" li.group-one").eq(i).find("i").animate({height: bar_value1.toString()+"%"});
	            $(element+" li.group-two").eq(i).find("i").animate({height: bar_value2.toString()+"%"});
	            $(element+" li.group-three").eq(i).find("i").animate({height: bar_value3.toString()+"%"});
	            $(element+" li.group-four").eq(i).find("i").animate({height: bar_value4.toString()+"%"});
	            $(element+" li.group-five").eq(i).find("i").animate({height: bar_value5.toString()+"%"});
	            
	            $(element+" li.group-one").eq(i).find("i").attr("data-percent",bar_value1.toString());
	            $(element+" li.group-two").eq(i).find("i").attr("data-percent",bar_value2.toString());
	            $(element+" li.group-three").eq(i).find("i").attr("data-percent",bar_value3.toString());
	            $(element+" li.group-four").eq(i).find("i").attr("data-percent",bar_value4.toString());
	            $(element+" li.group-five").eq(i).find("i").attr("data-percent",bar_value5.toString());
	          }
          	
          	  //set bar colors
	          var bar_li = $(element+" li.group-one," + element+" li.group-two,"
	                       + element+" li.group-three," + element+" li.group-four,"
	                       + element+" li.group-five");
	          for(var i=0;i<bar_li.length;i++)
	          {
	            var height = parseInt(bar_li.eq(i).find("i").attr("data-percent"));
	            if(height>=80)
	            {
	              bar_li.eq(i).addClass("green");
	            }
	            if(height<80 && height>=60)
	            {
	              bar_li.eq(i).addClass("light-green");
	            }
	            if(height<60 && height>=40)
	            {
	              bar_li.eq(i).addClass("blue");
	            }
	            if(height<40 && height>=20)
	            {
	              bar_li.eq(i).addClass("yellow");
	            }
	            if(height<20)
	            {
	              bar_li.eq(i).addClass("red");
	            }
	          }
	          
          });
    })}//load Line Chartfunction loadLineChart(id,json_file_name){  $.getJSON(
      "../data/"+json_file_name,
      function(json){
         $(function(){

                 var flow=json[0].itemLineChartFlow;

                 var data = [
                                {
                                    value:flow,
                                    color:'#009dce',
                                    line_width:2
                                 }
                            ];

		 var chart = new iChart.LineBasic2D({
		  	render : id,
		 	data: data,
			align:'center',
			width : $("#"+id).width(),
			height : $("#"+id).height(),
			background_color:'#303e49',
			border: false,
			animation : true,
			animation_duration:800,
			crosshair:{
				enable:false,
				line_color:'#ec4646'
			},
			label:{
				fontsize:0
			},
			sub_option : {
				smooth : false,
				label:false,
				hollow:false,
				hollow_inside:false,
				point_size:0
			},
		 	coordinate:{
				width:$("#"+id).width(),
				height:$("#"+id).height(),
				striped_factor : 0.18,
				grid_color:'#e3e3e3',
				gridlinesVisible:false,
				axis:{
					color:'#303e49',
					width:[0,0,0,0]
				},
			scale:[{
				label : {
					fontsize:0
				},
				scale_size:0
				}]
			}
		 });

	 	chart.draw();
	 });   
    })}