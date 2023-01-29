var myForm = document.getElementById("new-form");

myForm.addEventListener("submit", function(event) {
  event.preventDefault(); // ignore normal form submit button
  var alias = document.getElementById("alias");
  var ctype = document.getElementById("ctype");
  var status_code = document.getElementById("status_code");
  var content = document.getElementById("content");
  var jdata = {
    alias: alias.value,
    status_code: status_code.value,
    ctype: ctype.value,
    content: content.value,
  };

  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState === XMLHttpRequest.DONE) {
      try {
        var response = JSON.parse(this.responseText);
      } catch (e) {
        var response = { detail: [{ msg: this.responseText }] };
      }

      if (this.status == 201) {
        console.log("OK");
        var created =
          '<div class="alert alert-success" role="alert"><h4>Saved!</h4><code>id: ' +
          response.id +
          "</code></div>";
        document.getElementById("messages").innerHTML = created;
      } else {
        console.log("ERROR");
        if (response.detail) {
          var error =
            '<div class="alert alert-danger" role="alert"><h4>Error!</h4>';
          if (typeof response.detail != "string") {
            for (var i = 0; i < response.detail.length; i++) {
              if (response.detail[i].msg) {
                error = error + "<li>" + response.detail[i].msg + "</li>";
              }
            }
          } else {
            error = error + "<li>" + response.detail + "</li>";
          }
          error = error + "</div>";
        } else {
          error = this.responseText;
        }
        document.getElementById("messages").innerHTML = error;
      }
      window.scrollTo(0, 0);
    }
  };

  xmlhttp.open((method = "POST"), (url = "/v1/customresponse"), (async = true));
  xmlhttp.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
  xmlhttp.send(JSON.stringify(jdata));
});
