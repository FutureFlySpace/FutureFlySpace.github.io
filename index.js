(function () {
  let redirect_url = "https://bit.ly/m/FutureFly";
  let delay = 1; //second
  let input_time = document.querySelector("#url_time");
  let time = input_time.value = delay;

  function redirect_page() {
    if (1 < time) {
      time -= 1;
      input_time.value = time;
      setTimeout(redirect_page, 1000);
    } else {
      window.location.href = redirect_url;
    }
  }
  redirect_page();
})();
