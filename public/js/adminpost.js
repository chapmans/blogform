$(document).ready(function(){
  $('#wcount').text($('#text').val().match(/\S+/g).length);
  $('#text').height($('#text')[0].scrollHeight + 100);
  
  $('#text').on('input', function() {
    $('#wcount').text($('#text').val().match(/\S+/g).length);
    $(this).height(0);
    $(this).height(this.scrollHeight);
  });
  
  $('#noteform').submit(function(){
    var mval = $("#inote").val();
    $.ajax({
      type: "POST",
      url: "/movement/dash/note",
      data: {
        note:  mval
      },
      success: function(data) {
        $("#inote").val("");
        $("#notelist").prepend("<div class=\"note\" id=\"post" + data + "\">" +  
          "<div class=\"notetext\" id=\"text" + data + "\">" + mval + 
          "</div></div>");
      }
    });
    return false;
  });
  
  $('.switch').click(function(){
    console.log($('#x').prop('checked'));
  });
  
  var tagArray = [];
  
  function Tag(action, tag) {
    this.action = action;
    this.tag = tag;
  }
  
  $('#addtag').keypress(function(event){
    if (event.which === 13) {
      var mval = $("#addtag").val().trim();
      if (mval.length === 0) {
        return false;
      }
      $("#taglist").append("<div class=\"tag\"><a class=\"ti\" href=\"#\">&times;</a> #<span class=\"tim\">" + mval + "</span></div>");
      $('#addtag').val("");
      tagArray.push(new Tag(1, mval));
      
      $('#tagarray').val(JSON.stringify(tagArray));
      console.log($('#tagarray').val());
      return false;
    }
  });
  
  $('#taglist').on('click', '.ti', function(event){
    var x = $(this).parent().children('.tim');
    var mval = x.text();
    tagArray.push(new Tag(-1, mval));
    
    $('#tagarray').val(JSON.stringify(tagArray));
    console.log($('#tagarray').val());
    $(this).parent().remove();
    return false;
  });
});
