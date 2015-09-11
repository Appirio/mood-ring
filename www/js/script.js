var calendar_event = "";//Set Event on calendar

$(document).ready(function () {
  //auto suggestion values 
  var consultant_array = ["Jack Harris","James Doe","Lames Doe"];
  var project_manager_array = ["Jane Riddle","Kane Riddle","Kand Riddle"];
  var projects_array = ["Java Program Project","Net Program Project","Java Web Project"];
  
  //render the custom style form elements
  if($(".form-container").length>0){
     $('.form-container').jqTransform({imgPath:'i/'});
  }
  
  //click on links
  $("a").click(function(event){
    var href = $(this).attr("href");
    window.location = href;
    if (href.lastIndexOf("login.html") >= 0) {
        StatusBar.overlaysWebView(true);
        StatusBar.styleLightContent();
    } else {
        StatusBar.overlaysWebView(false);
        StatusBar.styleDefault();
    }
    event.preventDefault();
  })
  
  var count = 0;
  //swipe on panels 
  $(".main-content.history-content,.main-content.member-details,"+
    ".main-content.manager-satisfaction,.main-content.user-rating-history").hammer().on('swipeleft', function(){
    var next_day_value = 0;
    var selected_date_text = $(".selected-calendar-date").html();
    var new_today = new Date();
    var date_today_str = (new_today.getYear()+1900)+"/"+(new_today.getMonth()+1)+"/"+new_today.getDate();
    
    //change Date text on page
    if(selected_date_text === "Today")
    {
      var next_date = new Date((new_today/1000+86400)*1000);
      
      //next date is in next month
      if(next_date.getMonth()>new_today.getMonth())
      {
        $(".btn-next").click();
      }
      
      var date_next_day_str = (next_date.getYear()+1900)+"/"+(next_date.getMonth()+1)+"/"+next_date.getDate();
      $(".selected-calendar-date").html(date_next_day_str);
      
      next_day_value = next_date.getDate();
    }
    else
    {
      var selected_date_text_str = selected_date_text.split("/");
      if(selected_date_text_str.length === 3)
      {
        var year = parseInt(selected_date_text_str[0])-1900;
        var month = parseInt(selected_date_text_str[1]);
        var day = parseInt(selected_date_text_str[2]);
        
        var selected_date = new Date(year+1900+"/"+month+"/"+day); 
        var next_date = new Date((selected_date/1000+86400)*1000);
        
        //next date is in next month
        if(next_date.getMonth()>selected_date.getMonth())
        {
          $(".btn-next").click();
        }
      
        var date_next_day_str = (next_date.getYear()+1900)+"/"+(next_date.getMonth()+1)+"/"+next_date.getDate();
        
        if(date_today_str === date_next_day_str)
        {
          $(".selected-calendar-date").html("Today");
        }
        else
        {
          $(".selected-calendar-date").html(date_next_day_str);
        }
        
        next_day_value = next_date.getDate();
      }
    }
    
    //change selection in Calendar
    if($(".calendar-table").length>0)
    {
      for(var i=0;i<$(".calendar-table td label").length;i++)
      {
        if($(".calendar-table td label").eq(i).attr("data-date") === date_next_day_str)
        {
          $(".calendar-table td label").eq(i).click();
        }
      }
    }
    
    //mock up the change in historys list
    if($(".historys-list").length>0)
    {
      var pre_text_str = $(".historys-list .history:eq(0) .name").html().split("-");
      var pre_text = pre_text_str[0];
      
      $(".historys-list").hide();
      $(".historys-list .history:eq(0) .name").html(pre_text + "-" + next_day_value.toString());
      $(".historys-list").fadeIn();
    }
    
    //mock up change of satisfaction slider in manager project details page
    if($(".time-choise").length>0)
    {
      $(".time-choise ul").hide();
      for(var i=0;i<$(".time-choise .choise").length;i++)
      {
        var count_number = parseInt($(".time-choise .choise").eq(i).find(".count").html());
        $(".time-choise .choise").eq(i).find(".count").html((count_number+1).toString());
      }
      $(".time-choise ul").fadeIn();
    }
  });
  
  $(".main-content.history-content,.main-content.member-details,"+
    ".main-content.manager-satisfaction,.main-content.user-rating-history").hammer().on('swiperight', function(){
    var prev_day_value = 0;
    var selected_date_text = $(".selected-calendar-date").html();
    var new_today = new Date();
    var date_today_str = (new_today.getYear()+1900)+"/"+(new_today.getMonth()+1)+"/"+new_today.getDate();
    
    //change Date text on page
    if(selected_date_text === "Today")
    {
      var prev_date = new Date((new_today/1000-86400)*1000);
      
      //prev date is in lasr month
      if(prev_date.getMonth()<new_today.getMonth())
      {
        $(".btn-prev").click();
      }
      
      var date_prev_day_str = (prev_date.getYear()+1900)+"/"+(prev_date.getMonth()+1)+"/"+prev_date.getDate();
      $(".selected-calendar-date").html(date_prev_day_str);
      
      prev_day_value = prev_date.getDate();
    }
    else
    {
      var selected_date_text_str = selected_date_text.split("/");
      if(selected_date_text_str.length === 3)
      {
        var year = parseInt(selected_date_text_str[0])-1900;
        var month = parseInt(selected_date_text_str[1]);
        var day = parseInt(selected_date_text_str[2]);
        
        var selected_date = new Date(year+1900+"/"+month+"/"+day); 
        var prev_date = new Date((selected_date/1000-86400)*1000);
        
        //prev date is in lasr month
        if(prev_date.getMonth()<selected_date.getMonth())
        {
          $(".btn-prev").click();
        }
      
        var date_prev_day_str = (prev_date.getYear()+1900)+"/"+(prev_date.getMonth()+1)+"/"+prev_date.getDate();
        
        if(date_today_str === date_prev_day_str)
        {
          $(".selected-calendar-date").html("Today");
        }
        else
        {
          $(".selected-calendar-date").html(date_prev_day_str);
        }
        
        prev_day_value = prev_date.getDate();
      }
    }
    
    //change selection in Calendar
    if($(".calendar-table").length>0)
    {
      for(var i=0;i<$(".calendar-table td label").length;i++)
      {
        if($(".calendar-table td label").eq(i).attr("data-date") === date_prev_day_str)
        {
          $(".calendar-table td label").eq(i).click();
        }
      }
    }
    
    //mock up the change in historys list
    if($(".historys-list").length>0)
    {
      var pre_text_str = $(".historys-list .history:eq(0) .name").html().split("-");
      var pre_text = pre_text_str[0];
      
      $(".historys-list").hide();
      $(".historys-list .history:eq(0) .name").html(pre_text + "-" + prev_day_value.toString());
      $(".historys-list").fadeIn();
    }
    
    //mock up change of satisfaction slider in manager project details page
    if($(".time-choise").length>0)
    {
      $(".time-choise ul").hide();
      for(var i=0;i<$(".time-choise .choise").length;i++)
      {
        var count_number = parseInt($(".time-choise .choise").eq(i).find(".count").html());
        $(".time-choise .choise").eq(i).find(".count").html((count_number+1).toString());
      }
      $(".time-choise ul").fadeIn();
    }
  });
  
  
  //click on Search button in header
  $("header .button-search").click(function(){
    $(".search-bar").removeClass("hide");
    $(".modal-bg").removeClass("hide");
    
    $(".top-search-input").focus();
    $(".top-search-input").val("");
  })
  
  //click on Cancel button in Search bar
  $(".search-bar .cancel-search-btn").click(function(){
    $(".search-bar").addClass("hide");
    $(".search-tip").slideUp();
    $(".modal-bg").addClass("hide");
  })
  
  //click on Factor icon to change it
  $(".set-factor .expression,.show-factor .expression").click(function(){
    //change header
    $("header .dashboard").addClass("hide");
    $("header .satisfaction").removeClass("hide");
    
    //change main content
    $(".main-content .dashboard").addClass("hide");
    $(".main-content .factor-content").removeClass("hide");
    
    //change page background color
    $("body").addClass("bg-white");
  })
  
  //select Factors
  $(".factor-area li a").click(function(){
    $(".factor-area li a").removeClass("active");
    $(this).addClass("active");
  })
  
  //click Cancel button in Select Factors screen
  $("header .cancel-select-factor-btn").click(function(){
    //change header
    $("header .dashboard").removeClass("hide");
    $("header .satisfaction").addClass("hide");
    
    //change main content
    $(".main-content .dashboard").removeClass("hide");
    $(".main-content .factor-content").addClass("hide");
    
    //reset selection and entered value
    $(".factor-content li a.active").removeClass("active");
    $(".factor-content .tell-us").val("");
    
    //change page background color
    $("body").removeClass("bg-white");
  })
  
  //click Submit button in Select Factors screen
  $("header .submit-select-factor-btn").click(function(){
    //change header
    $("header .dashboard").removeClass("hide");
    $("header .satisfaction").addClass("hide");
    
    //change main content
    $(".main-content .dashboard").removeClass("hide");
    $(".main-content .factor-content").addClass("hide");
    
    //show selected Factor
    if($(".factor-area li a.active").length>0)
    {
      var factor_class = $(".factor-area li a.active").attr("class").replace(" active","");
      $(".main-content .dashboard .set-factor").addClass("hide");
      $(".main-content .dashboard .show-factor").removeClass("hide");
      $(".main-content .dashboard .show-factor").attr("class","summary show-factor " + factor_class);
    }
    
    //change page background color
    $("body").removeClass("bg-white");
  })
  
  //click tabs
  $(".tabs .tab a").click(function(){
    $(".tabs .tab a").removeClass("active");
    $(this).addClass("active");
    
    var index = $(".tabs .tab a").index($(this));
    $(".tab-content").addClass("hide");
    $(".tab-content").eq(index).removeClass("hide");
  })
  
  //click on Rate button in Project Details page
  $(".project-details .rate").click(function(){
    if(!$(this).hasClass("disabled"))
    {
      //change header
      $("header .project-details").addClass("hide");
      $("header .rate-user").removeClass("hide");
      
      //change main content
      $(".main-content .project-details").addClass("hide");
      $(".main-content .rate-content").removeClass("hide");
      
      var src = $(this).parent().find("a img").attr("src");
      $(".main-content .rate-content").find("a img").attr("src",src);
      
      var scroll_offset = $("body").offset();  
      $("body,html").animate({
        scrollTop:scroll_offset.top+1
      },1);
    }
    
    $(".rate-btn-clicked").removeClass("rate-btn-clicked");
    $(this).addClass("rate-btn-clicked");
  })
  
  //click Cancel button in Rate User screen
  $("header .cancel-rate-user-btn,header .submit-rate-user-btn").click(function(){
    //change header
    $("header .project-details").removeClass("hide");
    $("header .rate-user").addClass("hide");
    
    //change main content
    $(".main-content .project-details").removeClass("hide");
    $(".main-content .rate-content").addClass("hide");
    
    //when click Cancel button,reset selection and entered value
    if($(this).hasClass("cancel-rate-user-btn"))
    {
      $(".rate-content li a.active").removeClass("active");
      $(".rate-content .tell-us").val("");
    }
    
    //when click Submit button,make Rate button gray
    if($(this).hasClass("submit-rate-user-btn"))
    {
      $(".rate-btn-clicked").addClass("disabled"); 
    }
  })
  
  //click Stars in Rate User screen
  $(".rate-area ul li a").click(function(){
    var index = $(".rate-area ul li a").index($(this));
    $(".rate-area ul li a").removeClass("active");
    var stars = $(".rate-area ul li a");
    for(var i=0;i<=index;i++)
    {
      stars.eq(i).addClass("active");
    }
  })

  //click Factor in Project Details page
  $(".project-details-page .smiling .icons").click(function(){
    var factor_class = $(this).attr("class").replace("icons ","");
    
    $(".mask-details").animate({ bottom: "+=235px" }, 500);
    $(".mask-project").removeClass("hide");
    
    $(".mask-details").attr("class","mask-details " + factor_class);
    $(".mask-details").find("a img").attr("src",$(this).parent().next().find("img").attr("src"));
  })
  
  //click mask layer
  $(".mask-project").click(function(){
    $(".mask-details").animate({ bottom: "-=235px" }, 500);
    $(".mask-project").addClass("hide");
  })
  
  //click Menu icon
  $(".button-menu-toggle").click(function(){
    $("aside").animate({ left: "+=325px" }, 500);
    $(".modal-bg").removeClass("hide");
    
    $(".main-content").addClass("fixed-position");
  })
  
  //click on cover layer of modal
  $(".modal-bg").click(function(){
    //hide search bar
    $(".search-bar").addClass("hide");
    $(".search-tip").slideUp();
    
    //hide menu
    $("aside").animate({ left: "-325px" }, 500);
    $(".modal-bg").addClass("hide");
    $(".main-content").removeClass("fixed-position");
    
    //hide calendar popup
    $(".main-content.calendar-content .calendar").hide();
    $(".main-content").removeClass("calendar-content");
  })
  
  //click rows in My Rating page
  $(".rate-content .item-row").click(function(){
    if($(this).next().hasClass("hide"))
    {
      //show detail links
      $(this).parents(".tab-content").find(".view-bar").addClass("hide");
      $(this).next().removeClass("hide");
    }
    else
    {
      //hide detail links
      $(this).parents(".tab-content").find(".view-bar").addClass("hide");
      $(this).next().addClass("hide");
    }
  })
  
  //click on search box input
  $(".top-search-input").click(function(event){
    $(".top-search-input").keyup();
    event.stopPropagation();
  })
  
  //type in search box to show auto suggestion popup
  $(".top-search-input").keyup(function(){
    var search_text = $(".top-search-input").val();
	  
    if(search_text !== "")
    {
      var consultant_matched = false;
      var project_manager_matched = false;
      var projects_matched = false;
	    
      $(".search-tip .consultant_result ul li.copy-row").remove();
      for(var i=0;i<consultant_array.length;i++)
      {
        if((consultant_array[i].toLowerCase()).indexOf(search_text.toLowerCase()) > -1)
        {
          consultant_matched = true;
	         
          var new_case_row = $(".search-tip .consultant_result ul li.hide").clone(true);
          new_case_row.addClass("copy-row").removeClass("hide");
          new_case_row.find("a").html(consultant_array[i]);
          $(".search-tip .consultant_result ul").append(new_case_row);
        }
      }
 	    
      if(consultant_matched)
      {
        //find result
        $(".search-tip .consultant_result").removeClass("hide");
        $(".search-tip .consultant_result .consultant_number_text").html($(".search-tip .consultant_result ul li").length-1);
      }
      else
      {
        //find no result
        $(".search-tip .consultant_result").addClass("hide");
      }
 	    
 	    
      $(".search-tip .project_manager_result ul li.copy-row").remove();
      for(var i=0;i<project_manager_array.length;i++)
      {
        if((project_manager_array[i].toLowerCase()).indexOf(search_text.toLowerCase()) > -1)
        {
          project_manager_matched = true;
	         
          var new_case_row = $(".search-tip .project_manager_result ul li.hide").clone(true);
          new_case_row.addClass("copy-row").removeClass("hide");
          new_case_row.find("a").html(project_manager_array[i]);
          $(".search-tip .project_manager_result ul").append(new_case_row);
        }
      }
 	    
      if(project_manager_matched)
      {
        //find result
        $(".search-tip .project_manager_result").removeClass("hide");
        $(".search-tip .project_manager_result .project_manager_number_text").html($(".search-tip .project_manager_result ul li").length-1);
      }
      else
      {
        //find no result
        $(".search-tip .project_manager_result").addClass("hide");
      }
 	    
 	    
      $(".search-tip .projects_result ul li.copy-row").remove();
      for(var i=0;i<projects_array.length;i++)
      {
        if((projects_array[i].toLowerCase()).indexOf(search_text.toLowerCase()) > -1)
        {
          projects_matched = true;
	         
          var new_case_row = $(".search-tip .projects_result ul li.hide").clone(true);
          new_case_row.addClass("copy-row").removeClass("hide");
          new_case_row.find("a").html(projects_array[i]);
          $(".search-tip .projects_result ul").append(new_case_row);
        }
      }
 	    
      if(projects_matched)
      {
        //find result
        $(".search-tip .projects_result").removeClass("hide");
        $(".search-tip .projects_result .projects_number_text").html($(".search-tip .projects_result ul li").length-1);
      }
      else
      {
        //find no result
        $(".search-tip .projects_result").addClass("hide");
      }
 	    
      if(consultant_matched || project_manager_matched || projects_matched)
      {
        $(".search-tip").slideDown();
      }
      else
      {
        $(".search-tip").slideUp(); 
      }
    }
    else
    {
      $(".search-tip").slideUp();
    }
  })
	
  //load Line chart
  if($("#canvasLineChart").length>0)
  {
    loadLineChart("canvasLineChart",$("#canvasLineChart").attr("data-file"));
  }
	
  //load bar chart
  if($(".histogram-box").length>0)
  {
    loadBarChart(".histogram-box ul",$(".histogram-box").attr("data-file"));
  }
	
  //window resize
  $(window).resize(function(){
    //load Line chart
    if($("#canvasLineChart").length>0)
    {
      loadLineChart("canvasLineChart",$("#canvasLineChart").attr("data-file"));
    }
  })
	
  //click calendar dropdown
  $(".filter .time").click(function(){
    $(".main-content").addClass("calendar-content");
    $(".main-content.calendar-content .calendar").fadeIn();
    
    $(".modal-bg").removeClass("hide");
  })
	
  //click on calendar dates
  $(document).on("click",".calendar-table td label",function(){
    if($(this).css("cursor") === "pointer")
    {
      $(".visited").removeClass("visited");
      var clicked_date = $(this).attr("data-date");
      $(this).addClass("visited");
      calendar_event = clicked_date;
      
      $(".selected-calendar-date").html(clicked_date);
      $(".modal-bg").click();
    }
  })
	
  //calendar
  var today = new Date();
  var year;
  var month;

  if($(".calendar-box").length === 1)
  {
    year = today.getFullYear();
    month = today.getMonth() + 1;
    var monthText = convertMonthText(month) + " " + year; 
    $(".month-title label").html(monthText);
    
    initCalendar();
  }
  
  //prev month
  $(".btn-prev").on("click", function(){
    $(".month-title label").hide();
    $(".calendar-table").hide();
    
    today.setDate(15);
    today.setMonth(today.getMonth()-1);
    
    year = today.getFullYear();
    month = today.getMonth() + 1;
    var monthText = convertMonthText(month) + " " + year; 
    $(".month-title label").html(monthText);
    initCalendar();
    
    $(".month-title label").fadeIn();
    $(".calendar-table").fadeIn();
  });

  //next month
  $(".btn-next").on("click", function(){
    $(".month-title label").hide();
    $(".calendar-table").hide();
  
    today.setDate(15);
    today.setMonth(today.getMonth()+1);
    
    year = today.getFullYear();
    month = today.getMonth() + 1;
    var monthText = convertMonthText(month) + " " + year; 
    $(".month-title label").html(monthText);
    initCalendar();
    
    $(".month-title label").fadeIn();
    $(".calendar-table").fadeIn();
  });

  //init calendar
  var Event_Name = "";
  var Task_Name = "";
  function initCalendar(){
    
    var Nowdate=new Date(today);
    var MonthNextFirstDay=new Date(Nowdate.getYear()+1900,Nowdate.getMonth()+1,1);
    var v_today=new Date(MonthNextFirstDay-86400000);

    
    var totalDays = v_today.getDate();
    
    v_today.setDate(1);
    var firstDayinWeekday = v_today.getDay();
    var weeks = 0;
    
    var table = $(".calendar-box").find("table tbody");
    table.find("td label").html("");
    table.find("td label").removeClass("visited");
    
    table.find("td.current-event").removeClass("current-event");
    table.find("td.disable-text").removeClass("disable-text");
    
    table.find("td a").remove();
    table.find("td label").show();
    table.find("td.past-event").removeClass("past-event");
    table.find("td.next-event").removeClass("next-event");
    
    if(table.find("tr").length > 5)
      table.find("tr").eq(table.find("tr").length-1).remove();
      
    if(table.find("tr").length < 5)
    {
      var newRow = table.find("tr").eq(0).clone();
      newRow.find("td label").html("");
      newRow.find("td a").remove();
      newRow.find("td label").show();
      newRow.find("td").removeClass("current-event").removeClass("past-event").removeClass("next-event");
      table.append(newRow);
    }
    
    for(var i = 1; i <= totalDays; i++)
    {
      v_today.setDate(i);
      var weekDay = v_today.getDay();//0-6
        
      var row = table.find("tr").eq(weeks);
      var cell = row.find("td").eq(weekDay);
      if(isToday(v_today))
        cell.addClass("current-event");
      cell.find("label").html(i);
      
      var clicked_date = v_today.getYear()+1900+"/"+(v_today.getMonth()+1)+"/"+v_today.getDate();
      cell.find("label").attr("data-date",clicked_date);
      
      var returnValue = setEvent(v_today);
      if(returnValue != "")
      {
        cell.find("label").addClass("visited");
      }
      
      if(i === totalDays)
      {
        var k = 1;
        for(var j = (weekDay+1); j <=6 ;j++)
        {
          row.find("td").eq(j).addClass("disable-text");
          row.find("td").eq(j).find("label").html(k);
          k++;
        }
        
        var first_row = table.find("tr").eq(0);
        var blankCount = 0;
        for(var j = 0;j <=6; j++)
        {
          var cell_first_row = first_row.find("td").eq(j);
          if(cell_first_row.find("label").html() === "")
            blankCount++;
        }
        
        v_today.setMonth(v_today.getMonth())
        v_today.setDate(0);
        var prev_totalDays = v_today.getDate();
        
        for(var j = 0;j <blankCount; j++)
        {
          var cell_first_row = first_row.find("td").eq(j).addClass("disable-text");
          cell_first_row.find("label").html(prev_totalDays-blankCount+j+1);
        }
      }
      
      if(weekDay === 6 && i < totalDays)
      {
        weeks++;
        if(weeks>4 && i < totalDays)
        {
          var newRow = table.find("tr").eq(0).clone();
          newRow.find("td label").html("");
          newRow.find("td a").remove();
          newRow.find("td label").show();
          newRow.find("td").removeClass("current-event").removeClass("past-event").removeClass("next-event");
          table.append(newRow);
        }
      }
    }
    
    if(weeks === 3)
    {
      table.find("tr").eq(4).remove();
    }
  }
  
  //check Event day
  function setEvent(v_today){
    if(calendar_event !== "")
    {
      var day = new Date(calendar_event);
      
      var date_day = day.getYear()+"-"+(day.getMonth()+1)+"-"+day.getDate();
      var date_v_today = v_today.getYear()+"-"+(v_today.getMonth()+1)+"-"+v_today.getDate();
      
      if(date_day === date_v_today)
      {
        return "yes";
      }
    }
    return "";
  }
  
  //check if the date is on today
  function isToday(v_today){
    var new_today = new Date();
    
    var date_day = new_today.getYear()+"-"+(new_today.getMonth()+1)+"-"+new_today.getDate();
    var date_v_today = v_today.getYear()+"-"+(v_today.getMonth()+1)+"-"+v_today.getDate();
    if(date_day === date_v_today)
      return true;
    else
      return false;
  }

  //convert month text
  function convertMonthText(month){
    var monthText = "";
    switch(month)
    {
      case 1:
        monthText = "January";
        break;
      case 2:
        monthText = "February";
        break;
      case 3:
        monthText = "March";
        break;
      case 4:
        monthText = "April";
        break;
      case 5:
        monthText = "May";
        break;
      case 6:
        monthText = "June";
        break;
      case 7:
        monthText = "July";
        break;
      case 8:
        monthText = "August";
        break;
      case 9:
        monthText = "September";
        break;
      case 10:
        monthText = "October";
        break;
      case 11:
        monthText = "November";
        break;
      case 12:
        monthText = "December";
        break;
    }
    return monthText;
  }
});