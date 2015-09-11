1.Please deploy the prototype onto a web server like "xampp"

2.For iPhone Home screen,you can open index.html in Safari,
and then click Bookmark icon of Safari,and choose "Add to Home screen",
and then you can visit this prototype directly like an Application of you iPhone in fullscreen.

3."data" folder has 4 json files,
myRatingLineChart.json and projectDetailsLineChart.json contains the data of Line Chart,
memberDetailsBarChart.json and satisfactionBarChart.json contains the data of Bar Chart.

For data of Bar Chart,you can set value from 0-100,the color of bar will be decided as:
80-100:Dark Green color
60-79:Light Green color
40-59:Blue color
20-39:Yellow color
0-19:Red color

4.About changing the different factor on pages:
  The following pages have factors and followed with the code:
    4.1.project_details.html:<span class="smiling"><i class="icons laugh"></i></span>
    4.2.member_details.html:<div class="info laugh"><span class="smiling"><i class="expr"></i></span></div>
    4.3.my_satisfaction.html:
                      <div class="info laugh"><span class="smiling"><i class="icons expr"></i></span></div>
                      and 
                      <div class="exp laugh"><i class="icons"></i></div>
    4.4.manager_dashboard.html:<div class="rate-status laugh"><i class="icons"></i></div>
    4.5.manager_project_details.html:
                      <a href="javascript:;" class="exp happy"><i class="icons"></i></a>
                      and
                      <span class="smiling"><i class="icons laugh"></i></span>
    4.6.manager_member_details.html:<div class="info laugh"><span class="smiling"><i class="expr"></i></span></div>
    4.7.manager_satisfaction.html:
                      <div class="info happy"><span class="smiling"><i class="icons expr"></i></span></div>
                      and
                      <span class="smiling"><i class="icons laugh"></i></span>
    You can switch between the class "happy","laugh","normal","sad","pain" to change different type of factors.
    For example,in project_details.html,you can change <span class="smiling"><i class="icons laugh"></i></span> 
                to <span class="smiling"><i class="icons pain"></i></span>
  
  
5.About changing the different Project Type icons on pages:
  The following pages have Project Type icons and followed with the code:
    5.1.dashboard.html:<div class="project health"><div class="flag"><span><i class="icons"></i></span></div></div>
    5.2.project_details.html:<a href="javascript:;" class="flag health"><span><i class="icons"></i></span></a>
    5.3.my_rating.html:<div class="project health"><div class="flag"><span><i class="icons"></i></span></div></div>
    5.4.manager_dashboard.html:<div class="project health"><div class="flag"><span><i class="icons"></i></span></div></div>
    5.5.manager_project_details.html:<a href="javascript:;" class="flag happy"><span><i class="icons"></i></span></a>
    5.6.manager_satisfaction.html:<a href="javascript:;" class="flag health"><span><i class="icons"></i></span></a>
    You can switch between the class "health","lorem","acme","acme-retail" to change different type of Project icons.
    For example,in dashboard.html,you can change <div class="project health"><div class="flag"><span><i class="icons"></i></span></div></div>
                to <div class="project lorem"><div class="flag"><span><i class="icons"></i></span></div></div>
  